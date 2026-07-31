/// Un aviso de texto libre recibido por el usuario actual (bandeja del seguidor), con el
/// nombre del cliente/sede que lo mandó y si ya lo ha abierto.
class AvisoRecibido {
  final String idClienteAvisoDestinatario;
  final String titulo;
  final String texto;
  final DateTime fechaAlta;
  final bool leido;
  final String nombreCliente;
  final String nombreSede;

  const AvisoRecibido({
    required this.idClienteAvisoDestinatario,
    required this.titulo,
    required this.texto,
    required this.fechaAlta,
    required this.leido,
    required this.nombreCliente,
    required this.nombreSede,
  });

  factory AvisoRecibido.fromMap(Map<String, dynamic> map) {
    final aviso = map['TClienteAvisos'] as Map<String, dynamic>;
    final sede = aviso['TClienteSedes'] as Map<String, dynamic>;
    final cliente = sede['TSistemaUsuarios'] as Map<String, dynamic>;
    return AvisoRecibido(
      idClienteAvisoDestinatario: map['IdClienteAvisoDestinatario'] as String,
      titulo: aviso['Titulo'] as String,
      texto: aviso['Texto'] as String,
      // La del propio buzón (cuándo le llegó a este destinatario), no la del aviso original:
      // se crean en la misma transacción así que a efectos prácticos es el mismo instante, pero
      // esta es la que se puede ordenar/paginar directamente sin depender de un recurso embebido.
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      leido: map['Leido'] as bool,
      nombreCliente: cliente['Nombre'] as String,
      nombreSede: sede['Nombre'] as String,
    );
  }
}
