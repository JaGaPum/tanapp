/// Un seguimiento (usuario que sigue una sede propia), con el concello del propio seguidor
/// (no el de la sede): lo justo para desglosar el número de seguidores de cada sede por zona.
class SeguimientoSedeInfo {
  final String idSistemaUsuario;
  final String idClienteSede;
  final String? concelloSeguidor;

  const SeguimientoSedeInfo({
    required this.idSistemaUsuario,
    required this.idClienteSede,
    required this.concelloSeguidor,
  });
}
