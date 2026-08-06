import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../sistema_usuarios/data/catalogos_repository.dart';
import '../data/clientes_stats.dart';
import '../data/dashboard_repository.dart';
import '../data/ia_stats.dart';
import '../data/usuarios_stats.dart';

final clientesStatsProvider = FutureProvider.autoDispose<ClientesStats>((
  ref,
) async {
  final stats = await ref
      .watch(dashboardRepositoryProvider)
      .fetchClientesStats();
  final tipos = await ref.watch(clienteTiposListProvider.future);
  final nombrePorId = {
    for (final t in tipos) t.idConfiguracionClienteTipo: t.nombre,
  };
  return ClientesStats(
    totalActivos: stats.totalActivos,
    totalInactivos: stats.totalInactivos,
    totalSedes: stats.totalSedes,
    totalPublicaciones: stats.totalPublicaciones,
    totalAvisos: stats.totalAvisos,
    porTipo:
        stats.porTipo
            .map((e) => MapEntry(nombrePorId[e.key] ?? e.key, e.value))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
    publicacionesPorMes: stats.publicacionesPorMes,
    avisosPorMes: stats.avisosPorMes,
    topClientesPorPublicaciones: stats.topClientesPorPublicaciones,
  );
});

final usuariosStatsProvider = FutureProvider.autoDispose<UsuariosStats>((
  ref,
) async {
  final stats = await ref
      .watch(dashboardRepositoryProvider)
      .fetchUsuariosStats();
  final idiomas = await ref.watch(idiomasCatalogoProvider.future);
  final nombrePorId = {for (final i in idiomas) i.idSistemaIdioma: i.nombre};
  return UsuariosStats(
    totalActivos: stats.totalActivos,
    totalInactivos: stats.totalInactivos,
    totalConNotificacionesPush: stats.totalConNotificacionesPush,
    totalSeguimientos: stats.totalSeguimientos,
    totalZonasSeguidas: stats.totalZonasSeguidas,
    porIdioma:
        stats.porIdioma
            .map((e) => MapEntry(nombrePorId[e.key] ?? e.key, e.value))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
    topConcellos: stats.topConcellos,
  );
});

final iaStatsProvider = FutureProvider.autoDispose<IaStats>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchIaStats();
});
