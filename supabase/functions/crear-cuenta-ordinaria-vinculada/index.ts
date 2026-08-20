// Edge Function: crear-cuenta-ordinaria-vinculada
//
// Un CLIENTE (funeraria/tanatorio) puede tener su propia cuenta USUARIO_ORDINARIO, separada de
// su cuenta de negocio, para seguir clientes/zonas y dejar condolencias como cualquier otra
// persona (sin mezclar esa navegación con la suya, ver 052 y 063). Esta función crea esa cuenta
// la primera vez que hace falta (con un email sintético, sin contraseña ni login propios: solo
// se entra en ella intercambiando sesión, igual que la suplantación de admin) y, si ya existe,
// simplemente devuelve su id — así el botón "Entrar en tu cuenta personal" siempre puede
// llamarla sin más.
//
// El propio "cambio de sesión" a esta cuenta lo hace la Edge Function "suplantar-usuario"
// (ampliada para permitir también este caso, no solo a un ADMIN).
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: crear-cuenta-ordinaria-vinculada
//   3. Pega este archivo como index.ts y despliega.
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente; no
//      hace falta ningún secreto adicional.
//   4. Aplicar antes la migración 063.
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
    console.error('crear-cuenta-ordinaria-vinculada: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
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

  const rolesEmbed =
    'TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario(TSistemaRoles(Codigo))';

  const { data: cliente, error: clienteError } = await adminClient
    .from('TSistemaUsuarios')
    .select(
      `IdSistemaUsuario, Nombre, Apellido1, Telefono, Concello, Provincia, ` +
        `IdSistemaUsuarioOrdinarioVinculado, ${rolesEmbed}`,
    )
    .eq('IdAuthSupabase', authUserId)
    .maybeSingle();
  if (clienteError || !cliente) {
    console.error('crear-cuenta-ordinaria-vinculada: fallo consultando al solicitante', clienteError);
    return jsonResponse({ error: 'No autorizado' }, 401);
  }
  const esCliente = (
    (cliente.TSistemaUsuariosRoles ?? []) as { TSistemaRoles: { Codigo: string } | null }[]
  ).some((r) => r.TSistemaRoles?.Codigo === 'CLIENTE');
  if (!esCliente) {
    return jsonResponse({ error: 'Solo una cuenta de cliente puede tener una cuenta personal vinculada' }, 403);
  }

  // Ya existe: no se crea otra, se devuelve la que hay.
  if (cliente.IdSistemaUsuarioOrdinarioVinculado) {
    return jsonResponse({
      idSistemaUsuarioOrdinarioVinculado: cliente.IdSistemaUsuarioOrdinarioVinculado,
    });
  }

  // Email sintético (dominio no enrutable a propósito): nunca se manda correo a esta cuenta, se
  // entra en ella solo por intercambio de sesión (ver suplantar-usuario), así que no hace falta
  // que sea una dirección real.
  const emailSintetico = `ordinario-${crypto.randomUUID()}@tanapp.internal`;

  const { data: created, error: createError } = await adminClient.auth.admin.createUser({
    email: emailSintetico,
    email_confirm: true,
    user_metadata: {
      nombre: cliente.Apellido1 || cliente.Nombre,
      telefono: cliente.Telefono,
      concello: cliente.Concello,
      provincia: cliente.Provincia,
    },
  });
  if (createError || !created.user) {
    console.error('crear-cuenta-ordinaria-vinculada: fallo creando el usuario', createError);
    return jsonResponse({ error: createError?.message ?? 'No se pudo crear la cuenta' }, 500);
  }

  // El trigger FSistemaHandleNewAuthUser ya creó la fila en TSistemaUsuarios y le asignó
  // USUARIO_ORDINARIO (lo hace con cualquier alta en auth.users): es justo el rol que hace
  // falta aquí, así que no hay que tocar nada más.
  const { data: nuevoPerfil, error: nuevoPerfilError } = await adminClient
    .from('TSistemaUsuarios')
    .select('IdSistemaUsuario')
    .eq('IdAuthSupabase', created.user.id)
    .maybeSingle();
  if (nuevoPerfilError || !nuevoPerfil) {
    console.error('crear-cuenta-ordinaria-vinculada: no se encontró el perfil recién creado', nuevoPerfilError);
    return jsonResponse({ error: 'No se pudo completar la creación de la cuenta' }, 500);
  }

  const { error: linkError } = await adminClient
    .from('TSistemaUsuarios')
    .update({ IdSistemaUsuarioOrdinarioVinculado: nuevoPerfil.IdSistemaUsuario })
    .eq('IdSistemaUsuario', cliente.IdSistemaUsuario);
  if (linkError) {
    console.error('crear-cuenta-ordinaria-vinculada: fallo enlazando la cuenta', linkError);
    return jsonResponse({ error: 'No se pudo enlazar la cuenta' }, 500);
  }

  return jsonResponse({ idSistemaUsuarioOrdinarioVinculado: nuevoPerfil.IdSistemaUsuario });
}
