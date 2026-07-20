import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/text_format.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';

/// Quita acentos y pasa a minúsculas, para que la detección de palabras clave no dependa de que
/// el OCR haya reconocido bien las tildes (algo que falla a menudo).
String _normalizar(String texto) {
  const conAcento = 'áéíóúüñàèìòù';
  const sinAcento = 'aeiouunaeiou';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < conAcento.length; i++) {
    resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
  }
  return resultado;
}

/// Palabras que casi con seguridad solo aparecen en el párrafo de familiares de una esquela
/// (hijos, nietos, hermanos...), en castellano y gallego: cualquier bloque de texto que las
/// contenga se descarta del prellenado, para no arrastrar datos personales de familiares al
/// formulario.
const _palabrasFamiliares = {
  'hijo', 'hija', 'hijos', 'hijas',
  'fillo', 'filla', 'fillos', 'fillas',
  'nieto', 'nieta', 'nietos', 'nietas',
  'neto', 'neta', 'netos', 'netas',
  'hermano', 'hermana', 'hermanos', 'hermanas',
  'irman', 'irma', 'irmans',
  'sobrino', 'sobrina', 'sobrinos', 'sobrinas',
  'primo', 'prima', 'primos', 'primas',
  'curman', 'curma', 'curmans',
  'esposo', 'esposa', 'viudo', 'viuda',
  'padre', 'madre', 'padres',
  'pai', 'nai', 'pais',
  'ahijado', 'ahijada', 'cunado', 'cunada', 'yerno', 'nuera', 'politicos', 'politica',
};

/// Frases que solo aparecen en el texto importante de la esquela (fecha/edad, convocatoria del
/// funeral, capilla ardiente...), en castellano y gallego. Un bloque que las contenga se
/// conserva siempre, aunque también roce alguna palabra de la lista de familiares (p. ej. "su
/// esposa" dentro de la propia convocatoria).
const _anclasImportantes = [
  'fallecio', 'faleceu', 'falleceu', 'finou', 'morreu', 'murio',
  'ruegan', 'rogan', 'pregan',
  'capilla ardiente', 'capela ardente',
  'auxilios espirituales', 'auxilios espirituais',
  'complexo funerario', 'complejo funerario', 'tanatorio',
  'd.e.p', 'q.e.p.d',
];

bool _tieneAnclaImportante(String textoBloque) {
  final normalizado = _normalizar(textoBloque);
  return _anclasImportantes.any(normalizado.contains);
}

bool _esBloqueFamiliar(String textoBloque) {
  final normalizado = _normalizar(textoBloque);
  final palabras = normalizado.split(RegExp(r'[^a-z]+'));
  return palabras.any(_palabrasFamiliares.contains);
}

/// Frases que solo aparecen en el pie publicitario de la propia funeraria (que ya se ve por
/// otro lado en la publicación, como cliente/sede) o números sueltos que en realidad son una
/// filigrana del borde decorativo mal leída como texto: ruido que conviene descartar siempre.
const _frasesRuido = ['servicios de defuncion', 'todas las companias', 'www.'];

bool _esBloqueRuido(String textoBloque, {String? nombreCliente, String? telefonoCliente}) {
  final normalizado = _normalizar(textoBloque.trim());
  if (RegExp(r'^\d{1,3}\.?$').hasMatch(normalizado)) return true;
  if (_frasesRuido.any(normalizado.contains)) return true;

  // El nombre/teléfono propio del cliente que escanea (ya en su perfil) permite identificar con
  // precisión su propio pie publicitario, sin depender de una lista genérica de palabras.
  if (nombreCliente != null) {
    final nombreNormalizado = _normalizar(nombreCliente.trim());
    if (nombreNormalizado.length >= 4 && normalizado.contains(nombreNormalizado)) return true;
  }
  if (telefonoCliente != null) {
    final digitosTelefono = telefonoCliente.replaceAll(RegExp(r'\D'), '');
    if (digitosTelefono.length >= 6) {
      final digitosBloque = textoBloque.replaceAll(RegExp(r'\D'), '');
      if (digitosBloque.contains(digitosTelefono)) return true;
    }
  }
  return false;
}

/// Dentro de un mismo bloque, los saltos de línea que trae el OCR son solo el ajuste visual de
/// la línea impresa (el propio ML Kit ya separa los párrafos/apartados reales en bloques
/// distintos). Esto los convierte en texto corrido: une palabras partidas por guión de fin de
/// línea ("espiri-\ntuales" → "espirituales") y el resto de saltos los deja como espacio, para
/// que no queden palabras sueltas colgando en su propia línea.
String _limpiarBloque(String textoBloque) {
  var resultado = textoBloque.replaceAll(RegExp(r'-\n\s*'), '');
  resultado = resultado.replaceAll(RegExp(r'\s*\n\s*'), ' ');
  resultado = resultado.replaceAll(RegExp(r' {2,}'), ' ');
  return resultado.trim();
}

const _prefijosHonorificos = [
  'don ', 'doña ', 'dona ', 'd. ', 'dña. ', "d.ª ",
  'el señor ', 'la señora ', 'o señor ', 'a señora ',
];

String _limpiarNombre(String linea) {
  var resultado = linea.trim();
  // Bucle en vez de un solo intento: algunas esquelas encadenan dos honoríficos ("El señor Don
  // Fulano"), y hay que quitarlos todos, no solo el primero.
  var cambiado = true;
  while (cambiado) {
    cambiado = false;
    final minuscula = resultado.toLowerCase();
    for (final prefijo in _prefijosHonorificos) {
      if (minuscula.startsWith(prefijo)) {
        resultado = resultado.substring(prefijo.length).trim();
        cambiado = true;
        break;
      }
    }
  }
  return resultado;
}

/// Mes (nombre en castellano o gallego, sin tilde) → número de mes.
const _meses = {
  'enero': 1, 'xaneiro': 1,
  'febrero': 2, 'febreiro': 2,
  'marzo': 3,
  'abril': 4,
  'mayo': 5, 'maio': 5,
  'junio': 6, 'xuno': 6,
  'julio': 7, 'xullo': 7,
  'agosto': 8,
  'septiembre': 9, 'setiembre': 9, 'setembro': 9,
  'octubre': 10, 'outubro': 10,
  'noviembre': 11, 'novembro': 11,
  'diciembre': 12, 'decembro': 12,
};

/// Fecha de fallecimiento con el mes escrito en letra ("...o día 15 de xullo de 2026").
final _regexFechaFallecimiento = RegExp(
  r'(?:falleci[oó]|faleceu|falleceu|finou|morreu|muri[oó])[^\d]{0,20}(\d{1,2})\s+de\s+([a-zñ]+)\s+de\s+(\d{4})',
  caseSensitive: false,
);

/// Fallback cuando la fecha viene en formato numérico ("...falleció el día 15/07/2026") en vez
/// de con el mes escrito en letra.
final _regexFechaFallecimientoNumerica = RegExp(
  r'(?:falleci[oó]|faleceu|falleceu|finou|morreu|muri[oó])[^\d]{0,20}(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})',
  caseSensitive: false,
);

/// Edad con ancla explícita delante ("a los 82 años" / "aos 82 anos" / "ós 82 anos").
final _regexEdad = RegExp(r'(?:a\s+los|aos|[oó]s)\s+(\d{1,3})\s+a[nñ]os', caseSensitive: false);

/// Fallback más permisivo: la edad casi siempre aparece justo después de la fecha de
/// fallecimiento, como un número pegado a "años"/"anos" sin que el ancla previa se reconozca
/// siempre igual de bien (letra suelta del OCR, redacción distinta...).
final _regexEdadGenerica = RegExp(r'(\d{1,3})\s*a[nñ]os', caseSensitive: false);

/// Día de la semana (nombre en castellano o gallego, sin tilde) → `DateTime.weekday`.
const _diasSemana = {
  'lunes': DateTime.monday, 'luns': DateTime.monday,
  'martes': DateTime.tuesday,
  'miercoles': DateTime.wednesday, 'mercores': DateTime.wednesday,
  'jueves': DateTime.thursday, 'xoves': DateTime.thursday,
  'viernes': DateTime.friday, 'venres': DateTime.friday,
  'sabado': DateTime.saturday,
  'domingo': DateTime.sunday,
};

/// Solo el nombre del día de la semana (la esquela casi nunca da una fecha explícita para el
/// funeral, sino "O Xoves"/"El Jueves"): la fecha real se calcula a partir de este día más la
/// fecha de fallecimiento (ver `_proximoDiaSemana`).
final _regexDiaSemana = RegExp(
  r'\b(lunes|martes|mi[ée]rcoles|jueves|viernes|s[áa]bado|domingo|luns|mercores|xoves|venres)\b',
  caseSensitive: false,
);

/// Primer día, a partir de [referencia] (incluida), cuyo `weekday` sea [diaSemanaObjetivo].
DateTime _proximoDiaSemana(DateTime referencia, int diaSemanaObjetivo) {
  var fecha = DateTime(referencia.year, referencia.month, referencia.day);
  while (fecha.weekday != diaSemanaObjetivo) {
    fecha = fecha.add(const Duration(days: 1));
  }
  return fecha;
}

/// Número de hora escrito en letra (castellano o gallego, sin tilde) → 1-12.
const _numerosHora = {
  'una': 1, 'unha': 1,
  'dos': 2, 'duas': 2,
  'tres': 3,
  'cuatro': 4, 'catro': 4,
  'cinco': 5,
  'seis': 6,
  'siete': 7, 'sete': 7,
  'ocho': 8, 'oito': 8,
  'nueve': 9, 'nove': 9,
  'diez': 10, 'dez': 10,
  'once': 11,
  'doce': 12,
};

/// Hora del funeral en letra o en cifra ("ás Cinco do serán", "a las 11 y media de la
/// mañana"): grupo 1 = número (letra o cifra), grupo 2 = "e media" si está, grupo 3 = momento
/// del día (mañá/tarde/serán/noite), que decide si son las 24h de la mañana o hay que sumar 12.
final _regexHoraFuneral = RegExp(
  r'\b[aá]s?\s+([a-zñ]+|\d{1,2})\s*(?:e\s+media|y\s+media)?\s*(?:do|da|de\s+la)\s+'
  r'(ma[ñn][aá]|manha|tarde|ser[aá]n|noite)',
  caseSensitive: false,
);

/// Convierte lo que capturó [_regexHoraFuneral] a "HH:mm" en 24h, o `null` si el número de
/// hora no se reconoce.
String? _horaDesdeMatch(RegExpMatch match) {
  final horaToken = match.group(1)!;
  var hora = int.tryParse(horaToken);
  hora ??= _numerosHora[_normalizar(horaToken)];
  if (hora == null || hora < 1 || hora > 12) return null;

  final tieneMedia = match.group(0)!.toLowerCase().contains('media');
  final periodo = _normalizar(match.group(2)!);

  int hora24;
  if (periodo.startsWith('mana') || periodo.startsWith('manh')) {
    hora24 = hora == 12 ? 0 : hora;
  } else if (periodo.startsWith('noite') && hora == 12) {
    hora24 = 0;
  } else {
    hora24 = hora == 12 ? 12 : hora + 12;
  }
  final minuto = tieneMedia ? 30 : 0;
  return '${hora24.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
}

// "Lgrexa" cubre un error de OCR muy típico: la "I" mayúscula de "Igrexa" se lee como "L"
// (tipografías finas/condensadas), sobre todo cuando además se come el espacio con la palabra
// anterior ("Apóstol á Igrexa" → "Apóstolá Lgrexa").
const _terminadorIglesia = r'igrexa\b|iglesia\b|lgrexa\b';

/// Iglesia + Lugar en un único patrón, con dos grupos: el "Lugar" es lo que venga entre
/// paréntesis justo después del nombre de la iglesia (p. ej. "Santa María de Marrozos
/// (Santiago)" → Iglesia = "Santa María de Marrozos", Lugar = "Santiago").
final _regexIglesiaLugar = RegExp(
  r'(?:iglesia|igrexa|lgrexa)(?:\s+parroquial)?\s+de\s+([^,;.()]+?)(?:\s*\(([^)]+)\))?'
  r'(?=\s+(?:onde|donde)\b|[,;.]|$)',
  caseSensitive: false,
);

final _regexCapillaArdiente = RegExp(
  r'(?:capilla ardiente|capela ardente|sala velatoria)\s*:?\s*([^\.]+)',
  caseSensitive: false,
);

/// Fallback cuando la esquela no trae la etiqueta explícita "Capilla Ardiente:"/"Capela
/// Ardente:": el nombre del tanatorio/complejo funerario suele delatar por sí solo dónde está
/// la capilla ardiente ("Complexo Funerario Apóstol Santiago"). Se corta antes de la dirección
/// entre paréntesis, del punto/punto y coma, de la iglesia (campo propio) o de "sala X" (campo
/// propio también).
final _regexCapillaArdienteNegocio = RegExp(
  r'((?:complexo|complejo)\s+funerario|tanatorio)\s+([^(;.]+?)'
  r'(?=\s*\(|[;.]|' + _terminadorIglesia + r'|,?\s*sala\b|$)',
  caseSensitive: false,
);

/// Sala: solo la palabra o número suelto que venga justo después de "sala" (campo propio,
/// independiente de Capilla Ardiente). El carácter de separación se deja abierto ("[^\p{L}\p{N}]*")
/// en vez de enumerar comillas concretas, para no depender de qué tipo de comilla use el OCR.
final _regexSala = RegExp(
  r'\bsala\b[^\p{L}\p{N}]*([\p{L}\p{N}]+)',
  caseSensitive: false,
  unicode: true,
);

/// Intenta rellenar cada campo por separado a partir del texto ya limpiado (bloques válidos,
/// ordenados y unidos en una sola línea); si no encuentra un campo con confianza, lo deja en
/// blanco para que el cliente lo rellene a mano en vez de arrastrar texto a medias.
class _CamposExtraidos {
  final DateTime? fechaFallecimiento;
  final int? edad;
  final DateTime? fechaFuneral;
  final String? horaFuneral;
  final String? iglesia;
  final String? lugar;
  final String? capillaArdiente;
  final String? sala;

  const _CamposExtraidos({
    this.fechaFallecimiento,
    this.edad,
    this.fechaFuneral,
    this.horaFuneral,
    this.iglesia,
    this.lugar,
    this.capillaArdiente,
    this.sala,
  });
}

_CamposExtraidos _extraerCampos(String texto) {
  DateTime? fechaFallecimiento;
  final matchFecha = _regexFechaFallecimiento.firstMatch(texto);
  if (matchFecha != null) {
    final dia = int.tryParse(matchFecha.group(1)!);
    final mes = _meses[_normalizar(matchFecha.group(2)!)];
    final anio = int.tryParse(matchFecha.group(3)!);
    if (dia != null && mes != null && anio != null) {
      fechaFallecimiento = DateTime(anio, mes, dia);
    }
  }
  if (fechaFallecimiento == null) {
    // La esquela trae la fecha en formato numérico (15/07/2026) en vez de con el mes en letra.
    final matchFechaNumerica = _regexFechaFallecimientoNumerica.firstMatch(texto);
    if (matchFechaNumerica != null) {
      final dia = int.tryParse(matchFechaNumerica.group(1)!);
      final mes = int.tryParse(matchFechaNumerica.group(2)!);
      final anio = int.tryParse(matchFechaNumerica.group(3)!);
      if (dia != null && mes != null && mes >= 1 && mes <= 12 && anio != null) {
        fechaFallecimiento = DateTime(anio, mes, dia);
      }
    }
  }

  var matchEdad = _regexEdad.firstMatch(texto);
  matchEdad ??= _regexEdadGenerica.firstMatch(texto);
  final edad = matchEdad != null ? int.tryParse(matchEdad.group(1)!) : null;

  DateTime? fechaFuneral;
  final matchDia = _regexDiaSemana.firstMatch(texto);
  if (matchDia != null) {
    final diaObjetivo = _diasSemana[_normalizar(matchDia.group(0)!)];
    if (diaObjetivo != null) {
      fechaFuneral = _proximoDiaSemana(fechaFallecimiento ?? DateTime.now(), diaObjetivo);
    }
  }

  final matchHora = _regexHoraFuneral.firstMatch(texto);
  final horaFuneral = matchHora != null ? _horaDesdeMatch(matchHora) : null;

  final matchIglesiaLugar = _regexIglesiaLugar.firstMatch(texto);
  final iglesiaCruda = matchIglesiaLugar?.group(1)?.trim();
  final iglesia = iglesiaCruda != null && iglesiaCruda.isNotEmpty ? formatearTitulo(iglesiaCruda) : null;
  final lugarCrudo = matchIglesiaLugar?.group(2)?.trim();
  final lugar = lugarCrudo != null && lugarCrudo.isNotEmpty ? formatearTitulo(lugarCrudo) : null;

  // Group(1), no group(0): se descarta la propia etiqueta ("Capilla Ardiente: "/"Sala
  // velatoria: "), solo interesa el nombre del tanatorio y la sala.
  final matchCapilla = _regexCapillaArdiente.firstMatch(texto);
  var capillaCruda = matchCapilla?.group(1)?.trim();
  if (capillaCruda == null || capillaCruda.isEmpty) {
    // La esquela no trae una etiqueta explícita: se busca directamente el nombre del
    // tanatorio/complejo funerario donde esté.
    final matchNegocio = _regexCapillaArdienteNegocio.firstMatch(texto);
    if (matchNegocio != null) {
      capillaCruda = '${matchNegocio.group(1)} ${matchNegocio.group(2)}'.trim();
    }
  }
  final capillaArdiente = capillaCruda != null && capillaCruda.isNotEmpty ? formatearTitulo(capillaCruda) : null;

  final matchSala = _regexSala.firstMatch(texto);
  final salaCruda = matchSala?.group(1)?.trim();
  final sala = salaCruda != null && salaCruda.isNotEmpty ? formatearTitulo(salaCruda) : null;

  return _CamposExtraidos(
    fechaFallecimiento: fechaFallecimiento,
    edad: edad,
    fechaFuneral: fechaFuneral,
    horaFuneral: horaFuneral,
    iglesia: iglesia,
    lugar: lugar,
    capillaArdiente: capillaArdiente,
    sala: sala,
  );
}

/// Toma una foto de la esquela y ejecuta reconocimiento de texto en el propio móvil (no se
/// envía la imagen a ningún servidor): con eso rellena por separado los campos del formulario
/// (fecha, edad, funeral, lugar, capilla ardiente), para que el cliente los revise antes de
/// publicar. No se guarda la foto, solo lo que el cliente confirme.
class PublicacionEscanearScreen extends ConsumerStatefulWidget {
  const PublicacionEscanearScreen({super.key});

  @override
  ConsumerState<PublicacionEscanearScreen> createState() => _PublicacionEscanearScreenState();
}

class _PublicacionEscanearScreenState extends ConsumerState<PublicacionEscanearScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _escanear());
  }

  Future<void> _escanear() async {
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
    } catch (_) {
      picked = null;
    }
    if (picked == null) {
      if (mounted) context.pop();
      return;
    }

    // El nombre/teléfono del propio cliente (ya en su perfil) ayuda a identificar con precisión
    // su propio pie publicitario dentro de la esquela.
    final perfil = await ref.read(currentUserProfileProvider.future);

    var nombreGuess = '';
    _CamposExtraidos campos = const _CamposExtraidos();
    var ocrFallo = false;
    String? detalleError;
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await recognizer.processImage(InputImage.fromFilePath(picked.path));
      await recognizer.close();

      final lineas = [for (final block in recognizedText.blocks) ...block.lines];
      if (lineas.isEmpty) {
        ocrFallo = true;
      } else {
        final masGrande = lineas.reduce((a, b) => a.boundingBox.height >= b.boundingBox.height ? a : b);
        nombreGuess = formatearTitulo(_limpiarNombre(masGrande.text));

        // El orden en el que ML Kit devuelve los bloques no siempre sigue el orden visual de
        // lectura (arriba a abajo), sobre todo con bordes decorativos alrededor del texto; se
        // reordenan por su posición vertical en la foto para que los patrones de texto no
        // tengan que buscar a través de fragmentos descolocados.
        final bloquesOrdenados = recognizedText.blocks.toList()
          ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

        final bloquesValidos = bloquesOrdenados.where((b) {
          // Los bloques con una palabra ancla importante (RUEGAN, Capilla Ardiente...) nunca se
          // descartan, ni como ruido ni como bloque familiar: p. ej. la sala del velatorio puede
          // coincidir con el nombre del propio tanatorio-cliente sin ser su pie publicitario.
          if (_tieneAnclaImportante(b.text)) return true;
          if (_esBloqueRuido(b.text, nombreCliente: perfil?.nombre, telefonoCliente: perfil?.telefono)) {
            return false;
          }
          return !_esBloqueFamiliar(b.text);
        });
        final textoCompleto = bloquesValidos.map((b) => _limpiarBloque(b.text)).join(' ');
        campos = _extraerCampos(textoCompleto);
      }
    } catch (e) {
      ocrFallo = true;
      detalleError = e.toString();
    }

    // Si no se ha encontrado ninguna capilla ardiente y el propio cliente que escanea es de
    // tipo "Tanatorio", casi siempre el velatorio es su propio local: se rellena con su nombre.
    if ((campos.capillaArdiente == null || campos.capillaArdiente!.isEmpty) && perfil != null) {
      try {
        final tipos = await ref.read(clienteTiposListProvider.future);
        final tipoNombre = tipos
            .where((t) => t.idConfiguracionClienteTipo == perfil.idConfiguracionClienteTipo)
            .map((t) => t.nombre)
            .firstOrNull;
        if (tipoNombre == 'Tanatorio') {
          campos = _CamposExtraidos(
            fechaFallecimiento: campos.fechaFallecimiento,
            edad: campos.edad,
            fechaFuneral: campos.fechaFuneral,
            horaFuneral: campos.horaFuneral,
            iglesia: campos.iglesia,
            lugar: campos.lugar,
            capillaArdiente: perfil.nombre,
            sala: campos.sala,
          );
        }
      } catch (_) {
        // Sin conexión o fallo puntual: no es crítico, el cliente rellena el campo a mano.
      }
    }

    if (!mounted) return;
    context.pushReplacement(
      '/publicar/manual',
      extra: {
        'nombre': nombreGuess,
        'fechaFallecimiento': campos.fechaFallecimiento?.toIso8601String(),
        'edad': campos.edad?.toString(),
        'fechaFuneral': campos.fechaFuneral?.toIso8601String(),
        'horaFuneral': campos.horaFuneral,
        'iglesia': campos.iglesia,
        'lugar': campos.lugar,
        'capillaArdiente': campos.capillaArdiente,
        'sala': campos.sala,
        if (ocrFallo)
          'avisoOcr': detalleError != null
              ? context.l10n.publicarOcrError(detalleError)
              : context.l10n.publicarOcrSinTexto,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.publicarEscanear)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.publicarLeyendoEsquela),
          ],
        ),
      ),
    );
  }
}
