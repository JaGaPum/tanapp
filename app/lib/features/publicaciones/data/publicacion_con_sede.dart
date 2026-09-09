import '../../acto_tipos/data/acto_tipo.dart';

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
  final int numCondolencias;

  /// 'ESQUELA' (por defecto) o 'ACTO' (misa u otro acto de recuerdo, no ligado a un fallecimiento
  /// recién ocurrido — ver 064).
  final String tipo;
  final String? idConfiguracionActoTipo;

  /// Solo cuando el cliente ha elegido "Otro" en vez de un tipo del catálogo.
  final String? actoTipoOtro;

  /// Si esta esquela admite condolencias (069). Un acto (misa u otro) nunca las admite, tenga lo
  /// que tenga esta columna -no viene de aquí, ver [esActo]-.
  final bool admiteCondolencias;

  /// Si está activo, cada condolencia que se deje aquí es privada sin que quien la escribe tenga
  /// que marcarlo (el trigger "FSistemaValidarCondolencia" en 069 lo fuerza igualmente).
  final bool condolenciasSoloPrivadas;

  bool get esActo => tipo == 'ACTO';

  /// Fecha y hora combinadas del evento (funeral o acto), o null si falta cualquiera de las dos
  /// (070): la usa el botón de "recordatorio" de la tarjeta para decidir si tiene sentido
  /// ofrecerlo, y para acotar el selector de fecha/hora del recordatorio.
  DateTime? get fechaHoraEvento {
    final fecha = fechaFuneral;
    final hora = horaFuneral;
    if (fecha == null || hora == null) return null;
    final partes = hora.split(':');
    if (partes.length < 2) return null;
    final horas = int.tryParse(partes[0]);
    final minutos = int.tryParse(partes[1]);
    if (horas == null || minutos == null) return null;
    return DateTime(fecha.year, fecha.month, fecha.day, horas, minutos);
  }

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
    required this.numCondolencias,
    this.tipo = 'ESQUELA',
    this.idConfiguracionActoTipo,
    this.actoTipoOtro,
    this.admiteCondolencias = true,
    this.condolenciasSoloPrivadas = false,
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
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreCliente: cliente['Nombre'] as String,
      nombreSede: sede['Nombre'] as String,
      concello: sede['Concello'] as String,
      provincia: sede['Provincia'] as String,
      numCondolencias: map['numCondolencias'] as int? ?? 0,
      tipo: map['Tipo'] as String? ?? 'ESQUELA',
      idConfiguracionActoTipo: map['IdConfiguracionActoTipo'] as String?,
      actoTipoOtro: map['ActoTipoOtro'] as String?,
      admiteCondolencias: map['AdmiteCondolencias'] as bool? ?? true,
      condolenciasSoloPrivadas:
          map['CondolenciasSoloPrivadas'] as bool? ?? false,
    );
  }

  /// Fila plana (sin anidar) que devuelve la función "FBuscarPublicacionesHistorico": mismos
  /// datos que [fromMap], pero el cliente y la sede vienen como columnas propias en vez de como
  /// recursos embebidos, al ser el resultado de un RPC en vez de un SELECT con joins de PostgREST.
  factory PublicacionConSede.fromSearchRow(Map<String, dynamic> map) {
    final fechaFallecimiento = map['FechaFallecimiento'] as String?;
    final fechaFuneral = map['FechaFuneral'] as String?;
    final horaFuneralCruda = map['HoraFuneral'] as String?;
    return PublicacionConSede(
      idClientePublicacion: map['IdClientePublicacion'] as String,
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
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreCliente: map['NombreCliente'] as String,
      nombreSede: map['NombreSede'] as String,
      concello: map['Concello'] as String,
      provincia: map['Provincia'] as String,
      numCondolencias: map['NumCondolencias'] as int? ?? 0,
      tipo: map['Tipo'] as String? ?? 'ESQUELA',
      idConfiguracionActoTipo: map['IdConfiguracionActoTipo'] as String?,
      actoTipoOtro: map['ActoTipoOtro'] as String?,
      // El RPC no devuelve estas dos columnas todavía (no hace falta para el tablón/búsqueda,
      // que no muestran el botón de condolencias distinto según esto, solo según [esActo]): se
      // asume el valor por defecto, y quien de verdad las necesita (el formulario de edición) lee
      // por [PublicacionConSede.fromMap], que sí las trae.
      admiteCondolencias: map['AdmiteCondolencias'] as bool? ?? true,
      condolenciasSoloPrivadas:
          map['CondolenciasSoloPrivadas'] as bool? ?? false,
    );
  }
}

/// Nombre del tipo de acto de [publicacion] (del catálogo, o el texto libre de "Otro"), o null si
/// no es un acto o todavía no se ha resuelto. Se usa tanto en la tarjeta (para el chip) como en
/// el detalle (para la fila con el tipo), a partir del mismo catálogo ya cargado en memoria
/// (ver [actoTiposListProvider]).
String? nombreActoTipoDe(
  PublicacionConSede publicacion,
  List<ActoTipo> actoTipos,
) {
  if (!publicacion.esActo) return null;
  if (publicacion.actoTipoOtro != null) return publicacion.actoTipoOtro;
  return actoTipos
      .where(
        (t) => t.idConfiguracionActoTipo == publicacion.idConfiguracionActoTipo,
      )
      .map((t) => t.nombre)
      .firstOrNull;
}
