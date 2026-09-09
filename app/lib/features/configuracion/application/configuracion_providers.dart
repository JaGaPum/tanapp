import 'package:flutter_riverpod/flutter_riverpod.dart';

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
