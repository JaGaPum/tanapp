import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../configuracion/data/configuracion_repository.dart';
import '../../application/planes_suscripcion_providers.dart';
import '../../data/periodo_gratuito.dart';
import '../widgets/periodo_gratuito_form_dialog.dart';
import '../widgets/periodo_gratuito_tile.dart';
import '../widgets/plan_form_dialog.dart';

class ConfiguracionPlanesScreen extends ConsumerWidget {
  const ConfiguracionPlanesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planesAsync = ref.watch(planesSuscripcionListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.planesTitulo)),
      body: planesAsync.when(
        data: (planes) => ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            const _PeriodosGratuitosCard(),
            const SizedBox(height: 24),
            Text(
              context.l10n.planesExplicacion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            for (final plan in planes) ...[
              Card(
                child: ListTile(
                  title: Text(
                    plan.nombre,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  isThreeLine: true,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.planesPrecioYSedes(
                          plan.precioMensual.toStringAsFixed(2),
                          plan.maxSedes,
                        ),
                      ),
                      Text(
                        plan.maxEscaneosIaPorDia != null
                            ? context.l10n.planesEscaneosIaPorSede(
                                plan.maxEscaneosIaPorDia!,
                              )
                            : context.l10n.planesEscaneosIaSinLimite,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: context.l10n.editar,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => PlanFormDialog(plan: plan),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

/// Periodos gratuitos generales (080), antes de empezar a cobrar de verdad: mientras alguno esté
/// activo, ningún cliente se bloquea por "PlanPagado" aunque no lo tenga marcado. Pueden convivir
/// varios a la vez (los caducados se quedan como histórico). Cada cliente puede tener además los
/// suyos propios (ver su ficha), que se suman a estos -no hace falta que "gane" uno solo-.
class _PeriodosGratuitosCard extends ConsumerWidget {
  const _PeriodosGratuitosCard();

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (_) => PeriodoGratuitoFormDialog(
        onGuardar: ({required inicio, fin}) => ref
            .read(configuracionRepositoryProvider)
            .crearPeriodoGratuitoGlobal(inicio: inicio, fin: fin),
      ),
    );
    ref.invalidate(periodosGratuitosGlobalesProvider);
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref,
    PeriodoGratuito periodo,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => PeriodoGratuitoFormDialog(
        periodo: periodo,
        onGuardar: ({required inicio, fin}) => ref
            .read(configuracionRepositoryProvider)
            .actualizarPeriodoGratuitoGlobal(
              idConfiguracionPeriodoGratuito: periodo.id,
              inicio: inicio,
              fin: fin,
            ),
      ),
    );
    ref.invalidate(periodosGratuitosGlobalesProvider);
  }

  Future<void> _eliminar(WidgetRef ref, String id) async {
    await ref
        .read(configuracionRepositoryProvider)
        .eliminarPeriodoGratuitoGlobal(id);
    ref.invalidate(periodosGratuitosGlobalesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodosAsync = ref.watch(periodosGratuitosGlobalesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.periodoGratuitoTitulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.periodoGratuitoExplicacion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            periodosAsync.when(
              data: (periodos) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (periodos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        context.l10n.periodoGratuitoNinguno,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    for (final periodo in periodos)
                      PeriodoGratuitoTile(
                        periodo: periodo,
                        onEditar: () => _editar(context, ref, periodo),
                        onEliminar: () => _eliminar(ref, periodo.id),
                      ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(context.l10n.periodoGratuitoNuevo),
              onPressed: () => _crear(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
