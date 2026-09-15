import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../planes_suscripcion/data/periodo_gratuito.dart';
import '../data/concello.dart';
import '../data/configuracion_repository.dart';
import '../data/provincia.dart';

final provinciasProvider = FutureProvider.autoDispose<List<Provincia>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listProvincias();
});

final concellosPorProvinciaProvider = FutureProvider.autoDispose
    .family<List<Concello>, String>((ref, idConfiguracionProvincia) {
      return ref
          .watch(configuracionRepositoryProvider)
          .listConcellosPorProvincia(idConfiguracionProvincia);
    });

/// Interruptor global de la importación de esquelas con IA (ver migración 030): si es false,
/// nadie puede activar su importación web ni ver propuestas, aunque ya la tuviera configurada.
final importacionWebIaActivaProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref
      .watch(configuracionRepositoryProvider)
      .fetchImportacionWebIaActiva();
});

/// Interruptor global del escaneo de esquelas por foto con IA (ver migración 041), independiente
/// del de importación web: si es false, la pantalla de escanear usa el OCR local de siempre.
final escaneoEsquelaIaActivaProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref
      .watch(configuracionRepositoryProvider)
      .fetchEscaneoEsquelaIaActiva();
});

/// Interruptores globales de los botones de login social (073): se leen también desde la
/// pantalla de login, antes de haber iniciado sesión.
final googleLoginActivoProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(configuracionRepositoryProvider).fetchGoogleLoginActivo();
});

final facebookLoginActivoProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(configuracionRepositoryProvider).fetchFacebookLoginActivo();
});

final appleLoginActivoProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(configuracionRepositoryProvider).fetchAppleLoginActivo();
});

/// Periodos gratuitos generales (080): la lista completa (activos e histórico), para gestionarla
/// en Configuración > Planes. La comprobación real de si un cliente está en periodo gratuito la
/// hace la base de datos (trigger + RPC), esto es solo para mostrarla/editarla.
final periodosGratuitosGlobalesProvider =
    FutureProvider.autoDispose<List<PeriodoGratuito>>((ref) {
      return ref
          .watch(configuracionRepositoryProvider)
          .listPeriodosGratuitosGlobales();
    });
