/// Cuántas publicaciones se crearon en un mes concreto, para la gráfica de actividad del Panel
/// de Datos del cliente.
class PublicacionesPorMes {
  final DateTime mes;
  final int total;

  const PublicacionesPorMes({required this.mes, required this.total});
}
