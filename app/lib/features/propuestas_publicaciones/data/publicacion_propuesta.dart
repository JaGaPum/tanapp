class PublicacionPropuesta {
  final String idClientePublicacionPropuesta;
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
  final String urlOrigen;
  final DateTime fechaAlta;

  const PublicacionPropuesta({
    required this.idClientePublicacionPropuesta,
    required this.nombreFallecido,
    this.fechaFallecimiento,
    this.edad,
    this.fechaFuneral,
    this.horaFuneral,
    this.iglesia,
    this.lugar,
    this.capillaArdiente,
    this.sala,
    this.observaciones,
    required this.urlOrigen,
    required this.fechaAlta,
  });

  factory PublicacionPropuesta.fromMap(Map<String, dynamic> map) {
    final fechaFallecimiento = map['FechaFallecimiento'] as String?;
    final fechaFuneral = map['FechaFuneral'] as String?;
    final horaFuneralCruda = map['HoraFuneral'] as String?;
    return PublicacionPropuesta(
      idClientePublicacionPropuesta: map['IdClientePublicacionPropuesta'] as String,
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
      urlOrigen: map['UrlOrigen'] as String,
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
    );
  }
}
