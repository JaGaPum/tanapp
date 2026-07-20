/// Representa una sede de un cliente (no el cliente en sí: un mismo cliente con varias
/// sedes aparece como varias `ClienteSeguible`, una por sede) — es lo que de verdad se busca,
/// se sigue y para lo que sirve "Cómo llegar".
class ClienteSeguible {
  final String idClienteSede;
  final String idSistemaUsuarioCliente;
  final String nombreCliente;
  final String nombreSede;
  final String direccion;
  final String concello;
  final String provincia;
  final String? telefono;
  final String? fotoUrl;

  const ClienteSeguible({
    required this.idClienteSede,
    required this.idSistemaUsuarioCliente,
    required this.nombreCliente,
    required this.nombreSede,
    required this.direccion,
    required this.concello,
    required this.provincia,
    this.telefono,
    this.fotoUrl,
  });

  /// [map] es una fila de TClienteSedes con el TSistemaUsuarios (cliente dueño) embebido.
  factory ClienteSeguible.fromSedeMap(Map<String, dynamic> map) {
    final cliente = map['TSistemaUsuarios'] as Map<String, dynamic>;
    return ClienteSeguible(
      idClienteSede: map['IdClienteSede'] as String,
      idSistemaUsuarioCliente: map['IdSistemaUsuario'] as String,
      nombreCliente: cliente['Nombre'] as String,
      nombreSede: map['Nombre'] as String,
      direccion: map['Direccion'] as String,
      concello: map['Concello'] as String,
      provincia: map['Provincia'] as String,
      telefono: cliente['Telefono'] as String?,
      fotoUrl: cliente['FotoUrl'] as String?,
    );
  }
}
