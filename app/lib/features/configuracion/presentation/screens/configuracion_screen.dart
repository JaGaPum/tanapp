import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.drawerConfiguracion)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.map_outlined),
              title: Text(context.l10n.provincias),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/configuracion/provincias'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(context.l10n.comunicaciones),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/configuracion/comunicaciones'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text(context.l10n.tiposCliente),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/configuracion/tipos-cliente'),
            ),
          ),
        ],
      ),
    );
  }
}
