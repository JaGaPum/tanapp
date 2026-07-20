import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../seguidos/application/seguidos_providers.dart';
import '../../../seguidos/data/seguidores_resumen.dart';

class PanelDatosScreen extends ConsumerWidget {
  const PanelDatosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sedesAsync = ref.watch(misSedesProvider);
    final publicacionesAsync = ref.watch(misPublicacionesProvider);
    final seguidoresAsync = ref.watch(misSeguidoresPorSedeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SeccionCard(
            icon: Icons.campaign_outlined,
            titulo: context.l10n.panelDatosPublicaciones,
            child: sedesAsync.when(
              data: (sedes) => publicacionesAsync.when(
                data: (publicaciones) {
                  final porSede = {for (final sede in sedes) sede.idClienteSede: 0};
                  for (final publicacion in publicaciones) {
                    porSede[publicacion.idClienteSede] = (porSede[publicacion.idClienteSede] ?? 0) + 1;
                  }
                  final maxCount = porSede.values.isEmpty ? 0 : porSede.values.reduce((a, b) => a > b ? a : b);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${publicaciones.length}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      for (final sede in sedes)
                        _BarraFila(
                          label: '${sede.codigo} · ${sede.nombre}',
                          value: porSede[sede.idClienteSede] ?? 0,
                          maxValue: maxCount,
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ),
          const SizedBox(height: 16),
          _SeccionCard(
            icon: Icons.favorite_border,
            titulo: context.l10n.panelDatosSeguidores,
            child: seguidoresAsync.when(
              data: (porSede) => _SeguidoresContenido(porSede: porSede),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeguidoresContenido extends StatelessWidget {
  final List<SeguidoresPorSede> porSede;
  const _SeguidoresContenido({required this.porSede});

  @override
  Widget build(BuildContext context) {
    final total = porSede.fold<int>(0, (suma, sede) => suma + sede.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$total',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        for (final sede in porSede) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${sede.codigoSede} · ${sede.nombreSede}',
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${sede.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (sede.porConcello.isEmpty) ...[
            const SizedBox(height: 4),
            Text(context.l10n.panelDatosSinSeguidores, style: Theme.of(context).textTheme.bodyMedium),
          ] else ...[
            const SizedBox(height: 8),
            for (final entrada in sede.porConcello)
              _BarraFila(
                label: entrada.key.isEmpty ? context.l10n.panelDatosConcelloDesconocido : entrada.key,
                value: entrada.value,
                maxValue: sede.porConcello.first.value,
              ),
          ],
        ],
      ],
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Widget child;

  const _SeccionCard({required this.icon, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(titulo, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _BarraFila extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const _BarraFila({required this.label, required this.value, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final fraccion = maxValue == 0 ? 0.0 : value / maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraccion,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
