import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../../acto_tipos/data/acto_tipo.dart';
import '../../../acto_tipos/data/acto_tipos_repository.dart';

class ConfiguracionActoTiposScreen extends ConsumerWidget {
  const ConfiguracionActoTiposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actoTiposAsync = ref.watch(actoTiposListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionTiposActoTitulo)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/configuracion/tipos-acto/nueva'),
        child: const Icon(Icons.add),
      ),
      body: actoTiposAsync.when(
        data: (actoTipos) {
          if (actoTipos.isEmpty) {
            return EmptyState(
              message: context.l10n.noHayTiposActoDadosDeAlta,
              icon: Icons.church_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(actoTiposListProvider.future),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: actoTipos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final actoTipo = actoTipos[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.church_outlined),
                    title: Text(actoTipo.nombre),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!actoTipo.activo)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(label: Text(context.l10n.inactiva)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.eliminar,
                          onPressed: () => _eliminar(context, ref, actoTipo),
                        ),
                      ],
                    ),
                    onTap: () => context.push(
                      '/admin/configuracion/tipos-acto/${actoTipo.idConfiguracionActoTipo}',
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    ActoTipo actoTipo,
  ) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.actoTipoEliminarTitulo,
      message: context.l10n.actoTipoEliminarMensaje(actoTipo.nombre),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref
        .read(actoTiposRepositoryProvider)
        .eliminarActoTipo(actoTipo.idConfiguracionActoTipo);
    ref.invalidate(actoTiposListProvider);
  }
}
