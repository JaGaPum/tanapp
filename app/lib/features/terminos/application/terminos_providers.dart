import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../data/termino.dart';
import '../data/terminos_repository.dart';

final terminosPendientesProvider = FutureProvider.autoDispose<List<Termino>>((ref) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return const [];
  final idiomaCodigo = ref.watch(appLocaleProvider).languageCode == 'gl' ? 'GL' : 'ES';
  return ref.watch(terminosRepositoryProvider).fetchPendientes(perfil.idSistemaUsuario, perfil.roles, idiomaCodigo);
});

final terminosActivosProvider = FutureProvider.autoDispose<List<Termino>>((ref) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return const [];
  final idiomaCodigo = ref.watch(appLocaleProvider).languageCode == 'gl' ? 'GL' : 'ES';
  return ref.watch(terminosRepositoryProvider).fetchActivos(perfil.roles, idiomaCodigo);
});
