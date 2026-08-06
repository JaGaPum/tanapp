import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/galician_sort.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../configuracion/data/concello.dart';
import '../../application/zonas_seguidas_providers.dart';
import '../../data/zonas_seguidas_repository.dart';

class ZonaConcellosScreen extends ConsumerStatefulWidget {
  final String idConfiguracionProvincia;
  const ZonaConcellosScreen({
    super.key,
    required this.idConfiguracionProvincia,
  });

  @override
  ConsumerState<ZonaConcellosScreen> createState() =>
      _ZonaConcellosScreenState();
}

class _ZonaConcellosScreenState extends ConsumerState<ZonaConcellosScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Concello> _ordenados(List<Concello> concellos, String? concelloPropio) {
    final termino = _busquedaController.text.trim().toLowerCase();
    final filtrados = termino.isEmpty
        ? concellos
        : concellos
              .where((c) => c.nombre.toLowerCase().contains(termino))
              .toList();
    final ordenados = [...filtrados]
      ..sort((a, b) {
        if (concelloPropio != null) {
          final aEsPropio = a.nombre == concelloPropio;
          final bEsPropio = b.nombre == concelloPropio;
          if (aEsPropio && !bEsPropio) return -1;
          if (bEsPropio && !aEsPropio) return 1;
        }
        return claveOrdenGalego(a.nombre).compareTo(claveOrdenGalego(b.nombre));
      });
    return ordenados;
  }

  @override
  Widget build(BuildContext context) {
    final concellosAsync = ref.watch(
      concellosPorProvinciaProvider(widget.idConfiguracionProvincia),
    );
    final provinciasAsync = ref.watch(provinciasProvider);
    final misZonasAsync = ref.watch(misZonasConcellosProvider);
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final concelloPropio = perfilAsync.value?.concello;
    final provinciaNombre = provinciasAsync.maybeWhen(
      data: (provincias) => provincias
          .where(
            (p) =>
                p.idConfiguracionProvincia == widget.idConfiguracionProvincia,
          )
          .map((p) => p.nombre)
          .firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.seguidosSeleccionaConcello)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.zonaExplicacion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: context.l10n.seguidosBuscarConcello,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: concellosAsync.when(
                data: (concellos) {
                  final ordenados = _ordenados(concellos, concelloPropio);
                  if (ordenados.isEmpty) {
                    return EmptyState(
                      message: context.l10n.noHayConcellosDadosDeAlta,
                      icon: Icons.location_city_outlined,
                    );
                  }
                  final misZonas = misZonasAsync.value ?? const <String>{};
                  return ListView.separated(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: ordenados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final concello = ordenados[index];
                      return _ZonaRow(
                        concello: concello.nombre,
                        provincia: provinciaNombre ?? '',
                        siguiendo: misZonas.contains(concello.nombre),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(context.l10n.errorGenerico(e.toString())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZonaRow extends ConsumerStatefulWidget {
  final String concello;
  final String provincia;
  final bool siguiendo;
  const _ZonaRow({
    required this.concello,
    required this.provincia,
    required this.siguiendo,
  });

  @override
  ConsumerState<_ZonaRow> createState() => _ZonaRowState();
}

class _ZonaRowState extends ConsumerState<_ZonaRow> {
  bool _loading = false;

  Future<void> _alternar() async {
    setState(() => _loading = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) return;
      final repo = ref.read(zonasSeguidasRepositoryProvider);
      if (widget.siguiendo) {
        await repo.dejarDeSeguirZona(
          idSistemaUsuario: perfil.idSistemaUsuario,
          concello: widget.concello,
        );
      } else {
        await repo.seguirZona(
          idSistemaUsuario: perfil.idSistemaUsuario,
          provincia: widget.provincia,
          concello: widget.concello,
        );
      }
      ref.invalidate(misZonasConcellosProvider);
      ref.invalidate(misZonasProvider);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          widget.concello,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        trailing: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : OutlinedButton.icon(
                icon: Icon(
                  widget.siguiendo
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                ),
                label: Text(
                  widget.siguiendo
                      ? context.l10n.zonaDejarDeSeguir
                      : context.l10n.zonaSeguir,
                ),
                onPressed: _alternar,
              ),
      ),
    );
  }
}
