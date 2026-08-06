import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/suplantacion_providers.dart';

/// Franja fija arriba de la app mientras un administrador está suplantando a otro usuario, para
/// que nunca se olvide de que no está en su propia cuenta. Solo se muestra cuando hay una
/// sesión de administrador guardada (ver [sesionAdminGuardadaProvider]).
class BannerSuplantacion extends ConsumerWidget {
  const BannerSuplantacion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sesionAdminGuardadaProvider) == null) {
      return const SizedBox.shrink();
    }
    final nombre =
        ref.watch(currentUserProfileProvider).value?.nombrePublico ?? '';

    return Material(
      color: Theme.of(context).colorScheme.error,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.suplantacionBannerTexto(nombre),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  await ref.read(sesionAdminGuardadaProvider.notifier).volver();
                  if (context.mounted) context.go('/home');
                },
                child: Text(context.l10n.suplantacionVolver),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
