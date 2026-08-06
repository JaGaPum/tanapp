class UsuariosStats {
  final int totalActivos;
  final int totalInactivos;
  final int totalConNotificacionesPush;
  final int totalSeguimientos;
  final int totalZonasSeguidas;
  final List<MapEntry<String, int>> porIdioma;
  final List<MapEntry<String, int>> topConcellos;

  const UsuariosStats({
    required this.totalActivos,
    required this.totalInactivos,
    required this.totalConNotificacionesPush,
    required this.totalSeguimientos,
    required this.totalZonasSeguidas,
    required this.porIdioma,
    required this.topConcellos,
  });
}
