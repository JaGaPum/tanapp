import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/propuestas_providers.dart';
import '../../data/propuestas_repository.dart';
import '../../data/publicacion_propuesta.dart';

class PropuestasScreen extends ConsumerWidget {
  const PropuestasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propuestasAsync = ref.watch(propuestasPendientesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.propuestasTitulo)),
      body: propuestasAsync.when(
        data: (propuestas) {
          if (propuestas.isEmpty) {
            return EmptyState(message: context.l10n.propuestasVacio, icon: Icons.fact_check_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: propuestas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _PropuestaCard(propuesta: propuestas[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _PropuestaCard extends ConsumerStatefulWidget {
  final PublicacionPropuesta propuesta;
  const _PropuestaCard({required this.propuesta});

  @override
  ConsumerState<_PropuestaCard> createState() => _PropuestaCardState();
}

class _PropuestaCardState extends ConsumerState<_PropuestaCard> {
  bool _procesando = false;

  Future<void> _revisar() async {
    final p = widget.propuesta;
    await context.push(
      '/publicar/manual',
      extra: {
        'idClientePublicacionPropuesta': p.idClientePublicacionPropuesta,
        'nombre': p.nombreFallecido,
        'fechaFallecimiento': p.fechaFallecimiento?.toIso8601String(),
        'edad': p.edad?.toString(),
        'fechaFuneral': p.fechaFuneral?.toIso8601String(),
        'horaFuneral': p.horaFuneral,
        'iglesia': p.iglesia,
        'lugar': p.lugar,
        'capillaArdiente': p.capillaArdiente,
        'sala': p.sala,
        'observaciones': p.observaciones,
        'avisoOcr': context.l10n.publicarAvisoImportadoWeb,
      },
    );
    ref.invalidate(propuestasPendientesProvider);
  }

  Future<void> _descartar() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.propuestasConfirmarDescartarTitulo,
      message: context.l10n.propuestasConfirmarDescartarMensaje(widget.propuesta.nombreFallecido),
      confirmLabel: context.l10n.propuestasDescartar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref.read(propuestasRepositoryProvider).descartar(widget.propuesta.idClientePublicacionPropuesta);
      ref.invalidate(propuestasPendientesProvider);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.propuesta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.nombreFallecido, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              context.l10n.propuestasDetectadaEl(DateFormat('dd/MM/yyyy').format(p.fechaAlta.toLocal())),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(context.l10n.propuestasRevisar),
                  onPressed: _procesando ? null : _revisar,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(context.l10n.propuestasDescartar),
                  onPressed: _procesando ? null : _descartar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
