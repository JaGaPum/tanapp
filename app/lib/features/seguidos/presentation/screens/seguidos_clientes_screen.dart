import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/como_llegar_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/etiqueta_chip.dart';
import '../../../../core/widgets/llamar_button.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../application/seguidos_providers.dart';
import '../../data/cliente_seguible.dart';
import '../../data/seguidos_repository.dart';
import '../widgets/cliente_avatar.dart';

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
            return _ClienteCard(
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

class _ClienteCard extends ConsumerStatefulWidget {
  final ClienteSeguible cliente;
  final bool siguiendo;
  const _ClienteCard({required this.cliente, required this.siguiendo});

  @override
  ConsumerState<_ClienteCard> createState() => _ClienteCardState();
}

class _ClienteCardState extends ConsumerState<_ClienteCard> {
  bool _loading = false;

  Future<void> _alternarSeguimiento() async {
    setState(() => _loading = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) return;
      final repo = ref.read(seguidosRepositoryProvider);
      if (widget.siguiendo) {
        await repo.dejarDeSeguir(
          idSistemaUsuario: perfil.idSistemaUsuario,
          idClienteSede: widget.cliente.idClienteSede,
        );
      } else {
        await repo.seguir(
          idSistemaUsuario: perfil.idSistemaUsuario,
          idClienteSede: widget.cliente.idClienteSede,
        );
      }
      ref.invalidate(misSeguidosIdsProvider);
      ref.invalidate(misSeguidosClientesProvider);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClienteAvatar(
                  nombre: cliente.nombreCliente,
                  fotoUrl: cliente.fotoUrl,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cliente.nombreCliente,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      EtiquetaChip(texto: cliente.nombreSede),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                EtiquetaChip(
                  texto: widget.siguiendo
                      ? context.l10n.seguidosSiguiendoEtiqueta
                      : context.l10n.seguidosNoSiguiendoEtiqueta,
                  icon: widget.siguiendo
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: widget.siguiendo
                      ? AppColors.green
                      : Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cliente.direccion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (cliente.telefono != null) ...[
              const SizedBox(height: 4),
              Text(
                cliente.telefono!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ComoLlegarButton(
                  direccion: cliente.direccion,
                  concello: cliente.concello,
                  provincia: cliente.provincia,
                ),
                if (cliente.telefono != null &&
                    cliente.telefono!.trim().isNotEmpty)
                  LlamarButton(telefono: cliente.telefono!),
                FilledButton.icon(
                  icon: Icon(
                    widget.siguiendo
                        ? Icons.person_remove_outlined
                        : Icons.person_add_alt_1_outlined,
                  ),
                  label: Text(
                    widget.siguiendo
                        ? context.l10n.seguidosDejarDeSeguir
                        : context.l10n.seguidosSeguir,
                  ),
                  onPressed: _loading ? null : _alternarSeguimiento,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
