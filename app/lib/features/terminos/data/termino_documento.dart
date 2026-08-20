/// Contenido de un documento legal en un idioma concreto, tal cual se guarda en
/// "TSistemaTerminosIdiomas" — a diferencia de [Termino] (que ya resuelve un único idioma para
/// mostrarlo a un usuario), aquí se necesitan TODOS los idiomas a la vez para poder editarlos.
class TerminoIdiomaContenido {
  final String idSistemaIdioma;
  final String codigoIdioma;
  final String nombreIdioma;
  final String titulo;
  final String cuerpo;

  const TerminoIdiomaContenido({
    required this.idSistemaIdioma,
    required this.codigoIdioma,
    required this.nombreIdioma,
    required this.titulo,
    required this.cuerpo,
  });

  factory TerminoIdiomaContenido.fromMap(Map<String, dynamic> map) {
    final idioma = map['TSistemaIdiomas'] as Map<String, dynamic>;
    return TerminoIdiomaContenido(
      idSistemaIdioma: map['IdSistemaIdioma'] as String,
      codigoIdioma: idioma['Codigo'] as String,
      nombreIdioma: idioma['Nombre'] as String,
      titulo: map['Titulo'] as String,
      cuerpo: map['Cuerpo'] as String,
    );
  }
}

/// Documento legal activo (versión en curso) con su contenido en todos los idiomas que ya
/// tenga, para editarlo desde el admin ("Configuración > Términos y condiciones").
class TerminoDocumento {
  final String idSistemaTermino;
  final String tipo;
  final String rol;
  final int version;
  final List<TerminoIdiomaContenido> idiomas;

  const TerminoDocumento({
    required this.idSistemaTermino,
    required this.tipo,
    required this.rol,
    required this.version,
    required this.idiomas,
  });

  factory TerminoDocumento.fromMap(Map<String, dynamic> map) {
    final idiomasRaw =
        map['TSistemaTerminosIdiomas'] as List<dynamic>? ?? const [];
    return TerminoDocumento(
      idSistemaTermino: map['IdSistemaTermino'] as String,
      tipo: map['Tipo'] as String,
      rol: map['Rol'] as String,
      version: map['Version'] as int,
      idiomas: idiomasRaw
          .map((e) => TerminoIdiomaContenido.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
