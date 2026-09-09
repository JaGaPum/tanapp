// Edge Function: escanear-webs-clientes
//
// Rastrea la web de cada cliente que haya autorizado la importación automática
// ("TClienteImportacionWeb", migración 027) y le pide a Claude que extraiga las esquelas que
// encuentre, en el mismo formato estructurado que ya usa el formulario manual de publicación.
// Los resultados caen en "TClientePublicacionesPropuestas" (migración 028) en estado
// PENDIENTE: NUNCA se publican solos, el cliente los revisa y publica él mismo desde la app.
//
// Se puede invocar de dos formas:
//   1. El cron diario (pg_cron + pg_net, ver el bloque comentado al final de
//      db/028_propuestas_publicaciones.sql), con la cabecera "X-Cron-Secret": rastrea TODOS
//      los clientes activos.
//   2. La propia app Flutter (botón "Ejecutar ahora" en Propuestas), con la sesión normal del
//      cliente logueado (sin "X-Cron-Secret"): rastrea SOLO la web de ese cliente, y solo si
//      la tiene activa. La pasarela de Supabase ya valida el JWT antes de que esta función se
//      ejecute, así que basta con leer el "sub" del token para saber quién llama, sin
//      necesidad de volver a verificarlo.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: escanear-webs-clientes
//   3. Pega este archivo como index.ts y despliega.
//   4. Secretos -> añadir "ANTHROPIC_API_KEY" (clave de la API de Anthropic) y
//      "CRON_SHARED_SECRET" (cadena larga que te inventes).
//      SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta Supabase automáticamente.
//   5. Rellena y ejecuta el bloque "cron.schedule" comentado al final de
//      db/028_propuestas_publicaciones.sql (con la URL real del proyecto y el mismo
//      CRON_SHARED_SECRET) para que se dispare sola una vez al día.
//
// IMPORTANTE: la vía 2 (botón "Ejecutar ahora") se llama desde un navegador (Flutter Web), así
// que hace falta responder a la petición de verificación previa CORS (OPTIONS) e incluir las
// cabeceras CORS en TODAS las respuestas; si no, el navegador bloquea la petición entera antes
// de que llegue a mandarse. El cron (vía 1) no pasa por un navegador, así que no le afecta.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import Anthropic from 'npm:@anthropic-ai/sdk@0.32.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Algunas webs traen bastante HTML (menús, cabecera, scripts) antes de llegar al listado real
// de esquelas: un límite bajo cortaba el texto justo antes de esa parte. 150 000 caracteres cubre
// páginas bastante grandes con margen, a coste todavía bajo por llamada.
const MAX_CARACTERES_PAGINA = 150000;

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
    console.error('escanear-webs-clientes: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

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

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });

  // Interruptor global (migración 030, editable desde Configuración > IA en la app): si está
  // desactivado no se procesa a nadie, ni por cron ni a petición de un cliente concreto, aunque
  // tenga su propia importación activa.
  const { data: configGlobal, error: configGlobalError } = await adminClient
    .from('TConfiguracionGlobal')
    .select('ImportacionWebIaActiva')
    .maybeSingle();
  if (configGlobalError) {
    console.error('escanear-webs-clientes: error leyendo configuración global', configGlobalError);
    return jsonResponse({ error: 'No se pudo comprobar la configuración global' }, 500);
  }
  if (!configGlobal?.ImportacionWebIaActiva) {
    return jsonResponse({ error: 'La importación de esquelas con IA está desactivada' }, 403);
  }

  const secretoRecibido = req.headers.get('X-Cron-Secret');
  const secretoEsperado = Deno.env.get('CRON_SHARED_SECRET');
  const esCron = !!secretoEsperado && secretoRecibido === secretoEsperado;

  let clientes: { IdSistemaUsuario: string; Url: string }[];
  if (esCron) {
    const { data, error } = await adminClient
      .from('TClienteImportacionWeb')
      .select('IdSistemaUsuario, Url')
      .eq('Activo', true);
    if (error) {
      console.error('escanear-webs-clientes: error listando clientes activos', error);
      return jsonResponse({ error: 'No se pudo listar clientes activos' }, 500);
    }
    clientes = data ?? [];
  } else {
    // Llamada de la app: solo se rastrea la web del propio cliente que la pide (nunca la de
    // otros), y solo si la tiene activa.
    const authUserId = extraerAuthUserId(req.headers.get('Authorization'));
    if (!authUserId) {
      return jsonResponse({ error: 'No autorizado' }, 401);
    }
    const { data: usuario, error: usuarioError } = await adminClient
      .from('TSistemaUsuarios')
      .select('IdSistemaUsuario')
      .eq('IdAuthSupabase', authUserId)
      .maybeSingle();
    if (usuarioError || !usuario) {
      return jsonResponse({ error: 'No autorizado' }, 401);
    }
    const { data: config, error: configError } = await adminClient
      .from('TClienteImportacionWeb')
      .select('IdSistemaUsuario, Url')
      .eq('IdSistemaUsuario', usuario.IdSistemaUsuario)
      .eq('Activo', true)
      .maybeSingle();
    if (configError || !config) {
      return jsonResponse({ error: 'No tienes la importación automática activa' }, 400);
    }
    clientes = [config];
  }

  const resultados = [];
  for (const cliente of clientes) {
    resultados.push(await procesarCliente(adminClient, anthropic, cliente.IdSistemaUsuario, cliente.Url));
  }

  console.log('escanear-webs-clientes: resultado', resultados);
  return jsonResponse({ resultados });
}

async function procesarCliente(
  adminClient: ReturnType<typeof createClient>,
  anthropic: Anthropic,
  idSistemaUsuario: string,
  url: string,
) {
  try {
    const paginaResp = await fetch(url);
    if (!paginaResp.ok) {
      return { idSistemaUsuario, url, error: `No se pudo descargar la página (${paginaResp.status})` };
    }
    const textoPagina = (await paginaResp.text()).slice(0, MAX_CARACTERES_PAGINA);

    const esquelas = await extraerEsquelas(anthropic, textoPagina);
    if (esquelas.length === 0) {
      return { idSistemaUsuario, url, encontradas: 0, nuevas: 0 };
    }

    const filas = await Promise.all(
      esquelas.map(async (esquela) => ({
        IdSistemaUsuario: idSistemaUsuario,
        NombreFallecido: esquela.nombreFallecido,
        FechaFallecimiento: esquela.fechaFallecimiento ?? null,
        Edad: esquela.edad ?? null,
        FechaFuneral: esquela.fechaFuneral ?? null,
        HoraFuneral: esquela.horaFuneral ?? null,
        Iglesia: esquela.iglesia ?? null,
        Lugar: esquela.lugar ?? null,
        CapillaArdiente: esquela.capillaArdiente ?? null,
        Sala: esquela.sala ?? null,
        Observaciones: esquela.observaciones ?? null,
        UrlOrigen: url,
        Fingerprint: await calcularFingerprint(esquela.nombreFallecido, esquela.fechaFallecimiento ?? null),
      })),
    );

    const { data: insertadas, error: insertError } = await adminClient
      .from('TClientePublicacionesPropuestas')
      .upsert(filas, { onConflict: 'IdSistemaUsuario,Fingerprint', ignoreDuplicates: true })
      .select('IdClientePublicacionPropuesta');
    if (insertError) {
      console.error('escanear-webs-clientes: error insertando propuestas', idSistemaUsuario, insertError);
      return { idSistemaUsuario, url, error: 'No se pudieron guardar las propuestas' };
    }

    return { idSistemaUsuario, url, encontradas: esquelas.length, nuevas: insertadas?.length ?? 0 };
  } catch (e) {
    console.error('escanear-webs-clientes: fallo procesando cliente', idSistemaUsuario, url, e);
    return { idSistemaUsuario, url, error: e instanceof Error ? e.message : String(e) };
  }
}

interface EsquelaExtraida {
  nombreFallecido: string;
  fechaFallecimiento?: string | null;
  edad?: number | null;
  fechaFuneral?: string | null;
  horaFuneral?: string | null;
  iglesia?: string | null;
  lugar?: string | null;
  capillaArdiente?: string | null;
  sala?: string | null;
  observaciones?: string | null;
}

const TOOL_REPORTAR_ESQUELAS = {
  name: 'reportar_esquelas',
  description:
    'Informa de las esquelas o avisos de defunción encontrados en el texto de la página, con sus datos estructurados.',
  input_schema: {
    type: 'object' as const,
    properties: {
      esquelas: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            nombreFallecido: { type: 'string', description: 'Nombre completo del fallecido' },
            fechaFallecimiento: { type: ['string', 'null'], description: 'Formato YYYY-MM-DD, o null si no consta' },
            edad: { type: ['integer', 'null'] },
            fechaFuneral: { type: ['string', 'null'], description: 'Formato YYYY-MM-DD, o null si no consta' },
            horaFuneral: { type: ['string', 'null'], description: 'Formato HH:mm (24h), o null si no consta' },
            iglesia: { type: ['string', 'null'] },
            lugar: { type: ['string', 'null'] },
            capillaArdiente: { type: ['string', 'null'], description: 'Tanatorio o capilla ardiente' },
            sala: { type: ['string', 'null'] },
            observaciones: { type: ['string', 'null'] },
          },
          required: ['nombreFallecido'],
        },
      },
    },
    required: ['esquelas'],
  },
};

async function extraerEsquelas(anthropic: Anthropic, textoPagina: string): Promise<EsquelaExtraida[]> {
  const mensaje = await anthropic.messages.create({
    model: 'claude-opus-4-8',
    max_tokens: 4096,
    tools: [TOOL_REPORTAR_ESQUELAS],
    tool_choice: { type: 'tool', name: 'reportar_esquelas' },
    messages: [
      {
        role: 'user',
        content:
          'El siguiente texto es el contenido de una página web de una funeraria/tanatorio/parroquia gallega. ' +
          'Extrae todas las esquelas o avisos de defunción que encuentres, con sus datos estructurados. ' +
          'No incluyas datos personales de familiares (nombres, teléfonos, direcciones) que puedan aparecer en el ' +
          'texto; solo el nombre del fallecido y la información relevante para el público (fechas, iglesia, ' +
          'lugar, tanatorio/capilla ardiente, sala). Si no hay ninguna esquela en el texto, informa una lista ' +
          `vacía.\n\n---\n\n${textoPagina}`,
      },
    ],
  });

  const toolUse = mensaje.content.find(
    (bloque): bloque is Anthropic.ToolUseBlock => bloque.type === 'tool_use',
  );
  const esquelas = (toolUse?.input as { esquelas?: EsquelaExtraida[] } | undefined)?.esquelas ?? [];
  return esquelas.filter((e) => e.nombreFallecido?.trim());
}

async function calcularFingerprint(nombre: string, fecha: string | null): Promise<string> {
  const texto = `${nombre.trim().toLowerCase()}|${fecha ?? ''}`;
  const datos = new TextEncoder().encode(texto);
  const hashBuffer = await crypto.subtle.digest('SHA-256', datos);
  return Array.from(new Uint8Array(hashBuffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
