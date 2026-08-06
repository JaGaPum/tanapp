import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/zona_seguida.dart';
import '../data/zonas_seguidas_repository.dart';

final misZonasProvider = FutureProvider.autoDispose<List<ZonaSeguida>>((ref) {
  return ref.watch(zonasSeguidasRepositoryProvider).listMisZonas();
});

final misZonasConcellosProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) {
  return ref.watch(zonasSeguidasRepositoryProvider).listMisZonasConcellos();
});
