import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/acto_tipo.dart';
import '../data/acto_tipos_repository.dart';

final actoTiposListProvider = FutureProvider.autoDispose<List<ActoTipo>>((ref) {
  return ref.watch(actoTiposRepositoryProvider).listActoTipos();
});

final actoTipoDetailProvider = FutureProvider.autoDispose
    .family<ActoTipo, String>((ref, id) {
      return ref.watch(actoTiposRepositoryProvider).fetchById(id);
    });
