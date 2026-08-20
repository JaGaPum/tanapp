import 'conteo_por_periodo.dart';

class UsuariosStats {
  final int totalActivos;
  final int totalInactivos;
  final int totalConNotificacionesPush;
  final int totalSeguimientos;
  final int totalZonasSeguidas;
  final List<MapEntry<String, int>> porIdioma;
  final List<MapEntry<String, int>> topConcellos;
  final List<ConteoPorPeriodo> altasPorMes;
  final List<ConteoPorPeriodo> bajasPorMes;

  const UsuariosStats({
    required this.totalActivos,
    required this.totalInactivos,
    required this.totalConNotificacionesPush,
    required this.totalSeguimientos,
    required this.totalZonasSeguidas,
    required this.porIdioma,
    required this.topConcellos,
    required this.altasPorMes,
    required this.bajasPorMes,
  });
}
