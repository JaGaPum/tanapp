import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../data/publicacion_con_sede.dart';
import '../data/publicaciones_repository.dart';

final publicacionesTablonProvider = FutureProvider.autoDispose<List<PublicacionConSede>>((ref) {
  return ref.watch(publicacionesRepositoryProvider).listTodas();
});

final publicacionesPorSedeProvider =
    FutureProvider.autoDispose.family<List<PublicacionConSede>, String>((ref, idClienteSede) {
  return ref.watch(publicacionesRepositoryProvider).listPorSedes([idClienteSede]);
});

final misPublicacionesProvider = FutureProvider.autoDispose<List<PublicacionConSede>>((ref) async {
  final sedes = await ref.watch(misSedesProvider.future);
  return ref.watch(publicacionesRepositoryProvider).listPorSedes(sedes.map((s) => s.idClienteSede).toList());
});

final misPublicacionesArchivadasIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) {
  return ref.watch(publicacionesRepositoryProvider).listMisArchivadasIds();
});

final misPublicacionesArchivadasProvider = FutureProvider.autoDispose<List<PublicacionConSede>>((ref) {
  return ref.watch(publicacionesRepositoryProvider).listMisArchivadas();
});
