class Sesion {
  final String idSistemaSesion;
  final String idSistemaUsuario;
  final DateTime fechaInicio;
  final DateTime fechaUltimoAcceso;
  final DateTime? fechaFin;
  final bool recordar;
  final String estado;
  final String? idClienteSede;

  const Sesion({
    required this.idSistemaSesion,
    required this.idSistemaUsuario,
    required this.fechaInicio,
    required this.fechaUltimoAcceso,
    this.fechaFin,
    required this.recordar,
    required this.estado,
    this.idClienteSede,
  });

  bool get abierta => estado == 'ABIERTA';

  factory Sesion.fromMap(Map<String, dynamic> map) {
    return Sesion(
      idSistemaSesion: map['IdSistemaSesion'] as String,
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      fechaInicio: DateTime.parse(map['FechaInicio'] as String),
      fechaUltimoAcceso: DateTime.parse(map['FechaUltimoAcceso'] as String),
      fechaFin: map['FechaFin'] == null
          ? null
          : DateTime.parse(map['FechaFin'] as String),
      recordar: map['Recordar'] as bool? ?? false,
      estado: map['Estado'] as String,
      idClienteSede: map['IdClienteSede'] as String?,
    );
  }
}

/// Fila de "FSistemaSesionesAbiertas": una sesión abierta con el nombre de usuario y de sede
/// ya resueltos, para la pestaña "En vivo" del admin.
class SesionAbierta {
  final String idSistemaSesion;
  final String idSistemaUsuario;
  final String nombreUsuario;
  final String emailUsuario;
  final String? idClienteSede;
  final String? nombreSede;
  final DateTime fechaInicio;
  final DateTime fechaUltimoAcceso;
  final bool recordar;

  const SesionAbierta({
    required this.idSistemaSesion,
    required this.idSistemaUsuario,
    required this.nombreUsuario,
    required this.emailUsuario,
    this.idClienteSede,
    this.nombreSede,
    required this.fechaInicio,
    required this.fechaUltimoAcceso,
    required this.recordar,
  });

  factory SesionAbierta.fromMap(Map<String, dynamic> map) {
    return SesionAbierta(
      idSistemaSesion: map['IdSistemaSesion'] as String,
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      nombreUsuario: map['NombreUsuario'] as String,
      emailUsuario: map['EmailUsuario'] as String,
      idClienteSede: map['IdClienteSede'] as String?,
      nombreSede: map['NombreSede'] as String?,
      fechaInicio: DateTime.parse(map['FechaInicio'] as String),
      fechaUltimoAcceso: DateTime.parse(map['FechaUltimoAcceso'] as String),
      recordar: map['Recordar'] as bool? ?? false,
    );
  }
}
