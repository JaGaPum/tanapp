import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/solicitudes_providers.dart';
import '../../data/solicitud_cliente.dart';

String _estadoLabel(BuildContext context, String estado) => switch (estado) {
      'PENDIENTE' => context.l10n.pendiente,
      'APROBADA' => context.l10n.estadoAprobadaSingular,
      'RECHAZADA' => context.l10n.estadoRechazadaSingular,
      _ => estado,
    };

class SolicitudesListScreen extends ConsumerWidget {
  const SolicitudesListScreen({super.key});

  Map<String?, String> _estados(AppLocalizations l10n) => {
        null: l10n.estadoTodas,
        'PENDIENTE': l10n.estadoPendientes,
        'APROBADA': l10n.estadoAprobadas,
        'RECHAZADA': l10n.estadoRechazadas,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoActual = ref.watch(solicitudesEstadoFiltroProvider);
    final solicitudesAsync = ref.watch(solicitudesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.solicitudesClientesTitulo)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 8,
              children: _estados(context.l10n).entries.map((entry) {
                final selected = entry.key == estadoActual;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  labelStyle: TextStyle(color: AppColors.chipLabel(selected)),
                  onSelected: (_) =>
                      ref.read(solicitudesEstadoFiltroProvider.notifier).set(entry.key),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: solicitudesAsync.when(
              data: (solicitudes) {
                if (solicitudes.isEmpty) {
                  return EmptyState(
                    message: context.l10n.noHaySolicitudesEnEsteEstado,
                    icon: Icons.assignment_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(solicitudesListProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: solicitudes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _SolicitudTile(solicitud: solicitudes[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitudTile extends StatelessWidget {
  final SolicitudCliente solicitud;
  const _SolicitudTile({required this.solicitud});

  Color _estadoColor(BuildContext context, String estado) {
    switch (estado) {
      case 'APROBADA':
        return Colors.green.shade700;
      case 'RECHAZADA':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(solicitud.razonSocial, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${solicitud.nombreContacto} · ${solicitud.emailContacto}'),
        trailing: Chip(
          label: Text(_estadoLabel(context, solicitud.estado), style: TextStyle(color: _estadoColor(context, solicitud.estado))),
        ),
        onTap: () => context.push('/admin/solicitudes/${solicitud.idClientesSolicitud}'),
      ),
    );
  }
}
