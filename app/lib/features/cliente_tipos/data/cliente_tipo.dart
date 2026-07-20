class ClienteTipoIdioma {
  final String? idConfiguracionClienteTipoIdioma;
  final String idSistemaIdioma;
  final String codigoIdioma;
  final String nombreIdioma;
  final String nombre;

  const ClienteTipoIdioma({
    this.idConfiguracionClienteTipoIdioma,
    required this.idSistemaIdioma,
    required this.codigoIdioma,
    required this.nombreIdioma,
    required this.nombre,
  });

  factory ClienteTipoIdioma.fromMap(Map<String, dynamic> map) => ClienteTipoIdioma(
        idConfiguracionClienteTipoIdioma: map['IdConfiguracionClienteTipoIdioma'] as String,
        idSistemaIdioma: map['IdSistemaIdioma'] as String,
        codigoIdioma: (map['TSistemaIdiomas'] as Map<String, dynamic>)['Codigo'] as String,
        nombreIdioma: (map['TSistemaIdiomas'] as Map<String, dynamic>)['Nombre'] as String,
        nombre: map['Nombre'] as String,
      );
}

class ClienteTipo {
  final String idConfiguracionClienteTipo;
  final String nombre;
  final bool activo;
  final List<ClienteTipoIdioma> traducciones;

  const ClienteTipo({
    required this.idConfiguracionClienteTipo,
    required this.nombre,
    required this.activo,
    required this.traducciones,
  });

  factory ClienteTipo.fromMap(Map<String, dynamic> map) {
    final traduccionesRaw = map['TConfiguracionClienteTiposIdiomas'] as List<dynamic>? ?? const [];
    return ClienteTipo(
      idConfiguracionClienteTipo: map['IdConfiguracionClienteTipo'] as String,
      nombre: map['Nombre'] as String,
      activo: map['Activo'] as bool? ?? true,
      traducciones:
          traduccionesRaw.map((e) => ClienteTipoIdioma.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }
}
