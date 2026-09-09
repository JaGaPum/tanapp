/// Una publicación programada: guardada en "TClientePublicacionesProgramadas" (055) hasta que
/// llegue su [fechaProgramada], momento en el que un job de la base de datos la mueve sola a
/// "TClientePublicaciones" (ver 056). Mientras tanto no es una esquela real: no la ve nadie
/// salvo su propio dueño.
class PublicacionProgramada {
  final String idClientePublicacionProgramada;
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
  final DateTime fechaProgramada;
  final String codigoSede;
  final String nombreSede;

  /// 'ESQUELA' (por defecto) o 'ACTO' — ver [PublicacionConSede.tipo] (064).
  final String tipo;
  final String? idConfiguracionActoTipo;
  final String? actoTipoOtro;

  /// Ver [PublicacionConSede.admiteCondolencias]/[PublicacionConSede.condolenciasSoloPrivadas]
  /// (069) — se guardan ya aquí para que al llegar su fecha se publiquen con la configuración
  /// que el cliente eligió, no con la de por defecto.
  final bool admiteCondolencias;
  final bool condolenciasSoloPrivadas;

  bool get esActo => tipo == 'ACTO';

  const PublicacionProgramada({
    required this.idClientePublicacionProgramada,
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
    required this.fechaProgramada,
    required this.codigoSede,
    required this.nombreSede,
    this.tipo = 'ESQUELA',
    this.idConfiguracionActoTipo,
    this.actoTipoOtro,
    this.admiteCondolencias = true,
    this.condolenciasSoloPrivadas = false,
  });

  factory PublicacionProgramada.fromMap(Map<String, dynamic> map) {
    final sede = map['TClienteSedes'] as Map<String, dynamic>;
    final fechaFallecimiento = map['FechaFallecimiento'] as String?;
    final fechaFuneral = map['FechaFuneral'] as String?;
    final horaFuneralCruda = map['HoraFuneral'] as String?;
    return PublicacionProgramada(
      idClientePublicacionProgramada:
          map['IdClientePublicacionProgramada'] as String,
      idClienteSede: map['IdClienteSede'] as String,
      nombreFallecido: map['NombreFallecido'] as String,
      fechaFallecimiento: fechaFallecimiento != null
          ? DateTime.parse(fechaFallecimiento)
          : null,
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
      fechaProgramada: DateTime.parse(map['FechaProgramada'] as String),
      codigoSede: sede['Codigo'] as String,
      nombreSede: sede['Nombre'] as String,
      tipo: map['Tipo'] as String? ?? 'ESQUELA',
      idConfiguracionActoTipo: map['IdConfiguracionActoTipo'] as String?,
      actoTipoOtro: map['ActoTipoOtro'] as String?,
      admiteCondolencias: map['AdmiteCondolencias'] as bool? ?? true,
      condolenciasSoloPrivadas:
          map['CondolenciasSoloPrivadas'] as bool? ?? false,
    );
  }
}
