import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cliente_importacion_web.dart';
import '../data/importacion_web_repository.dart';

final miImportacionWebProvider = FutureProvider.autoDispose<ClienteImportacionWeb?>((ref) {
  return ref.watch(importacionWebRepositoryProvider).fetchPropia();
});
