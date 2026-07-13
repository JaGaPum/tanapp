import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';

class SistemaScreen extends StatelessWidget {
  const SistemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.drawerSistema)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(context.l10n.gestionDeUsuarios),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/usuarios'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(context.l10n.solicitudesDeClientes),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/solicitudes'),
            ),
          ),
        ],
      ),
    );
  }
}
