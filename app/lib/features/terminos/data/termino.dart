class Termino {
  final String idSistemaTermino;
  final String tipo;
  final String idSistemaIdioma;
  final String titulo;
  final String cuerpo;

  const Termino({
    required this.idSistemaTermino,
    required this.tipo,
    required this.idSistemaIdioma,
    required this.titulo,
    required this.cuerpo,
  });

  /// [idiomaCodigo] es "ES" o "GL"; si el documento no tiene contenido en ese idioma
  /// (no debería pasar, pero por si acaso) se usa el primero disponible. [idSistemaIdioma] del
  /// contenido finalmente elegido se conserva (no necesariamente el pedido): hace falta para
  /// dejar constancia de en qué idioma aceptó exactamente el usuario (060).
  factory Termino.fromMap(Map<String, dynamic> map, String idiomaCodigo) {
    final idiomas = (map['TSistemaTerminosIdiomas'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final idioma = idiomas.firstWhere(
      (i) =>
          (i['TSistemaIdiomas'] as Map<String, dynamic>)['Codigo'] ==
          idiomaCodigo,
      orElse: () => idiomas.first,
    );
    return Termino(
      idSistemaTermino: map['IdSistemaTermino'] as String,
      tipo: map['Tipo'] as String,
      idSistemaIdioma: idioma['IdSistemaIdioma'] as String,
      titulo: idioma['Titulo'] as String,
      cuerpo: idioma['Cuerpo'] as String,
    );
  }
}
