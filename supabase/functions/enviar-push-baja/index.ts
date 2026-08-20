// Edge Function: enviar-push-baja
//
// Cuando un CLIENTE o USUARIO_ORDINARIO se da de baja a sí mismo desde su cuenta (ver
// AccountScreen), esta función hace dos cosas: avisa por push a todos los administradores, y
// manda al propio usuario un email de confirmación/despedida (plantilla "BAJA_CONFIRMADA" en
// TConfiguracionComunicaciones, 061, enviada vía Resend). NO la llama la app Flutter: la
// dispara un Database Webhook configurado en Supabase Studio sobre INSERT en "TSistemaBajas"
// (058). El registro de la baja en sí ya queda guardado por el propio INSERT (con o sin este
// envío) y ya sirve para el gráfico "Altas y bajas por mes" del dashboard de admin — esta
// función solo añade las notificaciones. Mismo patrón que "enviar-push-solicitud-cliente".
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: enviar-push-baja
//   3. Pega este archivo como index.ts y despliega.
//   4. Secretos (Edge Functions -> Secretos):
//      - "FIREBASE_SERVICE_ACCOUNT_KEY" y "WEBHOOK_SHARED_SECRET": los mismos que ya usa
//        "enviar-push-aviso".
//      - "RESEND_API_KEY": la API key de la cuenta de Resend (la que ya se usa para el email de
//        restablecer contraseña vía el SMTP de Supabase Auth) — aquí se llama directo a la API
//        de Resend, no hace falta volver a darla de alta si ya la tienes, solo copiarla aquí
//        como secreto de esta función.
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente.
//   5. Database -> Webhooks -> Create a new hook: tabla "TSistemaBajas", evento INSERT, tipo
//      "Supabase Edge Functions", función "enviar-push-baja". NO toques la cabecera
//      "Authorization" que ya viene puesta por defecto. En vez de eso, añade una cabecera
//      NUEVA: "X-Webhook-Secret: <el mismo valor que WEBHOOK_SHARED_SECRET>".
//   6. El remitente del email ("Remitente" en TConfiguracionComunicaciones, hoy
//      "no-reply@tanapp.es") tiene que ser de un dominio verificado en Resend; si usas otro
//      dominio, actualiza esa columna a mano.

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
    console.error('enviar-push-baja: error no controlado', e);
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
  const baja = payload?.record;
  if (!baja?.IdSistemaBaja || !baja?.IdSistemaUsuario || !baja?.Rol) {
    return jsonResponse({ error: 'Payload de webhook inesperado' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: usuarioBaja } = await adminClient
    .from('TSistemaUsuarios')
    .select('Nombre, Email, IdSistemaIdiomaPreferido')
    .eq('IdSistemaUsuario', baja.IdSistemaUsuario)
    .maybeSingle();
  const nombreBaja = usuarioBaja?.Nombre ?? '—';

  const { data: idiomas } = await adminClient.from('TSistemaIdiomas').select('IdSistemaIdioma, Codigo');
  const codigoPorIdioma = new Map((idiomas ?? []).map((i) => [i.IdSistemaIdioma, i.Codigo]));

  const resultados: Record<string, unknown> = {};
  resultados.email = await enviarEmailBaja(adminClient, {
    email: usuarioBaja?.Email,
    nombre: nombreBaja,
    esGallego: codigoPorIdioma.get(usuarioBaja?.IdSistemaIdiomaPreferido) === 'GL',
  });
  resultados.push = await enviarPushAdmins(adminClient, {
    nombreBaja,
    rol: baja.Rol,
    idSistemaUsuario: baja.IdSistemaUsuario,
    codigoPorIdioma,
  });

  console.log('enviar-push-baja: resultado', resultados);
  return jsonResponse(resultados);
}

// ---------------------------------------------------------------------
// Email de confirmación al propio usuario, vía Resend.
// ---------------------------------------------------------------------
async function enviarEmailBaja(
  // deno-lint-ignore no-explicit-any
  adminClient: any,
  opts: { email: string | undefined; nombre: string; esGallego: boolean },
): Promise<unknown> {
  if (!opts.email) return { omitido: 'usuario sin email' };

  const resendApiKey = Deno.env.get('RESEND_API_KEY');
  if (!resendApiKey) {
    console.error('enviar-push-baja: falta el secreto RESEND_API_KEY');
    return { omitido: 'falta RESEND_API_KEY' };
  }

  const { data: comunicacion } = await adminClient
    .from('TConfiguracionComunicaciones')
    .select(
      'Remitente, TConfiguracionComunicacionesIdiomas(Asunto, Cuerpo, TSistemaIdiomas(Codigo))',
    )
    .eq('CodComunicacion', 'BAJA_CONFIRMADA')
    .eq('Activo', true)
    .maybeSingle();
  if (!comunicacion) {
    console.error('enviar-push-baja: no existe la comunicación BAJA_CONFIRMADA (ver 061)');
    return { omitido: 'sin plantilla BAJA_CONFIRMADA' };
  }

  const idiomaBuscado = opts.esGallego ? 'GL' : 'ES';
  const traducciones = comunicacion.TConfiguracionComunicacionesIdiomas ?? [];
  const traduccion =
    traducciones.find((t: { TSistemaIdiomas: { Codigo: string } | null }) =>
      t.TSistemaIdiomas?.Codigo === idiomaBuscado
    ) ?? traducciones[0];
  if (!traduccion) return { omitido: 'plantilla BAJA_CONFIRMADA sin traducciones' };

  const asunto = (traduccion.Asunto ?? '').replaceAll('{nombre}', opts.nombre);
  const cuerpo = (traduccion.Cuerpo as string).replaceAll('{nombre}', opts.nombre);
  const cuerpoHtml = cuerpo
    .split('\n\n')
    .map((parrafo) => `<p>${parrafo.replaceAll('\n', '<br>')}</p>`)
    .join('');

  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: comunicacion.Remitente ?? 'TanApp <no-reply@tanapp.es>',
      to: [opts.email],
      subject: asunto,
      html: cuerpoHtml,
    }),
  });

  if (!resp.ok) {
    const errBody = await resp.json().catch(() => null);
    console.error('enviar-push-baja: fallo enviando email por Resend', errBody);
    return { error: errBody ?? `HTTP ${resp.status}` };
  }
  return { enviado: true };
}

// ---------------------------------------------------------------------
// Push a los administradores (igual que antes).
// ---------------------------------------------------------------------
async function enviarPushAdmins(
  // deno-lint-ignore no-explicit-any
  adminClient: any,
  opts: {
    nombreBaja: string;
    rol: string;
    idSistemaUsuario: string;
    // deno-lint-ignore no-explicit-any
    codigoPorIdioma: Map<any, any>;
  },
): Promise<unknown> {
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
    console.error('enviar-push-baja: fallo consultando administradores', adminsError);
    return { error: 'No se pudieron consultar los administradores' };
  }

  const destinatarios = (admins ?? []).filter((u: {
    NotificacionesPushActivas: boolean;
    TSistemaUsuariosRoles: { TSistemaRoles: { Codigo: string } | null }[];
  }) =>
    u.NotificacionesPushActivas &&
    (u.TSistemaUsuariosRoles ?? []).some((r) => r.TSistemaRoles?.Codigo === 'ADMIN')
  );
  if (destinatarios.length === 0) {
    console.log('enviar-push-baja: omitido, ningún admin con push activado');
    return { omitido: 'ningún admin con push activado' };
  }

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

    const esGallego = opts.codigoPorIdioma.get(admin.IdSistemaIdiomaPreferido) === 'GL';
    const esCliente = opts.rol === 'CLIENTE';
    const titulo = esGallego ? 'Baixa de conta' : 'Baja de cuenta';
    const cuerpo = esGallego
      ? `${opts.nombreBaja} (${esCliente ? 'cliente' : 'usuario'}) deuse de baixa.`
      : `${opts.nombreBaja} (${esCliente ? 'cliente' : 'usuario'}) se ha dado de baja.`;

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
            data: { idSistemaUsuario: opts.idSistemaUsuario },
          },
        }),
      });

      if (!resp.ok) {
        const errBody = await resp.json().catch(() => null);
        const errorStatus = errBody?.error?.status;
        if (errorStatus === 'UNREGISTERED' || errorStatus === 'NOT_FOUND' || errorStatus === 'INVALID_ARGUMENT') {
          await adminClient.from('TSistemaDispositivosPush').delete().eq('Token', token);
        } else {
          console.error('enviar-push-baja: fallo enviando push', errBody);
        }
        continue;
      }
      enviados++;
    }
  }

  return { enviados, total };
}
