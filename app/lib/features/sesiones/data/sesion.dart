class Sesion {
  final String idSistemaSesion;
  final String idSistemaUsuario;
  final DateTime fechaInicio;
  final DateTime fechaUltimoAcceso;
  final DateTime? fechaFin;
  final bool recordar;
  final String estado;

  const Sesion({
    required this.idSistemaSesion,
    required this.idSistemaUsuario,
    required this.fechaInicio,
    required this.fechaUltimoAcceso,
    this.fechaFin,
    required this.recordar,
    required this.estado,
  });

  bool get abierta => estado == 'ABIERTA';

  factory Sesion.fromMap(Map<String, dynamic> map) {
    return Sesion(
      idSistemaSesion: map['IdSistemaSesion'] as String,
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      fechaInicio: DateTime.parse(map['FechaInicio'] as String),
      fechaUltimoAcceso: DateTime.parse(map['FechaUltimoAcceso'] as String),
      fechaFin: map['FechaFin'] == null ? null : DateTime.parse(map['FechaFin'] as String),
      recordar: map['Recordar'] as bool? ?? false,
      estado: map['Estado'] as String,
    );
  }
}
