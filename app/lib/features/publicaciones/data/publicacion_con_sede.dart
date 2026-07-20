/// Una publicación (esquela) con los datos de la sede y del cliente que la firma, para
/// mostrarla en el Taboleiro, en "Seguindo" o en el panel de datos del propio cliente.
class PublicacionConSede {
  final String idClientePublicacion;
  final String idClienteSede;
  final String nombreFallecido;
  final DateTime? fechaFallecimiento;
  final int? edad;
  final DateTime? fechaFuneral;
  final String? horaFuneral;
  final String? iglesia;
  final String? lugar;
  final String? capillaArdiente;
  final String? sala;
  final String? observaciones;
  final DateTime fechaAlta;
  final String nombreCliente;
  final String nombreSede;
  final String concello;
  final String provincia;

  const PublicacionConSede({
    required this.idClientePublicacion,
    required this.idClienteSede,
    required this.nombreFallecido,
    required this.fechaFallecimiento,
    required this.edad,
    required this.fechaFuneral,
    required this.horaFuneral,
    required this.iglesia,
    required this.lugar,
    required this.capillaArdiente,
    required this.sala,
    required this.observaciones,
    required this.fechaAlta,
    required this.nombreCliente,
    required this.nombreSede,
    required this.concello,
    required this.provincia,
  });

  factory PublicacionConSede.fromMap(Map<String, dynamic> map) {
    final sede = map['TClienteSedes'] as Map<String, dynamic>;
    final cliente = sede['TSistemaUsuarios'] as Map<String, dynamic>;
    final fechaFallecimiento = map['FechaFallecimiento'] as String?;
    final fechaFuneral = map['FechaFuneral'] as String?;
    // Postgres devuelve "time" como "HH:mm:ss"; en la app solo interesan horas y minutos.
    final horaFuneralCruda = map['HoraFuneral'] as String?;
    return PublicacionConSede(
      idClientePublicacion: map['IdClientePublicacion'] as String,
      idClienteSede: map['IdClienteSede'] as String,
      nombreFallecido: map['NombreFallecido'] as String,
      fechaFallecimiento: fechaFallecimiento != null ? DateTime.parse(fechaFallecimiento) : null,
      edad: map['Edad'] as int?,
      fechaFuneral: fechaFuneral != null ? DateTime.parse(fechaFuneral) : null,
      horaFuneral: horaFuneralCruda != null && horaFuneralCruda.length >= 5
          ? horaFuneralCruda.substring(0, 5)
          : horaFuneralCruda,
      iglesia: map['Iglesia'] as String?,
      lugar: map['Lugar'] as String?,
      capillaArdiente: map['CapillaArdiente'] as String?,
      sala: map['Sala'] as String?,
      observaciones: map['Observaciones'] as String?,
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreCliente: cliente['Nombre'] as String,
      nombreSede: sede['Nombre'] as String,
      concello: sede['Concello'] as String,
      provincia: sede['Provincia'] as String,
    );
  }
}
