/// Preposiciones y artículos (castellano y gallego) que van en minúscula dentro de un nombre o
/// lugar, salvo que sean la primera palabra.
const _preposiciones = {
  'de', 'del', 'la', 'las', 'los', 'el', 'y', 'e', 'en',
  'da', 'do', 'das', 'dos', 'o', 'a', 'as', 'os',
};

/// Primera letra de cada palabra en mayúscula, el resto en minúscula; las preposiciones quedan
/// en minúscula salvo que abran el texto. Ej.: "MARIA DEL SOCORRO martinez" → "María del Socorro
/// Martinez".
String formatearTitulo(String texto) {
  final limpio = texto.trim();
  if (limpio.isEmpty) return limpio;
  final palabras = limpio.toLowerCase().split(RegExp(r'\s+'));
  return List.generate(palabras.length, (i) {
    final palabra = palabras[i];
    if (palabra.isEmpty) return palabra;
    if (i > 0 && _preposiciones.contains(palabra)) return palabra;
    return palabra[0].toUpperCase() + palabra.substring(1);
  }).join(' ');
}

/// Primera letra en mayúscula, el resto en minúscula. Ej.: "VIERNES A LAS 11:30" → "Viernes a
/// las 11:30".
String formatearFrase(String texto) {
  final limpio = texto.trim();
  if (limpio.isEmpty) return limpio;
  final minuscula = limpio.toLowerCase();
  return minuscula[0].toUpperCase() + minuscula.substring(1);
}
