/// Seguidores de una sede propia: total y desglose por el concello del propio seguidor (no el
/// de la sede), ordenado de más a menos.
class SeguidoresPorSede {
  final String idClienteSede;
  final String codigoSede;
  final String nombreSede;
  final int total;
  final List<MapEntry<String, int>> porConcello;

  const SeguidoresPorSede({
    required this.idClienteSede,
    required this.codigoSede,
    required this.nombreSede,
    required this.total,
    required this.porConcello,
  });
}
