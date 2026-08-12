import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_extensions.dart';
import 'app_button.dart';

/// Pantalla de bloqueo que sustituye al formulario de publicar/enviar avisos mientras el
/// cliente tenga alguna sede sin confirmar (ver "tieneSedeSinRenombrarProvider"): el nombre de
/// la sede es el que se usa en notificaciones, avisos y esquelas, así que no se deja continuar
/// hasta que el cliente lo revise (o cambie) desde "Mis sedes".
class SedeSinRenombrarBloqueo extends StatelessWidget {
  const SedeSinRenombrarBloqueo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.sedeSinRenombrarAviso,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: context.l10n.sedeSinRenombrarBoton,
              onPressed: () => context.push('/mis-sedes'),
            ),
          ],
        ),
      ),
    );
  }
}
