/// Un pago registrado (083): cubre 30 días naturales desde "fechaPago" (lo calcula siempre la
/// base de datos, nunca se manda desde la app). Un cliente está "al día" si hoy cae dentro de la
/// cobertura de cualquiera de sus pagos -normalmente el último, pero no hace falta que "gane"
/// uno solo-.
class PagoSuscripcion {
  final String id;
  final DateTime fechaPago;
  final DateTime fechaFinCobertura;

  const PagoSuscripcion({
    required this.id,
    required this.fechaPago,
    required this.fechaFinCobertura,
  });

  bool get vigente {
    final ahora = DateTime.now();
    return !ahora.isBefore(fechaPago) && !ahora.isAfter(fechaFinCobertura);
  }

  factory PagoSuscripcion.fromMap(Map<String, dynamic> map) => PagoSuscripcion(
    id: map['IdSistemaUsuarioPago'] as String,
    fechaPago: DateTime.parse(map['FechaPago'] as String),
    fechaFinCobertura: DateTime.parse(map['FechaFinCobertura'] as String),
  );
}
