import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sesion.dart';
import '../data/sesiones_repository.dart';

final usuarioSesionesProvider =
    FutureProvider.autoDispose.family<List<Sesion>, String>((ref, idSistemaUsuario) {
  return ref.watch(sesionesRepositoryProvider).listSesionesUsuario(idSistemaUsuario);
});
