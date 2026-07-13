class ComunicacionIdioma {
  final String? idConfiguracionComunicacionIdioma;
  final String idSistemaIdioma;
  final String codigoIdioma;
  final String nombreIdioma;
  final String? asunto;
  final String cuerpo;

  const ComunicacionIdioma({
    this.idConfiguracionComunicacionIdioma,
    required this.idSistemaIdioma,
    required this.codigoIdioma,
    required this.nombreIdioma,
    this.asunto,
    required this.cuerpo,
  });

  ComunicacionIdioma copyWith({String? asunto, String? cuerpo}) => ComunicacionIdioma(
        idConfiguracionComunicacionIdioma: idConfiguracionComunicacionIdioma,
        idSistemaIdioma: idSistemaIdioma,
        codigoIdioma: codigoIdioma,
        nombreIdioma: nombreIdioma,
        asunto: asunto ?? this.asunto,
        cuerpo: cuerpo ?? this.cuerpo,
      );

  factory ComunicacionIdioma.fromMap(Map<String, dynamic> map) => ComunicacionIdioma(
        idConfiguracionComunicacionIdioma: map['IdConfiguracionComunicacionIdioma'] as String,
        idSistemaIdioma: map['IdSistemaIdioma'] as String,
        codigoIdioma: (map['TSistemaIdiomas'] as Map<String, dynamic>)['Codigo'] as String,
        nombreIdioma: (map['TSistemaIdiomas'] as Map<String, dynamic>)['Nombre'] as String,
        asunto: map['Asunto'] as String?,
        cuerpo: map['Cuerpo'] as String,
      );
}

class Comunicacion {
  final String idConfiguracionComunicacion;
  final String tipoComunicacion;
  final String codComunicacion;
  final String nombreComunicacion;
  final String? remitente;
  final bool activo;
  final List<ComunicacionIdioma> traducciones;

  const Comunicacion({
    required this.idConfiguracionComunicacion,
    required this.tipoComunicacion,
    required this.codComunicacion,
    required this.nombreComunicacion,
    this.remitente,
    required this.activo,
    required this.traducciones,
  });

  factory Comunicacion.fromMap(Map<String, dynamic> map) {
    final traduccionesRaw = map['TConfiguracionComunicacionesIdiomas'] as List<dynamic>? ?? const [];
    return Comunicacion(
      idConfiguracionComunicacion: map['IdConfiguracionComunicacion'] as String,
      tipoComunicacion: map['TipoComunicacion'] as String,
      codComunicacion: map['CodComunicacion'] as String,
      nombreComunicacion: map['NombreComunicacion'] as String,
      remitente: map['Remitente'] as String?,
      activo: map['Activo'] as bool? ?? true,
      traducciones: traduccionesRaw
          .map((e) => ComunicacionIdioma.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
