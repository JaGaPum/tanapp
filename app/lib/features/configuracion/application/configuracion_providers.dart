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
