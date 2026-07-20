import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../sistema_usuarios/data/usuario_perfil.dart';
import '../../sistema_usuarios/data/usuarios_repository.dart';
import '../data/auth_repository.dart';

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

/// Se apoya en [authStateChangesProvider] únicamente para recalcular cuando cambia la sesión;
/// el usuario actual se lee de forma síncrona desde el cliente de Supabase.
final currentUserProfileProvider = FutureProvider.autoDispose<UsuarioPerfil?>((ref) async {
  ref.watch(authStateChangesProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  final repo = ref.watch(usuariosRepositoryProvider);
  return repo.fetchPerfilByAuthId(user.id);
});

final isAdminProvider = Provider.autoDispose<bool>((ref) {
  final perfilAsync = ref.watch(currentUserProfileProvider);
  return perfilAsync.maybeWhen(data: (p) => p?.roles.contains('ADMIN') ?? false, orElse: () => false);
});

final esUsuarioOrdinarioProvider = Provider.autoDispose<bool>((ref) {
  final perfilAsync = ref.watch(currentUserProfileProvider);
  return perfilAsync.maybeWhen(
    data: (p) => p?.roles.contains('USUARIO_ORDINARIO') ?? false,
    orElse: () => false,
  );
});

final isClienteProvider = Provider.autoDispose<bool>((ref) {
  final perfilAsync = ref.watch(currentUserProfileProvider);
  return perfilAsync.maybeWhen(data: (p) => p?.roles.contains('CLIENTE') ?? false, orElse: () => false);
});
