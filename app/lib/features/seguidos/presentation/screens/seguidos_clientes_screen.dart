import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../application/seguidos_providers.dart';
import '../widgets/cliente_seguible_card.dart';

class SeguidosClientesScreen extends ConsumerWidget {
  final String idConfiguracionClienteTipo;
  final String idConfiguracionProvincia;
  final String idConfiguracionConcello;

  const SeguidosClientesScreen({
    super.key,
    required this.idConfiguracionClienteTipo,
    required this.idConfiguracionProvincia,
    required this.idConfiguracionConcello,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);
    final concellosAsync = ref.watch(
      concellosPorProvinciaProvider(idConfiguracionProvincia),
    );
    final tiposAsync = ref.watch(clienteTiposListProvider);

    // "idConfiguracionClienteTipo" puede traer varios ids separados por coma cuando "Buscar"
    // fusiona varios tipos en una sola tarjeta (p.ej. Tanatorio/Funeraria).
    final idsTipo = idConfiguracionClienteTipo.split(',').toSet();
    final tipoNombre = tiposAsync.maybeWhen(
      data: (tipos) {
        final nombres = tipos
            .where((t) => idsTipo.contains(t.idConfiguracionClienteTipo))
            .map((t) => t.nombre)
            .toList();
        return nombres.isEmpty ? null : nombres.join('/');
      },
      orElse: () => null,
    );
    final provinciaNombre = provinciasAsync.maybeWhen(
      data: (provincias) => provincias
          .where((p) => p.idConfiguracionProvincia == idConfiguracionProvincia)
          .map((p) => p.nombre)
          .firstOrNull,
      orElse: () => null,
    );
    final concelloNombre = concellosAsync.maybeWhen(
      data: (concellos) => concellos
          .where((c) => c.idConfiguracionConcello == idConfiguracionConcello)
          .map((c) => c.nombre)
          .firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(concelloNombre ?? context.l10n.seguidosSeleccionaConcello),
      ),
      body: (provinciaNombre == null || concelloNombre == null)
          ? const Center(child: CircularProgressIndicator())
          : _ClientesList(
              filtro: ClientesFiltro(
                idConfiguracionClienteTipo: idConfiguracionClienteTipo,
                provincia: provinciaNombre,
                concello: concelloNombre,
              ),
              tipoNombre: tipoNombre,
            ),
    );
  }
}

class _ClientesList extends ConsumerWidget {
  final ClientesFiltro filtro;
  final String? tipoNombre;
  const _ClientesList({required this.filtro, required this.tipoNombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesPorFiltroProvider(filtro));
    final misSeguidosAsync = ref.watch(misSeguidosIdsProvider);

    return clientesAsync.when(
      data: (clientes) {
        if (clientes.isEmpty) {
          return EmptyState(
            message: context.l10n.seguidosNoHayActivosNesteConcello(
              tipoNombre ?? '',
            ),
            icon: Icons.local_florist_outlined,
          );
        }
        final misSeguidos = misSeguidosAsync.value ?? const <String>{};
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: clientes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cliente = clientes[index];
            return ClienteSeguibleCard(
              cliente: cliente,
              siguiendo: misSeguidos.contains(cliente.idClienteSede),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}
