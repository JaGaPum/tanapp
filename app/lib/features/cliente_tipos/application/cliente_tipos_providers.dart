import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cliente_tipo.dart';
import '../data/cliente_tipos_repository.dart';

final clienteTiposListProvider = FutureProvider.autoDispose<List<ClienteTipo>>((ref) {
  return ref.watch(clienteTiposRepositoryProvider).listClienteTipos();
});

final clienteTipoDetailProvider = FutureProvider.autoDispose.family<ClienteTipo, String>((ref, id) {
  return ref.watch(clienteTiposRepositoryProvider).fetchById(id);
});
