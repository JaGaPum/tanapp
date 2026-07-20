class ClienteSede {
  final String idClienteSede;
  final String codigo;
  final String nombre;
  final String provincia;
  final String concello;
  final String direccion;

  const ClienteSede({
    required this.idClienteSede,
    required this.codigo,
    required this.nombre,
    required this.provincia,
    required this.concello,
    required this.direccion,
  });

  factory ClienteSede.fromMap(Map<String, dynamic> map) => ClienteSede(
        idClienteSede: map['IdClienteSede'] as String,
        codigo: map['Codigo'] as String? ?? '',
        nombre: map['Nombre'] as String,
        provincia: map['Provincia'] as String,
        concello: map['Concello'] as String,
        direccion: map['Direccion'] as String,
      );
}
