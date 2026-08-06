import 'conteo_por_periodo.dart';

/// Precio aproximado por token del modelo usado en "escanear-esquela-imagen" (claude-sonnet-5),
/// en dólares por token: ajustar aquí si cambia el precio publicado por Anthropic o el modelo.
/// Es solo una estimación nuestra a partir de los tokens que devuelve cada respuesta, no el
/// saldo real de la cuenta (eso solo lo da la consola de Anthropic).
const precioPorTokenEntrada = 3 / 1000000;
const precioPorTokenSalida = 15 / 1000000;

double costoEstimado({required int tokensEntrada, required int tokensSalida}) =>
    tokensEntrada * precioPorTokenEntrada + tokensSalida * precioPorTokenSalida;

class IaUsoPorUsuario {
  final String idSistemaUsuario;
  final String nombreUsuario;
  final int peticiones;
  final double costoEstimado;

  const IaUsoPorUsuario({
    required this.idSistemaUsuario,
    required this.nombreUsuario,
    required this.peticiones,
    required this.costoEstimado,
  });
}

class IaStats {
  final int peticionesHoy;
  final int peticionesMes;
  final int peticionesTotal;
  final double costoHoy;
  final double costoMes;
  final double costoTotal;
  final double tasaExito;
  final List<ConteoPorPeriodo> peticionesPorDia;
  final List<IaUsoPorUsuario> usoPorUsuarioEsteMes;

  const IaStats({
    required this.peticionesHoy,
    required this.peticionesMes,
    required this.peticionesTotal,
    required this.costoHoy,
    required this.costoMes,
    required this.costoTotal,
    required this.tasaExito,
    required this.peticionesPorDia,
    required this.usoPorUsuarioEsteMes,
  });
}
