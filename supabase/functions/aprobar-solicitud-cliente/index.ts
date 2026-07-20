// Edge Function: aprobar-solicitud-cliente
//
// Al aprobar una TClienteSolicitudes, crea la cuenta de Supabase Auth del cliente
// SIN contraseña: el cliente deberá usar "¿Olvidaste tu contraseña?" en el login para
// establecer la suya. Esto requiere el Admin API (service_role), que no se puede usar
// desde el cliente Flutter, de ahí la Edge Function.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: aprobar-solicitud-cliente
//   3. Pega este archivo como index.ts y despliega.
//   SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente,
//   no hace falta configurar nada más.
//
// La app Flutter la invoca con supabase.functions.invoke('aprobar-solicitud-cliente',
// body: {'idClientesSolicitud': id}) tras marcar la solicitud como APROBADA.
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

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    return await handle(req);
  } catch (e) {
    // Red de seguridad: si algo inesperado revienta, que se vea el motivo real en vez de
    // un 500 sin cuerpo (así el aviso en la app deja de ser genérico).
    console.error('aprobar-solicitud-cliente: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return jsonResponse({ error: 'No autenticado' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // Cliente con el JWT del que llama, solo para averiguar quién es y si es ADMIN.
  const callerClient = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: userData, error: userError } = await callerClient.auth.getUser();
  if (userError || !userData.user) {
    return jsonResponse({ error: `No autenticado: ${userError?.message ?? 'sin usuario'}` }, 401);
  }

  // Cliente con service_role: bypassa RLS, necesario para crear usuarios y leer/escribir
  // en TSistemaUsuarios/TSistemaUsuariosRoles/TClienteSolicitudes sin restricciones.
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: perfilCaller, error: perfilError } = await adminClient
    .from('TSistemaUsuarios')
    .select('IdSistemaUsuario, TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario(TSistemaRoles(Codigo))')
    .eq('IdAuthSupabase', userData.user.id)
    .maybeSingle();

  const esAdmin = !perfilError && perfilCaller?.TSistemaUsuariosRoles?.some(
    (r: { TSistemaRoles: { Codigo: string } | null }) => r.TSistemaRoles?.Codigo === 'ADMIN',
  );
  if (!esAdmin) {
    return jsonResponse({ error: 'No autorizado' }, 403);
  }

  const { idClientesSolicitud } = await req.json();
  if (!idClientesSolicitud) {
    return jsonResponse({ error: 'Falta idClientesSolicitud' }, 400);
  }

  const { data: solicitud, error: solicitudError } = await adminClient
    .from('TClienteSolicitudes')
    .select('*')
    .eq('IdClientesSolicitud', idClientesSolicitud)
    .single();
  if (solicitudError || !solicitud) {
    return jsonResponse({ error: 'Solicitud no encontrada' }, 404);
  }
  if (solicitud.IdSistemaUsuarioCliente) {
    return jsonResponse({ error: 'Esta solicitud ya tiene una cuenta de cliente creada' }, 409);
  }

  // Sin contraseña: el cliente entra por primera vez con "¿Olvidaste tu contraseña?".
  // Mapeo: la razón social hace de "Nombre" (identidad principal de la cuenta B2B) y la
  // persona de contacto de "Apellido1", ya que TSistemaUsuarios exige Apellido1.
  const { data: created, error: createError } = await adminClient.auth.admin.createUser({
    email: solicitud.EmailContacto,
    email_confirm: true,
    user_metadata: {
      nombre: solicitud.RazonSocial,
      apellido1: solicitud.NombreContacto,
      telefono: solicitud.TelefonoContacto,
      concello: solicitud.Localidad,
      provincia: solicitud.Provincia,
      direccion: solicitud.Direccion,
    },
  });
  if (createError || !created.user) {
    return jsonResponse({ error: createError?.message ?? 'No se pudo crear el usuario' }, 409);
  }

  // El trigger FSistemaHandleNewAuthUser ya creó la fila en TSistemaUsuarios y le asignó
  // USUARIO_ORDINARIO; aquí añadimos además el rol CLIENTE.
  const { data: nuevoPerfil } = await adminClient
    .from('TSistemaUsuarios')
    .select('IdSistemaUsuario')
    .eq('IdAuthSupabase', created.user.id)
    .maybeSingle();

  if (nuevoPerfil) {
    const { data: rolCliente } = await adminClient
      .from('TSistemaRoles')
      .select('IdSistemaRol')
      .eq('Codigo', 'CLIENTE')
      .maybeSingle();
    if (rolCliente) {
      await adminClient.from('TSistemaUsuariosRoles').insert({
        IdSistemaUsuario: nuevoPerfil.IdSistemaUsuario,
        IdSistemaRol: rolCliente.IdSistemaRol,
      });
    }

    // Enlaza la solicitud con el usuario creado, para no volver a ofrecer el botón de crear cuenta.
    await adminClient
      .from('TClienteSolicitudes')
      .update({ IdSistemaUsuarioCliente: nuevoPerfil.IdSistemaUsuario })
      .eq('IdClientesSolicitud', idClientesSolicitud);

    // Traslada al usuario el tipo de cliente que el ADMIN eligió al aprobar la solicitud.
    if (solicitud.IdConfiguracionClienteTipo) {
      await adminClient
        .from('TSistemaUsuarios')
        .update({ IdConfiguracionClienteTipo: solicitud.IdConfiguracionClienteTipo })
        .eq('IdSistemaUsuario', nuevoPerfil.IdSistemaUsuario);
    }

    // Da de alta la primera sede del cliente (la de la propia solicitud). Buscar/Seguindo/
    // "Cómo llegar" operan sobre sedes, no sobre el cliente directamente, así que sin esto
    // el cliente recién aprobado no aparecería en ningún resultado hasta que él mismo diera
    // de alta una sede a mano.
    if (solicitud.Direccion && solicitud.Provincia && solicitud.Localidad) {
      await adminClient.from('TClienteSedes').insert({
        IdSistemaUsuario: nuevoPerfil.IdSistemaUsuario,
        Codigo: 'Sede001',
        Nombre: 'Sede principal',
        Provincia: solicitud.Provincia,
        Concello: solicitud.Localidad,
        Direccion: solicitud.Direccion,
      });
    }
  }

  return jsonResponse({ idAuthSupabase: created.user.id });
}
