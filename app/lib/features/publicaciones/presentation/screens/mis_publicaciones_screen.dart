import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicacion_con_sede.dart';
import '../../data/publicaciones_repository.dart';
import '../widgets/publicacion_detalle.dart';

class MisPublicacionesScreen extends ConsumerWidget {
  const MisPublicacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicacionesAsync = ref.watch(misPublicacionesProvider);

    return publicacionesAsync.when(
      data: (publicaciones) {
        if (publicaciones.isEmpty) {
          return EmptyState(message: context.l10n.publicarSinPublicaciones, icon: Icons.campaign_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: publicaciones.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _MiPublicacionCard(publicacion: publicaciones[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

class _MiPublicacionCard extends ConsumerStatefulWidget {
  final PublicacionConSede publicacion;
  const _MiPublicacionCard({required this.publicacion});

  @override
  ConsumerState<_MiPublicacionCard> createState() => _MiPublicacionCardState();
}

class _MiPublicacionCardState extends ConsumerState<_MiPublicacionCard> {
  bool _eliminando = false;

  Future<void> _editar() async {
    final publicacion = widget.publicacion;
    await context.push(
      '/publicar/manual',
      extra: {
        'idClientePublicacion': publicacion.idClientePublicacion,
        'idClienteSede': publicacion.idClienteSede,
        'nombre': publicacion.nombreFallecido,
        'fechaFallecimiento': publicacion.fechaFallecimiento?.toIso8601String(),
        'edad': publicacion.edad?.toString(),
        'fechaFuneral': publicacion.fechaFuneral?.toIso8601String(),
        'horaFuneral': publicacion.horaFuneral,
        'iglesia': publicacion.iglesia,
        'lugar': publicacion.lugar,
        'capillaArdiente': publicacion.capillaArdiente,
        'sala': publicacion.sala,
        'observaciones': publicacion.observaciones,
      },
    );
  }

  Future<void> _eliminar() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.publicarEliminarTitulo,
      message: context.l10n.publicarEliminarMensaje(widget.publicacion.nombreFallecido),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _eliminando = true);
    try {
      await ref.read(publicacionesRepositoryProvider).eliminarPublicacion(widget.publicacion.idClientePublicacion);
      ref.invalidate(misPublicacionesProvider);
      ref.invalidate(publicacionesTablonProvider);
      ref.invalidate(publicacionesPorSedeProvider(widget.publicacion.idClienteSede));
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicacion = widget.publicacion;
    final escala = ref.watch(escalaTextoProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(escala)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(publicacion.nombreFallecido, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(publicacion.concello, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  PublicacionDetalle(publicacion: publicacion),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(publicacion.fechaAlta.toLocal()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.editar),
                  onPressed: _eliminando ? null : _editar,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.l10n.eliminar),
                  onPressed: _eliminando ? null : _eliminar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
