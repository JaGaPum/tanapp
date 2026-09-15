import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/email_launcher.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/planes_suscripcion_providers.dart';
import '../../data/estado_suscripcion.dart';
import '../../data/plan_suscripcion.dart';
import '../widgets/pago_suscripcion_tile.dart';

const _emailSoporte = 'soporte_tanapp@tanapp.es';

/// Pantalla de autoservicio del cliente (078): su plan actual y el estado de su suscripción. El
/// pago en sí (pasarela) todavía no existe -queda para más adelante-, así que "Iniciar pago" por
/// ahora abre el correo a soporte, igual que "Contactar con soporte" en el resto de la app.
class MiSuscripcionScreen extends ConsumerWidget {
  const MiSuscripcionScreen({super.key});

  void _iniciarPago(BuildContext context) {
    enviarCorreo(
      destinatario: _emailSoporte,
      asunto: context.l10n.suscripcionIniciarPagoAsunto,
      cuerpo: '',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final planesAsync = ref.watch(planesSuscripcionListProvider);
    final estadoAsync = ref.watch(miEstadoSuscripcionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.suscripcionTitulo)),
      body: perfilAsync.when(
        data: (perfil) => planesAsync.when(
          data: (planes) => estadoAsync.when(
            data: (estado) {
              final plan = planes
                  .where(
                    (p) =>
                        p.idConfiguracionPlanSuscripcion ==
                        perfil?.idConfiguracionPlanSuscripcion,
                  )
                  .firstOrNull;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _PlanActualCard(plan: plan),
                  const SizedBox(height: 16),
                  _EstadoCard(estado: estado, onIniciarPago: _iniciarPago),
                  if (perfil != null) ...[
                    const SizedBox(height: 16),
                    _HistorialPagosCard(
                      idSistemaUsuario: perfil.idSistemaUsuario,
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(context.l10n.errorGenerico(e.toString()))),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _PlanActualCard extends StatelessWidget {
  final PlanSuscripcion? plan;
  const _PlanActualCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.suscripcionPlanActual,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            if (plan == null)
              Text(context.l10n.suscripcionSinPlan)
            else ...[
              Text(plan!.nombre, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                context.l10n.planesPrecioYSedes(
                  plan!.precioMensual.toStringAsFixed(2),
                  plan!.maxSedes,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final EstadoSuscripcion? estado;
  final void Function(BuildContext context) onIniciarPago;
  const _EstadoCard({required this.estado, required this.onIniciarPago});

  @override
  Widget build(BuildContext context) {
    if (estado == null) return const SizedBox.shrink();

    final IconData icono;
    final Color color;
    final String titulo;
    final String? subtitulo;

    if (estado!.planPagado) {
      icono = Icons.check_circle_outline;
      color = AppColors.green;
      titulo = context.l10n.suscripcionAlDia;
      subtitulo = null;
    } else if (estado!.enPeriodoGratuito) {
      icono = Icons.card_giftcard_outlined;
      color = Theme.of(context).colorScheme.primary;
      titulo = context.l10n.suscripcionEnPrueba;
      subtitulo = estado!.periodoGratuitoFin != null
          ? context.l10n.suscripcionEnPruebaHasta(
              DateFormat('dd/MM/yyyy').format(estado!.periodoGratuitoFin!),
            )
          : context.l10n.periodoGratuitoIndefinido;
    } else {
      icono = Icons.warning_amber_outlined;
      color = Theme.of(context).colorScheme.error;
      titulo = context.l10n.suscripcionPagoPendienteTitulo;
      subtitulo = context.l10n.suscripcionPagoPendienteExplicacion;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitulo,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (estado!.pagoPendiente) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.payments_outlined),
                label: Text(context.l10n.suscripcionIniciarPago),
                onPressed: () => onIniciarPago(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Historial de pagos del propio cliente (083), de solo lectura -a diferencia de la ficha del
/// ADMIN, aquí no hay botón de registrar ni de borrar.
class _HistorialPagosCard extends ConsumerWidget {
  final String idSistemaUsuario;
  const _HistorialPagosCard({required this.idSistemaUsuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagosAsync = ref.watch(pagosClienteProvider(idSistemaUsuario));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.pagoHistorialTitulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            pagosAsync.when(
              data: (pagos) => pagos.isEmpty
                  ? Text(context.l10n.pagoSinHistorial)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final pago in pagos)
                          PagoSuscripcionTile(pago: pago),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ],
        ),
      ),
    );
  }
}
