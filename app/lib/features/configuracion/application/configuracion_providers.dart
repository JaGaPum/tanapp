import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/concello.dart';
import '../data/configuracion_repository.dart';
import '../data/provincia.dart';

final provinciasProvider = FutureProvider.autoDispose<List<Provincia>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listProvincias();
});

final concellosPorProvinciaProvider =
    FutureProvider.autoDispose.family<List<Concello>, String>((ref, idConfiguracionProvincia) {
  return ref.watch(configuracionRepositoryProvider).listConcellosPorProvincia(idConfiguracionProvincia);
});

/// Interruptor global de la importación de esquelas con IA (ver migración 030): si es false,
/// nadie puede activar su importación web ni ver propuestas, aunque ya la tuviera configurada.
final importacionWebIaActivaProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(configuracionRepositoryProvider).fetchImportacionWebIaActiva();
});
