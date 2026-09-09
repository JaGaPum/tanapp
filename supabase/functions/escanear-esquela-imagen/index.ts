// Edge Function: escanear-esquela-imagen
//
// Sustituye (cuando está activada) al OCR + motor de reglas local de "publicacion_escanear_
// screen.dart": recibe la foto de una esquela y le pide a Claude (con visión) que extraiga sus
// datos estructurados, en el mismo formato que ya usa el formulario manual de publicación.
// Nunca publica nada por su cuenta: la app siempre abre el formulario ya prellenado para que el
// cliente lo revise antes de confirmar, igual que hace hoy el escaneo con OCR.
//
// Se invoca desde la propia app (botón "Escanear" -> foto), con la sesión normal del cliente
// logueado. A diferencia de la primera versión, ahora sí necesita saber quién llama: además del
// interruptor global, hay un interruptor por usuario (042) que el administrador puede desactivar
// para un cliente concreto, y cada llamada real a Claude se registra (043) para el Dashboard de
// consumo de IA del administrador.
//
// Despliegue (sin CLI, desde el panel de Supabase):
//   1. Dashboard del proyecto -> Edge Functions -> "Deploy a new function".
//   2. Nombre: escanear-esquela-imagen
//   3. Pega este archivo como index.ts y despliega.
//   4. Secretos -> añadir "ANTHROPIC_API_KEY" si no está ya (la comparte con
//      "escanear-webs-clientes"). SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya los inyecta
//      Supabase automáticamente.
//   5. Aplicar antes las migraciones 041-043 y activar el interruptor global en la app, en
//      Configuración > IA.
//
// IMPORTANTE: también se llama desde un navegador (Flutter Web, pantalla de escanear), así que
// hace falta responder a la petición de verificación previa CORS (OPTIONS) e incluir las
// cabeceras CORS en TODAS las respuestas; si no, el navegador bloquea la petición entera antes
// de que llegue a mandarse -por eso, sin esto, un escaneo desde la web caía en silencio al OCR
// local (que tampoco funciona en web, al no tener ML Kit), sin que llegase a verse ni una
// invocación en los logs de esta función-.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import Anthropic from 'npm:@anthropic-ai/sdk@0.32.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Fotos de móvil ya comprimidas por la app (calidad 90 en image_picker) rondan 1-3 MB; 8 MB en
// base64 da margen de sobra sin arriesgarse a mandar una foto sin comprimir por error.
const MAX_BYTES_IMAGEN_BASE64 = 8 * 1024 * 1024;

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

// Mismo mecanismo que "escanear-webs-clientes": la pasarela de Supabase ya valida el JWT antes
// de que esta función se ejecute, así que basta con leer el "sub" del token, sin verificarlo de
// nuevo aquí.
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
    console.error('escanear-esquela-imagen: error no controlado', e);
    return jsonResponse({ error: `Error interno: ${e instanceof Error ? e.message : e}` }, 500);
  }
});

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Método no permitido' }, 405);
  }

  const body = await req.json().catch(() => null);
  const imagenBase64 = body?.imagenBase64;
  const mimeType = typeof body?.mimeType === 'string' ? body.mimeType : 'image/jpeg';
  const idioma = body?.idioma === 'gl' ? 'gl' : 'es';
  if (typeof imagenBase64 !== 'string' || imagenBase64.length === 0) {
    return jsonResponse({ error: 'Falta la imagen' }, 400);
  }
  if (imagenBase64.length > MAX_BYTES_IMAGEN_BASE64) {
    return jsonResponse({ error: 'La imagen es demasiado grande' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Interruptor global (migración 041, editable desde Configuración > IA en la app): si está
  // desactivado, la app ni siquiera debería llamar a esta función (usa el OCR local), pero se
  // comprueba también aquí por si acaso.
  const { data: configGlobal, error: configGlobalError } = await adminClient
    .from('TConfiguracionGlobal')
    .select('EscaneoEsquelaIaActiva')
    .maybeSingle();
  if (configGlobalError) {
    console.error('escanear-esquela-imagen: error leyendo configuración global', configGlobalError);
    return jsonResponse({ error: 'No se pudo comprobar la configuración global' }, 500);
  }
  if (!configGlobal?.EscaneoEsquelaIaActiva) {
    return jsonResponse({ error: 'El escaneo de esquelas con IA está desactivado' }, 403);
  }

  const authUserId = extraerAuthUserId(req.headers.get('Authorization'));
  if (!authUserId) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }
  const { data: usuario, error: usuarioError } = await adminClient
    .from('TSistemaUsuarios')
    .select('IdSistemaUsuario, EscaneoEsquelaIaActiva')
    .eq('IdAuthSupabase', authUserId)
    .maybeSingle();
  if (usuarioError || !usuario) {
    return jsonResponse({ error: 'No autorizado' }, 401);
  }
  // Interruptor por usuario (migración 042, editable desde la ficha de usuario en el panel de
  // administración): el admin puede cortarle el acceso a un cliente concreto sin desactivarlo
  // para todos.
  if (!usuario.EscaneoEsquelaIaActiva) {
    return jsonResponse({ error: 'El escaneo de esquelas con IA está desactivado para este usuario' }, 403);
  }

  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });
  try {
    const { esquela, usage } = await extraerEsquela(anthropic, imagenBase64, mimeType, idioma);
    await registrarUso(adminClient, usuario.IdSistemaUsuario, true, usage);
    if (!esquela) {
      return jsonResponse({ error: 'No se ha reconocido ninguna esquela en la foto' }, 422);
    }
    return jsonResponse({ campos: esquela });
  } catch (e) {
    console.error('escanear-esquela-imagen: fallo extrayendo la esquela', e);
    await registrarUso(adminClient, usuario.IdSistemaUsuario, false, null);
    return jsonResponse({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
}

async function registrarUso(
  adminClient: ReturnType<typeof createClient>,
  idSistemaUsuario: string,
  exito: boolean,
  usage: { inputTokens: number; outputTokens: number } | null,
): Promise<void> {
  const { error } = await adminClient.from('TSistemaUsuarioEscaneoIaLog').insert({
    IdSistemaUsuario: idSistemaUsuario,
    Exito: exito,
    TokensEntrada: usage?.inputTokens ?? null,
    TokensSalida: usage?.outputTokens ?? null,
  });
  // No crítico: si falla el registro, no debe tumbar la respuesta al cliente.
  if (error) console.error('escanear-esquela-imagen: no se pudo registrar el uso', error);
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

const TOOL_REPORTAR_ESQUELA = {
  name: 'reportar_esquela',
  description: 'Informa de los datos estructurados de la esquela o aviso de defunción que aparece en la foto.',
  input_schema: {
    type: 'object' as const,
    properties: {
      nombreFallecido: {
        type: 'string',
        description: 'Nombre completo del fallecido, sin tratamientos honoríficos (Don, Doña, D., D.ª, El Señor, A Señora...) ni apodos.',
      },
      fechaFallecimiento: {
        type: ['string', 'null'],
        description:
          'Formato YYYY-MM-DD. Si el año no aparece junto a la fecha de fallecimiento, búscalo en otra parte del documento ' +
          '(p.ej. el pie con el lugar y la fecha de impresión). null si no consta ningún dato de fecha.',
      },
      edad: { type: ['integer', 'null'] },
      fechaFuneral: {
        type: ['string', 'null'],
        description:
          'Formato YYYY-MM-DD. Casi nunca viene como fecha explícita, sino como día de la semana ("el miércoles", ' +
          '"mañá mércores") o expresión relativa ("mañana", "hoy"): calcula la fecha real contando desde ' +
          'fechaFallecimiento como referencia (el funeral nunca es antes de la fecha de fallecimiento). ' +
          'null si no consta ninguna referencia.',
      },
      horaFuneral: { type: ['string', 'null'], description: 'Formato HH:mm en 24h. null si no consta.' },
      iglesia: { type: ['string', 'null'] },
      lugar: { type: ['string', 'null'], description: 'Localidad/parroquia donde se celebra el funeral o entierro.' },
      capillaArdiente: { type: ['string', 'null'], description: 'Tanatorio o capilla ardiente.' },
      sala: { type: ['string', 'null'] },
      observaciones: {
        type: ['string', 'null'],
        description:
          'Cualquier información relevante para el público que no encaje en los demás campos (p.ej. una misa de ' +
          'ánimas o un funeral posterior, con su propia fecha y hora). Nunca nombres, teléfonos, direcciones o ' +
          'parentescos de familiares.',
      },
    },
    required: ['nombreFallecido'],
  },
};

async function extraerEsquela(
  anthropic: Anthropic,
  imagenBase64: string,
  mimeType: string,
  idioma: 'es' | 'gl',
): Promise<{ esquela: EsquelaExtraida | null; usage: { inputTokens: number; outputTokens: number } }> {
  const idiomaTexto = idioma === 'gl' ? 'gallego' : 'castellano';
  const mensaje = await anthropic.messages.create({
    model: 'claude-sonnet-5',
    max_tokens: 2048,
    tools: [TOOL_REPORTAR_ESQUELA],
    tool_choice: { type: 'tool', name: 'reportar_esquela' },
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: { type: 'base64', media_type: mimeType as 'image/jpeg', data: imagenBase64 },
          },
          {
            type: 'text',
            text:
              'La imagen es la foto de una esquela o aviso de defunción gallego, en castellano o en gallego. ' +
              `Extrae sus datos con la herramienta "reportar_esquela". Escribe todo el contenido que extraigas ` +
              `(iglesia, lugar, observaciones...) en ${idiomaTexto}, tradúcelo si hace falta, sea cual sea el ` +
              'idioma en el que esté impresa la esquela; los nombres propios (persona, iglesia, lugar) se dejan ' +
              'como corresponda, sin forzar una traducción literal de un topónimo. ' +
              'No incluyas nombres, teléfonos, direcciones ni parentescos de familiares (hijos, hermanos, ' +
              'cónyuge, etc.): solo el nombre del fallecido y la información dirigida al público. ' +
              'Si la esquela es un aniversario, cabo de año o misa de ánimas de alguien fallecido hace tiempo (no ' +
              'un fallecimiento reciente), extrae igualmente los datos tal cual aparecen, sin filtrarla ni ' +
              'marcarla de forma especial. Si algún dato no se aprecia con claridad en la foto, deja ese campo en ' +
              'null en vez de inventarlo.',
          },
        ],
      },
    ],
  });

  const usage = { inputTokens: mensaje.usage.input_tokens, outputTokens: mensaje.usage.output_tokens };

  const toolUse = mensaje.content.find(
    (bloque): bloque is Anthropic.ToolUseBlock => bloque.type === 'tool_use',
  );
  const esquela = toolUse?.input as EsquelaExtraida | undefined;
  if (!esquela?.nombreFallecido?.trim()) return { esquela: null, usage };
  return { esquela, usage };
}
