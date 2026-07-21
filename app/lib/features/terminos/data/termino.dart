class Termino {
  final String idSistemaTermino;
  final String tipo;
  final String titulo;
  final String cuerpo;

  const Termino({
    required this.idSistemaTermino,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
  });

  /// [idiomaCodigo] es "ES" o "GL"; si el documento no tiene contenido en ese idioma
  /// (no debería pasar, pero por si acaso) se usa el primero disponible.
  factory Termino.fromMap(Map<String, dynamic> map, String idiomaCodigo) {
    final idiomas = (map['TSistemaTerminosIdiomas'] as List<dynamic>).cast<Map<String, dynamic>>();
    final idioma = idiomas.firstWhere(
      (i) => (i['TSistemaIdiomas'] as Map<String, dynamic>)['Codigo'] == idiomaCodigo,
      orElse: () => idiomas.first,
    );
    return Termino(
      idSistemaTermino: map['IdSistemaTermino'] as String,
      tipo: map['Tipo'] as String,
      titulo: idioma['Titulo'] as String,
      cuerpo: idioma['Cuerpo'] as String,
    );
  }
}
