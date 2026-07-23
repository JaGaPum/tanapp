class ClienteImportacionWeb {
  final String idClienteImportacionWeb;
  final String url;
  final bool activo;
  final DateTime fechaAutorizacion;

  const ClienteImportacionWeb({
    required this.idClienteImportacionWeb,
    required this.url,
    required this.activo,
    required this.fechaAutorizacion,
  });

  factory ClienteImportacionWeb.fromMap(Map<String, dynamic> map) => ClienteImportacionWeb(
        idClienteImportacionWeb: map['IdClienteImportacionWeb'] as String,
        url: map['Url'] as String,
        activo: map['Activo'] as bool,
        fechaAutorizacion: DateTime.parse(map['FechaAutorizacion'] as String),
      );
}
