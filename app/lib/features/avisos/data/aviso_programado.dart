/// Un aviso programado: guardado en "TClienteAvisosProgramados" (055) hasta que llegue su
/// [fechaProgramada], momento en el que un job de la base de datos lo mueve solo a
/// "TClienteAvisos" (ver 056), disparando el envío igual que uno inmediato.
class AvisoProgramado {
  final String idClienteAvisoProgramado;
  final String idClienteSede;
  final String titulo;
  final String texto;
  final DateTime fechaProgramada;
  final String codigoSede;
  final String nombreSede;

  const AvisoProgramado({
    required this.idClienteAvisoProgramado,
    required this.idClienteSede,
    required this.titulo,
    required this.texto,
    required this.fechaProgramada,
    required this.codigoSede,
    required this.nombreSede,
  });

  factory AvisoProgramado.fromMap(Map<String, dynamic> map) {
    final sede = map['TClienteSedes'] as Map<String, dynamic>;
    return AvisoProgramado(
      idClienteAvisoProgramado: map['IdClienteAvisoProgramado'] as String,
      idClienteSede: map['IdClienteSede'] as String,
      titulo: map['Titulo'] as String,
      texto: map['Texto'] as String,
      fechaProgramada: DateTime.parse(map['FechaProgramada'] as String),
      codigoSede: sede['Codigo'] as String,
      nombreSede: sede['Nombre'] as String,
    );
  }
}
