import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/comunicacion.dart';
import '../data/comunicaciones_repository.dart';

final comunicacionesListProvider = FutureProvider.autoDispose<List<Comunicacion>>((ref) {
  return ref.watch(comunicacionesRepositoryProvider).listComunicaciones();
});

final comunicacionDetailProvider = FutureProvider.autoDispose.family<Comunicacion, String>((ref, id) {
  return ref.watch(comunicacionesRepositoryProvider).fetchById(id);
});
