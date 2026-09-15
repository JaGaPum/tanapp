import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/estado_suscripcion.dart';
import '../data/pago_suscripcion.dart';
import '../data/periodo_gratuito.dart';
import '../data/plan_suscripcion.dart';
import '../data/planes_suscripcion_repository.dart';

final planesSuscripcionListProvider =
    FutureProvider.autoDispose<List<PlanSuscripcion>>((ref) {
      return ref.watch(planesSuscripcionRepositoryProvider).listPlanes();
    });

final miEstadoSuscripcionProvider =
    FutureProvider.autoDispose<EstadoSuscripcion?>((ref) {
      return ref
          .watch(planesSuscripcionRepositoryProvider)
          .fetchMiEstadoSuscripcion();
    });

/// Periodos gratuitos propios de un cliente (080), para gestionarlos desde su ficha.
final periodosGratuitosClienteProvider = FutureProvider.autoDispose
    .family<List<PeriodoGratuito>, String>((ref, idSistemaUsuario) {
      return ref
          .watch(planesSuscripcionRepositoryProvider)
          .listPeriodosGratuitosCliente(idSistemaUsuario);
    });

/// Historial de pagos de un cliente (083): lo usan tanto la ficha del ADMIN como "Mi
/// suscripción" del propio cliente (la RLS decide qué puede ver cada uno).
final pagosClienteProvider = FutureProvider.autoDispose
    .family<List<PagoSuscripcion>, String>((ref, idSistemaUsuario) {
      return ref
          .watch(planesSuscripcionRepositoryProvider)
          .listPagosCliente(idSistemaUsuario);
    });
