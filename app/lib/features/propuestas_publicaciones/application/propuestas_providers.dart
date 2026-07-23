import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/propuestas_repository.dart';
import '../data/publicacion_propuesta.dart';

final propuestasPendientesProvider = FutureProvider.autoDispose<List<PublicacionPropuesta>>((ref) {
  return ref.watch(propuestasRepositoryProvider).listPendientes();
});

final propuestasPendientesCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(propuestasPendientesProvider).maybeWhen(data: (lista) => lista.length, orElse: () => 0);
});
