/// Plan de suscripción de un cliente (075): son 3 fijos (Local/Multisede/Gran Grupo), el admin
/// solo edita su precio, su número máximo de sedes y su máximo de escaneos con IA al día (082,
/// se cuenta por sede), no puede crear, borrar ni renombrarlos.
class PlanSuscripcion {
  final String idConfiguracionPlanSuscripcion;
  final String nombre;
  final double precioMensual;
  final int maxSedes;

  /// Null = sin límite de escaneos con IA al día para cada sede de un cliente con este plan.
  final int? maxEscaneosIaPorDia;

  const PlanSuscripcion({
    required this.idConfiguracionPlanSuscripcion,
    required this.nombre,
    required this.precioMensual,
    required this.maxSedes,
    this.maxEscaneosIaPorDia,
  });

  factory PlanSuscripcion.fromMap(Map<String, dynamic> map) => PlanSuscripcion(
    idConfiguracionPlanSuscripcion:
        map['IdConfiguracionPlanSuscripcion'] as String,
    nombre: map['Nombre'] as String,
    precioMensual: (map['PrecioMensual'] as num).toDouble(),
    maxSedes: map['MaxSedes'] as int,
    maxEscaneosIaPorDia: map['MaxEscaneosIaPorDia'] as int?,
  );
}
