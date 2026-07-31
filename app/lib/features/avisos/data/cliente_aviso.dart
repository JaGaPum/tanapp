/// Un aviso de texto libre enviado por un cliente (p.ej. "cambio de horario"), tal y como lo ve
/// el propio cliente en su histórico de enviados.
class ClienteAviso {
  final String idClienteAviso;
  final String titulo;
  final String texto;
  final DateTime fechaAlta;
  final String nombreSede;

  const ClienteAviso({
    required this.idClienteAviso,
    required this.titulo,
    required this.texto,
    required this.fechaAlta,
    required this.nombreSede,
  });

  factory ClienteAviso.fromMap(Map<String, dynamic> map) {
    final sede = map['TClienteSedes'] as Map<String, dynamic>;
    return ClienteAviso(
      idClienteAviso: map['IdClienteAviso'] as String,
      titulo: map['Titulo'] as String,
      texto: map['Texto'] as String,
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreSede: sede['Nombre'] as String,
    );
  }
}
