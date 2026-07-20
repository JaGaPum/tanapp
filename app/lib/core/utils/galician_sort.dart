final _articuloInicial = RegExp(r'^(A|O|As|Os)\s+', caseSensitive: false);

/// Clave de orden que ignora el artículo gallego inicial (A/O/As/Os), para que
/// "A Coruña" se ordene junto a las C y no se amontone al principio bajo la "A".
String claveOrdenGalego(String nombre) => nombre.replaceFirst(_articuloInicial, '').toLowerCase();
