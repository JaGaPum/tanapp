import '../../publicaciones/data/publicacion_con_sede.dart';

/// Un recordatorio personal de una publicación (070): el usuario elige que se le avise en una
/// fecha/hora antes del evento, hasta un máximo de 2 por publicación. Mientras no ha llegado su
/// hora ([enviado] es false) aparece en "Mis recordatorios", donde se puede editar/eliminar; en
/// cuanto un job de la base de datos lo marca enviado, desaparece de ahí y pasa a verse como una
/// notificación recibida, con su propio [leido] (071) igual que un aviso normal.
class RecordatorioPublicacion {
  final String idClientePublicacionRecordatorio;
  final String idClientePublicacion;
  final DateTime fechaHoraRecordatorio;
  final bool enviado;
  final DateTime? fechaEnviado;
  final bool leido;

  /// Solo viene relleno cuando se pide con [fromMapConPublicacion] (listados personales, donde
  /// todavía no se conoce la publicación); en el listado de recordatorios de una publicación ya
  /// concreta ([fromMap]) no hace falta, porque la pantalla ya la tiene.
  final PublicacionConSede? publicacion;

  const RecordatorioPublicacion({
    required this.idClientePublicacionRecordatorio,
    required this.idClientePublicacion,
    required this.fechaHoraRecordatorio,
    required this.enviado,
    required this.fechaEnviado,
    required this.leido,
    this.publicacion,
  });

  factory RecordatorioPublicacion.fromMap(Map<String, dynamic> map) {
    final fechaEnviado = map['FechaEnviado'] as String?;
    return RecordatorioPublicacion(
      idClientePublicacionRecordatorio:
          map['IdClientePublicacionRecordatorio'] as String,
      idClientePublicacion: map['IdClientePublicacion'] as String,
      fechaHoraRecordatorio: DateTime.parse(
        map['FechaHoraRecordatorio'] as String,
      ).toLocal(),
      enviado: map['Enviado'] as bool,
      fechaEnviado: fechaEnviado != null
          ? DateTime.parse(fechaEnviado).toLocal()
          : null,
      leido: map['Leido'] as bool? ?? false,
    );
  }

  factory RecordatorioPublicacion.fromMapConPublicacion(
    Map<String, dynamic> map,
  ) {
    final base = RecordatorioPublicacion.fromMap(map);
    final publicacion = PublicacionConSede.fromMap(
      map['TClientePublicaciones'] as Map<String, dynamic>,
    );
    return RecordatorioPublicacion(
      idClientePublicacionRecordatorio: base.idClientePublicacionRecordatorio,
      idClientePublicacion: base.idClientePublicacion,
      fechaHoraRecordatorio: base.fechaHoraRecordatorio,
      enviado: base.enviado,
      fechaEnviado: base.fechaEnviado,
      leido: base.leido,
      publicacion: publicacion,
    );
  }
}
