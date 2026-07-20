import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/cliente_sedes_providers.dart';
import '../../data/cliente_sede.dart';
import '../../data/cliente_sedes_repository.dart';
import '../widgets/sede_form_dialog.dart';

class MisSedesScreen extends ConsumerWidget {
  const MisSedesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sedesAsync = ref.watch(misSedesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.misSedesTitulo)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: sedesAsync.when(
        data: (sedes) {
          if (sedes.isEmpty) {
            return EmptyState(message: context.l10n.misSedesVacio, icon: Icons.storefront_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sedes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sede = sedes[index];
              return Card(
                child: ListTile(
                  title: Text('${sede.codigo} · ${sede.nombre}'),
                  subtitle: Text('${sede.direccion}, ${sede.concello}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: context.l10n.editar,
                        onPressed: () => _mostrarFormulario(context, ref, sede: sede),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: context.l10n.eliminar,
                        onPressed: () => _eliminar(context, ref, sede, sedes.length),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref, ClienteSede sede, int totalSedes) async {
    if (totalSedes <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.misSedesUltimaSedeAviso)));
      return;
    }
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.misSedesEliminarTitulo,
      message: context.l10n.misSedesEliminarMensaje(sede.nombre),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref.read(clienteSedesRepositoryProvider).eliminarSede(sede.idClienteSede);
    ref.invalidate(misSedesProvider);
  }

  Future<void> _mostrarFormulario(BuildContext context, WidgetRef ref, {ClienteSede? sede}) async {
    final perfil = await ref.read(currentUserProfileProvider.future);
    if (perfil == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => SedeFormDialog(idSistemaUsuario: perfil.idSistemaUsuario, sede: sede),
    );
    ref.invalidate(misSedesProvider);
  }
}
