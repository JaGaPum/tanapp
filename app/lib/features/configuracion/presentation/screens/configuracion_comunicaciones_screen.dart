import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../comunicaciones/application/comunicaciones_providers.dart';
import '../../../comunicaciones/data/comunicacion.dart';
import '../../../comunicaciones/data/comunicaciones_repository.dart';

class ConfiguracionComunicacionesScreen extends ConsumerWidget {
  const ConfiguracionComunicacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comunicacionesAsync = ref.watch(comunicacionesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionComunicacionesTitulo)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/configuracion/comunicaciones/nueva'),
        child: const Icon(Icons.add),
      ),
      body: comunicacionesAsync.when(
        data: (comunicaciones) {
          if (comunicaciones.isEmpty) {
            return EmptyState(message: context.l10n.noHayComunicacionesDadasDeAlta, icon: Icons.mail_outline);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(comunicacionesListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: comunicaciones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final comunicacion = comunicaciones[index];
                return Card(
                  child: ListTile(
                    leading: Icon(_iconoTipo(comunicacion.tipoComunicacion)),
                    title: Text(comunicacion.nombreComunicacion),
                    subtitle: Text('${comunicacion.codComunicacion} · ${comunicacion.tipoComunicacion}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!comunicacion.activo)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(label: Text(context.l10n.inactiva)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.eliminar,
                          onPressed: () => _eliminar(context, ref, comunicacion),
                        ),
                      ],
                    ),
                    onTap: () => context.push(
                      '/admin/configuracion/comunicaciones/${comunicacion.idConfiguracionComunicacion}',
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

  IconData _iconoTipo(String tipo) => switch (tipo) {
        'EMAIL' => Icons.email_outlined,
        'MENSAJE' => Icons.sms_outlined,
        _ => Icons.notifications_outlined,
      };

  Future<void> _eliminar(BuildContext context, WidgetRef ref, Comunicacion comunicacion) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.comunicacionEliminarTitulo,
      message: context.l10n.comunicacionEliminarMensaje(comunicacion.nombreComunicacion),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref.read(comunicacionesRepositoryProvider).eliminarComunicacion(comunicacion.idConfiguracionComunicacion);
    ref.invalidate(comunicacionesListProvider);
  }
}
