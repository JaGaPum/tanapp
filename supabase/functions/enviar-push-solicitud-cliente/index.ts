// Edge Function: enviar-push-solicitud-cliente
//
// Avisa por push a todos los administradores cuando llega una solicitud de alta de cliente
// nueva. NO la llama la app Flutter: la dispara un Database Webhook configurado en Supabase
// Studio sobre INSERT en "TClienteSolicitudes". La solicitud en sí ya queda guardada por el
// propio INSERT (con o sin este envío), y ya aparece en la pestaña "Avisos" del admin vía la
// tarjeta de "solicitudes pendientes" (AvisosScreen, solicitudesPendientesCountProvider) —
// esta función solo añade el aviso push, para que el admin se entere sin tener que abrir la app.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: enviar-push-solicitud-cliente
//   3. Pega este archivo como index.ts y despliega.
//   4. Reutiliza los mismos secretos que "enviar-push-aviso": "FIREBASE_SERVICE_ACCOUNT_KEY" y
//      "WEBHOOK_SHARED_SECRET" (si esta función va en un proyecto distinto, cópialos igual).
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente.
//   5. Database -> Webhooks -> Create a new hook: tabla "TClienteSolicitudes", evento INSERT,
//      tipo "Supabase Edge Functions", función "enviar-push-solicitud-cliente". NO toques la
//      cabecera "Authorization" que ya viene puesta por defecto. En vez de eso, añade una
//      cabecera NUEVA: "X-Webhook-Secret: <el mismo valor que WEBHOOK_SHARED_SECRET>".

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
    console.error('enviar-push-solicitud-cliente: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const secretoRecibido = req.headers.get('X-Webhook-Secret');
  const secretoEsperado = Deno.env.get('WEBHOOK_SHARED_SECRET');
  if (!secretoEsperado || secretoRecibido !== secretoEsperado) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }

  const payload = await req.json();
  const solicitud = payload?.record;
  if (!solicitud?.IdClientesSolicitud || !solicitud?.RazonSocial) {
    return jsonResponse({ error: 'Payload de webhook inesperado' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Mismo motivo que en usuarios_repository.dart (_perfilSelect): "TSistemaUsuariosRoles" tiene
  // más de una FK hacia "TSistemaUsuarios", así que PostgREST necesita que se le indique cuál.
  const { data: admins, error: adminsError } = await adminClient
    .from('TSistemaUsuarios')
    .select(
      'IdSistemaUsuario, NotificacionesPushActivas, IdSistemaIdiomaPreferido, ' +
        'TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario(TSistemaRoles(Codigo))',
    )
    .eq('Activo', true);
  if (adminsError) {
    console.error('enviar-push-solicitud-cliente: fallo consultando administradores', adminsError);
    return jsonResponse({ error: 'No se pudieron consultar los administradores' }, 500);
  }

  const destinatarios = (admins ?? []).filter((u) =>
    u.NotificacionesPushActivas &&
    (u.TSistemaUsuariosRoles ?? []).some(
      (r: { TSistemaRoles: { Codigo: string } | null }) => r.TSistemaRoles?.Codigo === 'ADMIN',
    )
  );
  if (destinatarios.length === 0) {
    console.log('enviar-push-solicitud-cliente: omitido, ningún admin con push activado');
    return jsonResponse({ omitido: 'ningún admin con push activado' });
  }

  const { data: idiomas } = await adminClient.from('TSistemaIdiomas').select('IdSistemaIdioma, Codigo');
  const codigoPorIdioma = new Map((idiomas ?? []).map((i) => [i.IdSistemaIdioma, i.Codigo]));

  const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_KEY')!);
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const authClient = await auth.getClient();
  const accessToken = (await authClient.getAccessToken()).token;
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

  let enviados = 0;
  let total = 0;

  for (const admin of destinatarios) {
    const { data: dispositivos } = await adminClient
      .from('TSistemaDispositivosPush')
      .select('Token')
      .eq('IdSistemaUsuario', admin.IdSistemaUsuario);
    if (!dispositivos || dispositivos.length === 0) continue;

    const esGallego = codigoPorIdioma.get(admin.IdSistemaIdiomaPreferido) === 'GL';
    const titulo = esGallego ? 'Nova solicitude de alta' : 'Nueva solicitud de alta';
    const cuerpo = esGallego
      ? `${solicitud.RazonSocial} quere darse de alta como cliente.`
      : `${solicitud.RazonSocial} quiere darse de alta como cliente.`;

    for (const { Token: token } of dispositivos) {
      total++;
      const resp = await fetch(fcmUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: titulo, body: cuerpo },
            data: { idClientesSolicitud: solicitud.IdClientesSolicitud },
          },
        }),
      });

      if (!resp.ok) {
        const errBody = await resp.json().catch(() => null);
        const errorStatus = errBody?.error?.status;
        if (errorStatus === 'UNREGISTERED' || errorStatus === 'NOT_FOUND' || errorStatus === 'INVALID_ARGUMENT') {
          await adminClient.from('TSistemaDispositivosPush').delete().eq('Token', token);
        } else {
          console.error('enviar-push-solicitud-cliente: fallo enviando push', errBody);
        }
        continue;
      }
      enviados++;
    }
  }

  console.log('enviar-push-solicitud-cliente: resultado', { enviados, total });
  return jsonResponse({ enviados, total });
}
