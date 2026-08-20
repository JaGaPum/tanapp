import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/suplantacion_providers.dart';

/// Franja fija arriba de la app mientras hay una sesión secundaria activa, para que nunca se
/// olvide de que no se está en la cuenta original. Cubre dos casos (ver [ModoSesionSecundaria]):
/// un administrador suplantando a otro usuario, o un cliente en su cuenta personal vinculada.
/// Solo se muestra cuando hay una sesión secundaria guardada (ver [sesionAdminGuardadaProvider]).
class BannerSuplantacion extends ConsumerWidget {
  const BannerSuplantacion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secundaria = ref.watch(sesionAdminGuardadaProvider);
    if (secundaria == null) {
      return const SizedBox.shrink();
    }
    final esCuentaPropia = secundaria.modo == ModoSesionSecundaria.cuentaPropia;
    final nombre =
        ref.watch(currentUserProfileProvider).value?.nombrePublico ?? '';

    return Material(
      color: esCuentaPropia
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.error,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                esCuentaPropia
                    ? Icons.switch_account_outlined
                    : Icons.visibility_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esCuentaPropia
                      ? context.l10n.cuentaPropiaBannerTexto
                      : context.l10n.suplantacionBannerTexto(nombre),
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
                child: Text(
                  esCuentaPropia
                      ? context.l10n.cuentaPropiaVolver
                      : context.l10n.suplantacionVolver,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
