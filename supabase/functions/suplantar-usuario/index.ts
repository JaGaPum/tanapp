// Edge Function: suplantar-usuario
//
// Intercambia la sesión actual por la de otro usuario, sin conocer su contraseña. Tiene DOS usos:
//
//   1. Un administrador "inicia sesión como" otro usuario (cliente o usuario ordinario), para
//      depurar una incidencia viendo la app tal cual la ve él. Nunca deja suplantar a otro
//      administrador (evita escalada de privilegios), y cada suplantación queda registrada en
//      "TSistemaSuplantacionesLog" (046) para poder auditarla después.
//   2. Un CLIENTE entra en su propia cuenta personal USUARIO_ORDINARIO, vinculada a su cuenta de
//      negocio (063), para seguir clientes/zonas y dejar condolencias como cualquier otra
//      persona. Aquí no hace falta ser ADMIN: basta con que el objetivo sea exactamente la cuenta
//      que la migración 063 tiene enlazada como "IdSistemaUsuarioOrdinarioVinculado" del propio
//      solicitante. Este caso no se audita en "TSistemaSuplantacionesLog" (no es una suplantación
//      de otra persona, es la propia cuenta del solicitante).
//
// Devuelve un "token_hash" de tipo magiclink (vía la API de administración de Supabase Auth,
// "generateLink") que la app intercambia por una sesión real con "auth.verifyOTP" — nunca se
// manda ningún correo, el token va directo en la respuesta a quien ya ha demostrado ser ADMIN o
// dueño de la cuenta vinculada.
//
// Se invoca desde la propia app (ficha de usuario, botón "Suplantar usuario"; o desde Ajustes,
// botón "Entrar en tu cuenta personal"), con la sesión normal de quien la pulsa.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: suplantar-usuario
//   3. Pega este archivo como index.ts y despliega.
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente; no
//      hace falta ningún secreto adicional.
//   4. Aplicar antes las migraciones 046 y 063.
//
// IMPORTANTE: se llama desde un navegador (Flutter Web), así que hace falta responder
// a la petición de verificación previa CORS (OPTIONS) e incluir las cabeceras CORS en
// TODAS las respuestas; si no, el navegador bloquea la respuesta antes de que la app la
// vea y aparece como "Failed to fetch" sin más detalle.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

// Mismo mecanismo que el resto de Edge Functions de la app: la pasarela de Supabase ya valida
// el JWT antes de que esta función se ejecute, así que basta con leer el "sub" del token.
function extraerAuthUserId(authHeader: string | null): string | null {
  if (!authHeader?.startsWith('Bearer ')) return null;
  const token = authHeader.slice('Bearer '.length);
  const partes = token.split('.');
  if (partes.length !== 3) return null;
  try {
    const payload = JSON.parse(atob(partes[1].replace(/-/g, '+').replace(/_/g, '/')));
    return typeof payload.sub === 'string' ? payload.sub : null;
  } catch {
    return null;
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    return await handle(req);
  } catch (e) {
    console.error('suplantar-usuario: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const body = await req.json().catch(() => null);
  const idSistemaUsuarioObjetivo = body?.idSistemaUsuarioObjetivo;
  if (typeof idSistemaUsuarioObjetivo !== 'string' || idSistemaUsuarioObjetivo.length === 0) {
    return jsonResponse({ error: 'Falta el usuario a suplantar' }, 400);
  }

  const authUserId = extraerAuthUserId(req.headers.get('Authorization'));
  if (!authUserId) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // "TSistemaUsuariosRoles" tiene más de una FK hacia "TSistemaUsuarios" (la relación en sí más
  // las de auditoría IdSistemaUsuarioAlta/Modificacion), así que PostgREST no puede resolver el
  // embed sin indicarle cuál usar (mismo motivo que en usuarios_repository.dart, _perfilSelect).
  const rolesEmbed =
    'TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario(TSistemaRoles(Codigo))';

  const { data: solicitante, error: solicitanteError } = await adminClient
    .from('TSistemaUsuarios')
    .select(`IdSistemaUsuario, IdSistemaUsuarioOrdinarioVinculado, ${rolesEmbed}`)
    .eq('IdAuthSupabase', authUserId)
    .maybeSingle();
  if (solicitanteError || !solicitante) {
    console.error('suplantar-usuario: fallo consultando al solicitante', solicitanteError);
    return jsonResponse({ error: 'No autorizado' }, 401);
  }
  const esAdmin = (
    (solicitante.TSistemaUsuariosRoles ?? []) as { TSistemaRoles: { Codigo: string } | null }[]
  ).some((r) => r.TSistemaRoles?.Codigo === 'ADMIN');
  // Caso 2 del encabezado: no es un ADMIN suplantando a otro, es el propio cliente entrando en
  // su cuenta personal ya enlazada (063) — no hace falta ningún rol especial para esto.
  const esCambioACuentaPropia =
    !esAdmin &&
    solicitante.IdSistemaUsuarioOrdinarioVinculado != null &&
    idSistemaUsuarioObjetivo === solicitante.IdSistemaUsuarioOrdinarioVinculado;
  if (!esAdmin && !esCambioACuentaPropia) {
    return jsonResponse(
      { error: 'Solo un administrador puede suplantar a otro usuario' },
      403,
    );
  }

  if (idSistemaUsuarioObjetivo === solicitante.IdSistemaUsuario) {
    return jsonResponse({ error: 'No puedes suplantarte a ti mismo' }, 400);
  }

  const { data: objetivo, error: objetivoError } = await adminClient
    .from('TSistemaUsuarios')
    .select(`IdSistemaUsuario, Email, ${rolesEmbed}`)
    .eq('IdSistemaUsuario', idSistemaUsuarioObjetivo)
    .maybeSingle();
  if (objetivoError || !objetivo) {
    console.error('suplantar-usuario: fallo consultando al objetivo', objetivoError);
    return jsonResponse({ error: 'Usuario no encontrado' }, 404);
  }
  if (esAdmin) {
    const objetivoEsAdmin = (
      (objetivo.TSistemaUsuariosRoles ?? []) as { TSistemaRoles: { Codigo: string } | null }[]
    ).some((r) => r.TSistemaRoles?.Codigo === 'ADMIN');
    if (objetivoEsAdmin) {
      return jsonResponse({ error: 'No se puede suplantar a otro administrador' }, 403);
    }
  }

  const { data: link, error: linkError } = await adminClient.auth.admin.generateLink({
    type: 'magiclink',
    email: objetivo.Email,
  });
  if (linkError || !link?.properties?.hashed_token) {
    console.error('suplantar-usuario: fallo generando el enlace', linkError);
    return jsonResponse({ error: 'No se pudo generar el acceso' }, 500);
  }

  if (esAdmin) {
    const { error: logError } = await adminClient.from('TSistemaSuplantacionesLog').insert({
      IdSistemaUsuarioAdmin: solicitante.IdSistemaUsuario,
      IdSistemaUsuarioObjetivo: objetivo.IdSistemaUsuario,
    });
    // No crítico: si falla el registro de auditoría, no debe impedir la suplantación en sí, pero
    // sí queda en los logs de la función.
    if (logError) console.error('suplantar-usuario: no se pudo registrar la auditoría', logError);
  }

  return jsonResponse({ tokenHash: link.properties.hashed_token });
}
