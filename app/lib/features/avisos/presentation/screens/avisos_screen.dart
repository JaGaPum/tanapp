import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';

class AvisosScreen extends ConsumerWidget {
  const AvisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return EmptyState(message: context.l10n.proximamente, icon: Icons.notifications_outlined);
    }

    final pendientesAsync = ref.watch(solicitudesPendientesCountProvider);
    return pendientesAsync.when(
      data: (pendientes) {
        if (pendientes == 0) {
          return EmptyState(message: context.l10n.proximamente, icon: Icons.notifications_outlined);
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_late_outlined, color: Colors.red),
                title: Text(context.l10n.avisoSolicitudesPendientes(pendientes)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/solicitudes'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}
