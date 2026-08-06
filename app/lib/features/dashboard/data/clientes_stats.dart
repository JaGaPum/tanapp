import 'conteo_por_periodo.dart';

class ClientesStats {
  final int totalActivos;
  final int totalInactivos;
  final int totalSedes;
  final int totalPublicaciones;
  final int totalAvisos;
  final List<MapEntry<String, int>> porTipo;
  final List<ConteoPorPeriodo> publicacionesPorMes;
  final List<ConteoPorPeriodo> avisosPorMes;
  final List<MapEntry<String, int>> topClientesPorPublicaciones;

  const ClientesStats({
    required this.totalActivos,
    required this.totalInactivos,
    required this.totalSedes,
    required this.totalPublicaciones,
    required this.totalAvisos,
    required this.porTipo,
    required this.publicacionesPorMes,
    required this.avisosPorMes,
    required this.topClientesPorPublicaciones,
  });
}
