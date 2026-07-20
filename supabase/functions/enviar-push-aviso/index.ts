// Edge Function: enviar-push-aviso
//
// Envía la notificación push de una publicación nueva a un seguidor concreto. NO la llama la
// app Flutter: la dispara un Database Webhook configurado en Supabase Studio sobre
// INSERT en "TSistemaAvisos" (esa fila ya la crea el trigger FSistemaCrearAvisosPublicacion
// de la migración 024, en la misma transacción que la publicación, así que el aviso en la
// app nunca depende de que este envío funcione).
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: enviar-push-aviso
//   3. Pega este archivo como index.ts y despliega.
//   4. Secretos -> añadir "FIREBASE_SERVICE_ACCOUNT_KEY" con el JSON completo de la clave de
//      cuenta de servicio de Firebase (Firebase Console -> Configuración del proyecto ->
//      Cuentas de servicio -> Generar nueva clave privada), como una sola línea.
//      Añadir también "WEBHOOK_SHARED_SECRET" con cualquier cadena larga que tú elijas
//      (invéntatela, no tiene que venir de ningún sitio en concreto).
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente.
//   5. Database -> Webhooks -> Create a new hook: tabla "TSistemaAvisos", evento INSERT,
//      tipo "Supabase Edge Functions", función "enviar-push-aviso". NO toques la cabecera
//      "Authorization" que ya viene puesta por defecto (Supabase la necesita para su propia
//      autenticación de plataforma y no deja fijar ahí un valor distinto). En vez de eso,
//      añade una cabecera NUEVA: "X-Webhook-Secret: <el mismo valor que WEBHOOK_SHARED_SECRET>"
//      — así se verifica abajo que la petición viene realmente del webhook y no de cualquiera
//      que adivine la URL pública de la función.

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
    // Red de seguridad: que quede el motivo real en los logs de la función en vez de un 500
    // sin cuerpo (el webhook no muestra nada al usuario, así que esto es lo único que ayuda
    // a diagnosticar un fallo de envío).
    console.error('enviar-push-aviso: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // Solo el propio Database Webhook (configurado con esta misma clave en su propia cabecera
  // "X-Webhook-Secret") puede invocar esta función; evita que alguien con la URL pública mande
  // avisos falsos. No se usa "Authorization" porque esa cabecera la gestiona Supabase para su
  // propia autenticación de plataforma y no se puede fijar a un valor propio.
  const secretoRecibido = req.headers.get('X-Webhook-Secret');
  const secretoEsperado = Deno.env.get('WEBHOOK_SHARED_SECRET');
  if (!secretoEsperado || secretoRecibido !== secretoEsperado) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }

  const payload = await req.json();
  const aviso = payload?.record;
  if (!aviso?.IdSistemaUsuario || !aviso?.IdClientePublicacion) {
    return jsonResponse({ error: 'Payload de webhook inesperado' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: destinatario } = await adminClient
    .from('TSistemaUsuarios')
    .select('NotificacionesPushActivas')
    .eq('IdSistemaUsuario', aviso.IdSistemaUsuario)
    .maybeSingle();
  if (!destinatario?.NotificacionesPushActivas) {
    console.log('enviar-push-aviso: omitido, usuario sin notificaciones push activadas', aviso.IdSistemaUsuario);
    return jsonResponse({ omitido: 'usuario sin notificaciones push activadas' });
  }

  const { data: dispositivos } = await adminClient
    .from('TSistemaDispositivosPush')
    .select('Token')
    .eq('IdSistemaUsuario', aviso.IdSistemaUsuario);
  if (!dispositivos || dispositivos.length === 0) {
    console.log('enviar-push-aviso: omitido, usuario sin dispositivos registrados', aviso.IdSistemaUsuario);
    return jsonResponse({ omitido: 'usuario sin dispositivos registrados' });
  }

  // Solo se necesita el nombre del cliente/sede para el texto de la notificación — nunca el
  // nombre del fallecido ni ningún otro dato de la publicación, para no filtrar información
  // por la bandeja de notificaciones del sistema (visible con el móvil bloqueado, etc.).
  const { data: publicacion, error: publicacionError } = await adminClient
    .from('TClientePublicaciones')
    .select('TClienteSedes(IdClienteSede, TSistemaUsuarios(Nombre))')
    .eq('IdClientePublicacion', aviso.IdClientePublicacion)
    .maybeSingle();
  if (publicacionError || !publicacion) {
    return jsonResponse({ error: 'Publicación no encontrada' }, 404);
  }
  const sede = publicacion.TClienteSedes as unknown as {
    IdClienteSede: string;
    TSistemaUsuarios: { Nombre: string } | null;
  };
  const nombreCliente = sede?.TSistemaUsuarios?.Nombre ?? '';

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
              title: `${nombreCliente} fixo unha nova publicación.`,
            },
            data: {
              idClienteSede: sede?.IdClienteSede ?? '',
              idClientePublicacion: aviso.IdClientePublicacion,
            },
          },
        }),
      });

      if (!resp.ok) {
        const errBody = await resp.json().catch(() => null);
        const errorStatus = errBody?.error?.status;
        // Token de un dispositivo que ya no existe (app desinstalada, token caducado): se
        // borra para no reintentar en vano en próximas publicaciones.
        if (errorStatus === 'UNREGISTERED' || errorStatus === 'NOT_FOUND' || errorStatus === 'INVALID_ARGUMENT') {
          await adminClient.from('TSistemaDispositivosPush').delete().eq('Token', token);
        } else {
          console.error('enviar-push-aviso: fallo enviando push', errBody);
        }
        return { token, ok: false };
      }
      return { token, ok: true };
    }),
  );

  const enviados = resultados.filter((r) => r.ok).length;
  console.log('enviar-push-aviso: resultado', { enviados, total: resultados.length });
  return jsonResponse({ enviados, total: resultados.length });
}
