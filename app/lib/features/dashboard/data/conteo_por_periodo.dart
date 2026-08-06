/// Cuántos eventos (publicaciones, avisos, peticiones de IA...) hubo en un periodo concreto
/// (un día o un mes, según lo agregue quien lo construya): genérico para cualquier gráfica de
/// actividad del Dashboard del administrador.
class ConteoPorPeriodo {
  final DateTime periodo;
  final int total;

  const ConteoPorPeriodo({required this.periodo, required this.total});
}
