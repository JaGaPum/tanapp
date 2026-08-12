import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/cliente_sede.dart';
import '../data/cliente_sedes_repository.dart';

final misSedesProvider = FutureProvider.autoDispose<List<ClienteSede>>((
  ref,
) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return [];
  return ref
      .watch(clienteSedesRepositoryProvider)
      .listSedesDeUsuario(perfil.idSistemaUsuario);
});

final sedesDeUsuarioProvider = FutureProvider.autoDispose
    .family<List<ClienteSede>, String>((ref, idSistemaUsuario) {
      return ref
          .watch(clienteSedesRepositoryProvider)
          .listSedesDeUsuario(idSistemaUsuario);
    });

/// True si el cliente tiene alguna sede sin "NombreConfirmado" (ver "ClienteSede"): se usa para
/// bloquear publicar esquelas y enviar avisos hasta que la revise o cambie desde "Mis sedes".
final tieneSedeSinRenombrarProvider = Provider.autoDispose<bool>((ref) {
  final sedes = ref.watch(misSedesProvider).value ?? const [];
  return sedes.any((s) => !s.nombreConfirmado);
});
