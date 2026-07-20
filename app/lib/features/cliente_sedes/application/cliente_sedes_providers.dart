import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/cliente_sede.dart';
import '../data/cliente_sedes_repository.dart';

final misSedesProvider = FutureProvider.autoDispose<List<ClienteSede>>((ref) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return [];
  return ref.watch(clienteSedesRepositoryProvider).listSedesDeUsuario(perfil.idSistemaUsuario);
});

final sedesDeUsuarioProvider = FutureProvider.autoDispose.family<List<ClienteSede>, String>((ref, idSistemaUsuario) {
  return ref.watch(clienteSedesRepositoryProvider).listSedesDeUsuario(idSistemaUsuario);
});
