// Edge Function: enviar-push-recordatorio
//
// Envía la notificación push de un recordatorio personal (070) al usuario que lo configuró. NO
// la llama la app Flutter: la dispara un Database Webhook configurado en Supabase Studio sobre
// UPDATE en "TClientePublicacionesRecordatorios" (esa fila la marca "Enviado = true" el job de
// pg_cron "FSistemaMarcarRecordatoriosVencidos" de la migración 070, así que el recordatorio en
// la app nunca depende de que este envío funcione: solo se pierde el push, no el registro).
//
// Un UPDATE de esta tabla también se dispara cuando el usuario simplemente EDITA un recordatorio
// todavía pendiente (cambia la fecha/hora) — por eso lo primero que se comprueba es que el
// registro que llega ya tiene "Enviado = true"; si no, no es el caso que interesa y se ignora.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: enviar-push-recordatorio
//   3. Pega este archivo como index.ts y despliega.
//   4. Secretos: si ya desplegaste "enviar-push-aviso" no hace falta nada más (los secretos de
//      Edge Functions son del proyecto entero, no por función) — "FIREBASE_SERVICE_ACCOUNT_KEY"
//      y "WEBHOOK_SHARED_SECRET" ya están disponibles aquí también.
//   5. Database -> Webhooks -> Create a new hook: tabla "TClientePublicacionesRecordatorios",
//      evento UPDATE, tipo "Supabase Edge Functions", función "enviar-push-recordatorio". NO
//      toques la cabecera "Authorization" (la gestiona Supabase); añade una cabecera NUEVA
//      "X-Webhook-Secret: <el mismo valor que WEBHOOK_SHARED_SECRET>".

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9';

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  try {
    return await handle(req);
  } catch (e) {
    console.error('enviar-push-recordatorio: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  const secretoRecibido = req.headers.get('X-Webhook-Secret');
  const secretoEsperado = Deno.env.get('WEBHOOK_SHARED_SECRET');
  if (!secretoEsperado || secretoRecibido !== secretoEsperado) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }

  const payload = await req.json();
  const recordatorio = payload?.record;
  if (!recordatorio?.IdSistemaUsuario || !recordatorio?.IdClientePublicacion) {
    return jsonResponse({ error: 'Payload de webhook inesperado' }, 400);
  }
  // Solo interesa el momento en que el cron lo marca "Enviado": una edición de uno todavía
  // pendiente también dispara este mismo webhook (es un UPDATE cualquiera de la tabla), pero
  // no debe generar un push.
  if (recordatorio.Enviado !== true) {
    return jsonResponse({ omitido: 'recordatorio todavía no enviado (edición del pendiente)' });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: destinatario } = await adminClient
    .from('TSistemaUsuarios')
    .select('NotificacionesPushActivas')
    .eq('IdSistemaUsuario', recordatorio.IdSistemaUsuario)
    .maybeSingle();
  if (!destinatario?.NotificacionesPushActivas) {
    console.log(
      'enviar-push-recordatorio: omitido, usuario sin notificaciones push activadas',
      recordatorio.IdSistemaUsuario,
    );
    return jsonResponse({ omitido: 'usuario sin notificaciones push activadas' });
  }
  // Sin distinción de idioma (a diferencia de "enviar-push-aviso"): el texto es "Esquela"/el
  // nombre del tipo de acto tal cual lo escribió el admin en el catálogo, más el nombre del
  // fallecido -ninguno de los dos se traduce en ningún otro sitio de la app tampoco-.

  const { data: dispositivos } = await adminClient
    .from('TSistemaDispositivosPush')
    .select('Token')
    .eq('IdSistemaUsuario', recordatorio.IdSistemaUsuario);
  if (!dispositivos || dispositivos.length === 0) {
    console.log(
      'enviar-push-recordatorio: omitido, usuario sin dispositivos registrados',
      recordatorio.IdSistemaUsuario,
    );
    return jsonResponse({ omitido: 'usuario sin dispositivos registrados' });
  }

  // A diferencia de "enviar-push-aviso" (que deliberadamente NO nombra al fallecido, por ser un
  // aviso de "hay una publicación nueva" que llega a TODOS los seguidores de la sede), aquí el
  // propio usuario ha pedido expresamente que se le recuerde ESTA publicación en concreto: sin
  // decir cuál es, la notificación no serviría de mucho como recordatorio.
  const { data: publicacion, error: publicacionError } = await adminClient
    .from('TClientePublicaciones')
    .select(
      'IdClienteSede, NombreFallecido, Tipo, ActoTipoOtro, TConfiguracionActoTipos(Nombre)',
    )
    .eq('IdClientePublicacion', recordatorio.IdClientePublicacion)
    .maybeSingle();
  if (publicacionError || !publicacion) {
    return jsonResponse({ error: 'Publicación no encontrada' }, 404);
  }
  const actoTipo = publicacion.TConfiguracionActoTipos as unknown as { Nombre: string } | null;
  const tipoPublicacion =
    publicacion.Tipo === 'ACTO'
      ? (publicacion.ActoTipoOtro ?? actoTipo?.Nombre ?? 'Acto')
      : 'Esquela';
  const titulo = 'Recordatorio';
  const cuerpo = `${tipoPublicacion} · ${publicacion.NombreFallecido}`;

  const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_KEY')!);
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const authClient = await auth.getClient();
  const accessToken = (await authClient.getAccessToken()).token;
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

  const resultados = await Promise.all(
    dispositivos.map(async ({ Token: token }) => {
      const resp = await fetch(fcmUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title: titulo,
              body: cuerpo,
            },
            data: {
              idClienteSede: publicacion.IdClienteSede ?? '',
              idClientePublicacion: recordatorio.IdClientePublicacion,
              idClientePublicacionRecordatorio: recordatorio.IdClientePublicacionRecordatorio ?? '',
            },
          },
        }),
      });

      if (!resp.ok) {
        const errBody = await resp.json().catch(() => null);
        const errorStatus = errBody?.error?.status;
        if (errorStatus === 'UNREGISTERED' || errorStatus === 'NOT_FOUND' || errorStatus === 'INVALID_ARGUMENT') {
          await adminClient.from('TSistemaDispositivosPush').delete().eq('Token', token);
        } else {
          console.error('enviar-push-recordatorio: fallo enviando push', errBody);
        }
        return { token, ok: false };
      }
      return { token, ok: true };
    }),
  );

  const enviados = resultados.filter((r) => r.ok).length;
  console.log('enviar-push-recordatorio: resultado', { enviados, total: resultados.length });
  return jsonResponse({ enviados, total: resultados.length });
}
