/// Estado de la suscripción del cliente actual (078): si tiene el plan pagado, si está dentro
/// de un periodo gratuito (general o propio, ya resuelto por la base de datos) y, si lo está,
/// hasta cuándo (null = indefinido).
class EstadoSuscripcion {
  final bool planPagado;
  final bool enPeriodoGratuito;
  final DateTime? periodoGratuitoFin;

  const EstadoSuscripcion({
    required this.planPagado,
    required this.enPeriodoGratuito,
    this.periodoGratuitoFin,
  });

  /// Ni el plan está pagado ni sigue en periodo gratuito: hace falta regularizarlo.
  bool get pagoPendiente => !planPagado && !enPeriodoGratuito;

  factory EstadoSuscripcion.fromMap(Map<String, dynamic> map) =>
      EstadoSuscripcion(
        planPagado: map['PlanPagado'] as bool? ?? false,
        enPeriodoGratuito: map['EnPeriodoGratuito'] as bool? ?? false,
        periodoGratuitoFin: map['PeriodoGratuitoFin'] == null
            ? null
            : DateTime.parse(map['PeriodoGratuitoFin'] as String),
      );
}
