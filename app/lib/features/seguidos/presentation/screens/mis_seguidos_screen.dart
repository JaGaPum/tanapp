import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/como_llegar_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../application/seguidos_providers.dart';
import '../../data/cliente_seguible.dart';
import '../../data/seguidos_repository.dart';
import '../widgets/cliente_avatar.dart';

class MisSeguidosScreen extends ConsumerStatefulWidget {
  const MisSeguidosScreen({super.key});

  @override
  ConsumerState<MisSeguidosScreen> createState() => _MisSeguidosScreenState();
}

class _MisSeguidosScreenState extends ConsumerState<MisSeguidosScreen> {
  final _busquedaController = TextEditingController();
  String? _provinciaIdSeleccionada;
  String? _provinciaFiltro;
  String? _concelloFiltro;
  bool _mostrarFiltros = false;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<ClienteSeguible> _filtrar(List<ClienteSeguible> clientes) {
    final termino = _busquedaController.text.trim().toLowerCase();
    return clientes.where((c) {
      if (termino.isNotEmpty && !c.nombreCliente.toLowerCase().contains(termino)) return false;
      if (_provinciaFiltro != null && c.provincia != _provinciaFiltro) return false;
      if (_concelloFiltro != null && c.concello != _concelloFiltro) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(misSeguidosClientesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _mostrarFiltros = !_mostrarFiltros),
            icon: Icon(_mostrarFiltros ? Icons.expand_less : Icons.filter_list),
            label: Text(context.l10n.misSeguidosBuscarYFiltrar),
          ),
          if (_mostrarFiltros) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: context.l10n.misSeguidosBuscarNombre,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ref.watch(provinciasProvider).when(
                  data: (provincias) => DropdownButtonFormField<String?>(
                    initialValue: _provinciaIdSeleccionada,
                    decoration: InputDecoration(labelText: context.l10n.fieldProvincia),
                    items: [
                      DropdownMenuItem(value: null, child: Text(context.l10n.filtroTodasProvincias)),
                      ...provincias.map(
                        (p) => DropdownMenuItem(value: p.idConfiguracionProvincia, child: Text(p.nombre)),
                      ),
                    ],
                    onChanged: (idOrNull) => setState(() {
                      _provinciaIdSeleccionada = idOrNull;
                      _provinciaFiltro = idOrNull == null
                          ? null
                          : provincias.firstWhere((p) => p.idConfiguracionProvincia == idOrNull).nombre;
                      _concelloFiltro = null;
                    }),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(context.l10n.errorCargarProvincias(e.toString())),
                ),
            const SizedBox(height: 16),
            _provinciaIdSeleccionada == null
                ? DropdownButtonFormField<String?>(
                    initialValue: null,
                    decoration: InputDecoration(labelText: context.l10n.fieldConcello),
                    items: [DropdownMenuItem(value: null, child: Text(context.l10n.filtroTodosConcellos))],
                    onChanged: null,
                  )
                : ref.watch(concellosPorProvinciaProvider(_provinciaIdSeleccionada!)).when(
                      data: (concellos) => DropdownButtonFormField<String?>(
                        initialValue: _concelloFiltro,
                        decoration: InputDecoration(labelText: context.l10n.fieldConcello),
                        items: [
                          DropdownMenuItem(value: null, child: Text(context.l10n.filtroTodosConcellos)),
                          ...concellos.map((c) => DropdownMenuItem(value: c.nombre, child: Text(c.nombre))),
                        ],
                        onChanged: (value) => setState(() => _concelloFiltro = value),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text(context.l10n.errorCargarConcellos(e.toString())),
                    ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: clientesAsync.when(
              data: (clientes) {
                final filtrados = _filtrar(clientes);
                if (filtrados.isEmpty) {
                  return EmptyState(
                    message: context.l10n.misSeguidosVacio,
                    icon: Icons.favorite_border,
                  );
                }
                return ListView.separated(
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _ClienteSeguidoTile(cliente: filtrados[index]),
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

class _ClienteSeguidoTile extends ConsumerStatefulWidget {
  final ClienteSeguible cliente;
  const _ClienteSeguidoTile({required this.cliente});

  @override
  ConsumerState<_ClienteSeguidoTile> createState() => _ClienteSeguidoTileState();
}

class _ClienteSeguidoTileState extends ConsumerState<_ClienteSeguidoTile> {
  bool _loading = false;

  Future<void> _dejarDeSeguir() async {
    setState(() => _loading = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) return;
      await ref.read(seguidosRepositoryProvider).dejarDeSeguir(
            idSistemaUsuario: perfil.idSistemaUsuario,
            idClienteSede: widget.cliente.idClienteSede,
          );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClienteAvatar(nombre: cliente.nombreCliente, fotoUrl: cliente.fotoUrl, radius: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cliente.nombreCliente, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        '${cliente.concello} (${cliente.provincia})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(cliente.direccion, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ComoLlegarButton(
                    direccion: cliente.direccion,
                    concello: cliente.concello,
                    provincia: cliente.provincia,
                    label: context.l10n.mapa,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.campaign_outlined),
                    label: Text(context.l10n.tabPublicaciones),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: AppColors.white),
                    onPressed: () => context.push(
                      '/publicaciones/${cliente.idClienteSede}',
                      extra: '${cliente.nombreCliente} · ${cliente.nombreSede}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_remove_outlined),
              label: Text(context.l10n.seguidosDejarDeSeguir),
              onPressed: _loading ? null : _dejarDeSeguir,
            ),
          ],
        ),
      ),
    );
  }
}
