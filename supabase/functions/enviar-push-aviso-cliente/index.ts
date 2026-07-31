// Edge Function: enviar-push-aviso-cliente
//
// Envía la notificación push de un aviso de texto libre (título + texto que redacta el propio
// cliente, p.ej. "cambio de horario") a un seguidor concreto. NO la llama la app Flutter: la
// dispara un Database Webhook configurado en Supabase Studio sobre INSERT en
// "TClienteAvisosDestinatarios" (esa fila ya la crea el trigger
// FSistemaCrearDestinatariosClienteAviso de la migración 031, en la misma transacción que el
// aviso, así que el buzón en la app nunca depende de que este envío funcione).
//
// Hermana de "enviar-push-aviso" (que es para el aviso automático de "hay una publicación
// nueva"): se mantiene como función aparte para no tocar esa, aunque comparte los mismos
// secretos y la misma forma de hablar con FCM.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: enviar-push-aviso-cliente
//   3. Pega este archivo como index.ts y despliega.
//   4. Reutiliza los secretos ya existentes de "enviar-push-aviso": "FIREBASE_SERVICE_ACCOUNT_KEY"
//      y "WEBHOOK_SHARED_SECRET" (no hace falta crear ninguno nuevo).
//   5. Database -> Webhooks -> Create a new hook: tabla "TClienteAvisosDestinatarios", evento
//      INSERT, tipo "Supabase Edge Functions", función "enviar-push-aviso-cliente". Añade la
//      cabecera "X-Webhook-Secret: <el mismo valor que WEBHOOK_SHARED_SECRET>" (no toques la
//      cabecera "Authorization" que ya viene puesta por defecto).

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9';

const MAX_CARACTERES_TEXTO_PUSH = 120;

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
    console.error('enviar-push-aviso-cliente: error no controlado', e);
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
  const destinatarioAviso = payload?.record;
  if (!destinatarioAviso?.IdSistemaUsuario || !destinatarioAviso?.IdClienteAviso) {
    return jsonResponse({ error: 'Payload de webhook inesperado' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: destinatario } = await adminClient
    .from('TSistemaUsuarios')
    .select('NotificacionesPushActivas')
    .eq('IdSistemaUsuario', destinatarioAviso.IdSistemaUsuario)
    .maybeSingle();
  if (!destinatario?.NotificacionesPushActivas) {
    console.log(
      'enviar-push-aviso-cliente: omitido, usuario sin notificaciones push activadas',
      destinatarioAviso.IdSistemaUsuario,
    );
    return jsonResponse({ omitido: 'usuario sin notificaciones push activadas' });
  }

  const { data: dispositivos } = await adminClient
    .from('TSistemaDispositivosPush')
    .select('Token')
    .eq('IdSistemaUsuario', destinatarioAviso.IdSistemaUsuario);
  if (!dispositivos || dispositivos.length === 0) {
    console.log(
      'enviar-push-aviso-cliente: omitido, usuario sin dispositivos registrados',
      destinatarioAviso.IdSistemaUsuario,
    );
    return jsonResponse({ omitido: 'usuario sin dispositivos registrados' });
  }

  // A diferencia de "enviar-push-aviso" (publicaciones), aquí el título y el texto los ha
  // redactado el propio cliente a propósito para que el seguidor los lea, así que sí se pueden
  // usar tal cual en la notificación (solo se recorta el texto para que quepa bien).
  const { data: aviso, error: avisoError } = await adminClient
    .from('TClienteAvisos')
    .select('Titulo, Texto, TClienteSedes(TSistemaUsuarios(Nombre))')
    .eq('IdClienteAviso', destinatarioAviso.IdClienteAviso)
    .maybeSingle();
  if (avisoError || !aviso) {
    return jsonResponse({ error: 'Aviso no encontrado' }, 404);
  }
  const sede = aviso.TClienteSedes as unknown as { TSistemaUsuarios: { Nombre: string } | null };
  const nombreCliente = sede?.TSistemaUsuarios?.Nombre ?? '';
  const texto =
    aviso.Texto.length > MAX_CARACTERES_TEXTO_PUSH
      ? `${aviso.Texto.slice(0, MAX_CARACTERES_TEXTO_PUSH)}…`
      : aviso.Texto;

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
              title: aviso.Titulo,
              body: nombreCliente ? `${nombreCliente}: ${texto}` : texto,
            },
            data: {
              idClienteAviso: destinatarioAviso.IdClienteAviso,
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
          console.error('enviar-push-aviso-cliente: fallo enviando push', errBody);
        }
        return { token, ok: false };
      }
      return { token, ok: true };
    }),
  );

  const enviados = resultados.filter((r) => r.ok).length;
  console.log('enviar-push-aviso-cliente: resultado', { enviados, total: resultados.length });
  return jsonResponse({ enviados, total: resultados.length });
}
