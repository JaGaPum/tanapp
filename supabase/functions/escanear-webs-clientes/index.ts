// Edge Function: escanear-webs-clientes
//
// Rastrea la web de cada cliente que haya autorizado la importación automática
// ("TClienteImportacionWeb", migración 027) y le pide a Claude que extraiga las esquelas que
// encuentre, en el mismo formato estructurado que ya usa el formulario manual de publicación.
// Los resultados caen en "TClientePublicacionesPropuestas" (migración 028) en estado
// PENDIENTE: NUNCA se publican solos, el cliente los revisa y publica él mismo desde la app.
//
// NO la llama la app Flutter: la dispara un cron diario (pg_cron + pg_net, ver el bloque
// comentado al final de db/028_propuestas_publicaciones.sql), no un Database Webhook, así que
// aquí también hace falta una cabecera propia para autenticar la llamada.
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

import { createClient } from 'jsr:@supabase/supabase-js@2';
import Anthropic from 'npm:@anthropic-ai/sdk@0.32.1';

// Algunas webs traen bastante HTML (menús, cabecera, scripts) antes de llegar al listado real
// de esquelas: un límite bajo cortaba el texto justo antes de esa parte. 150 000 caracteres cubre
// páginas bastante grandes con margen, a coste todavía bajo por llamada.
const MAX_CARACTERES_PAGINA = 150000;

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
    console.error('escanear-webs-clientes: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  // Solo el propio cron (configurado con esta misma clave en su cabecera "X-Cron-Secret")
  // puede invocar esta función; evita que alguien con la URL pública dispare rastreos falsos.
  const secretoRecibido = req.headers.get('X-Cron-Secret');
  const secretoEsperado = Deno.env.get('CRON_SHARED_SECRET');
  if (!secretoEsperado || secretoRecibido !== secretoEsperado) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });

  const { data: clientes, error: clientesError } = await adminClient
    .from('TClienteImportacionWeb')
    .select('IdSistemaUsuario, Url')
    .eq('Activo', true);
  if (clientesError) {
    console.error('escanear-webs-clientes: error listando clientes activos', clientesError);
    return jsonResponse({ error: 'No se pudo listar clientes activos' }, 500);
  }

  const resultados = [];
  for (const cliente of clientes ?? []) {
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
