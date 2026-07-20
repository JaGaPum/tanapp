import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../../cliente_tipos/data/cliente_tipo.dart';
import '../../../cliente_tipos/data/cliente_tipos_repository.dart';

class ConfiguracionClienteTiposScreen extends ConsumerWidget {
  const ConfiguracionClienteTiposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteTiposAsync = ref.watch(clienteTiposListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionTiposClienteTitulo)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/configuracion/tipos-cliente/nueva'),
        child: const Icon(Icons.add),
      ),
      body: clienteTiposAsync.when(
        data: (clienteTipos) {
          if (clienteTipos.isEmpty) {
            return EmptyState(message: context.l10n.noHayTiposClienteDadosDeAlta, icon: Icons.category_outlined);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(clienteTiposListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clienteTipos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final clienteTipo = clienteTipos[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(clienteTipo.nombre),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!clienteTipo.activo)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(label: Text(context.l10n.inactiva)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.eliminar,
                          onPressed: () => _eliminar(context, ref, clienteTipo),
                        ),
                      ],
                    ),
                    onTap: () => context.push(
                      '/admin/configuracion/tipos-cliente/${clienteTipo.idConfiguracionClienteTipo}',
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref, ClienteTipo clienteTipo) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.clienteTipoEliminarTitulo,
      message: context.l10n.clienteTipoEliminarMensaje(clienteTipo.nombre),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref.read(clienteTiposRepositoryProvider).eliminarClienteTipo(clienteTipo.idConfiguracionClienteTipo);
    ref.invalidate(clienteTiposListProvider);
  }
}
