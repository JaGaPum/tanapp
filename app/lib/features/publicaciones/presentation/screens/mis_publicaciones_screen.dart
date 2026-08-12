import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicacion_con_sede.dart';
import '../../data/publicaciones_repository.dart';
import '../widgets/publicacion_card.dart';

class MisPublicacionesScreen extends ConsumerWidget {
  const MisPublicacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicacionesAsync = ref.watch(misPublicacionesProvider);

    return publicacionesAsync.when(
      data: (publicaciones) {
        if (publicaciones.isEmpty) {
          return EmptyState(
            message: context.l10n.publicarSinPublicaciones,
            icon: Icons.campaign_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: publicaciones.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _MiPublicacionCard(publicacion: publicaciones[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

/// Delega todo el aspecto visual en [PublicacionCard] (con [PublicacionCard.esPropia]): esta
/// clase solo aporta las acciones propias del dueño (editar/eliminar) y su estado de carga.
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
      message: context.l10n.publicarEliminarMensaje(
        widget.publicacion.nombreFallecido,
      ),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _eliminando = true);
    try {
      await ref
          .read(publicacionesRepositoryProvider)
          .eliminarPublicacion(widget.publicacion.idClientePublicacion);
      ref.invalidate(misPublicacionesProvider);
      ref.invalidate(publicacionesTablonProvider);
      ref.invalidate(
        publicacionesPorSedeProvider(widget.publicacion.idClienteSede),
      );
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PublicacionCard(
      publicacion: widget.publicacion,
      esPropia: true,
      eliminando: _eliminando,
      onEditar: _editar,
      onEliminar: _eliminar,
    );
  }
}
