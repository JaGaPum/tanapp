import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/galician_sort.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../configuracion/data/concello.dart';

class SeguidosConcellosScreen extends ConsumerStatefulWidget {
  final String idConfiguracionClienteTipo;
  final String idConfiguracionProvincia;
  const SeguidosConcellosScreen({
    super.key,
    required this.idConfiguracionClienteTipo,
    required this.idConfiguracionProvincia,
  });

  @override
  ConsumerState<SeguidosConcellosScreen> createState() => _SeguidosConcellosScreenState();
}

class _SeguidosConcellosScreenState extends ConsumerState<SeguidosConcellosScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Concello> _ordenados(List<Concello> concellos, String? concelloPropio) {
    final termino = _busquedaController.text.trim().toLowerCase();
    final filtrados =
        termino.isEmpty ? concellos : concellos.where((c) => c.nombre.toLowerCase().contains(termino)).toList();
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
    final concellosAsync = ref.watch(concellosPorProvinciaProvider(widget.idConfiguracionProvincia));
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final concelloPropio = perfilAsync.value?.concello;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.seguidosSeleccionaConcello)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  return ListView.separated(
                    itemCount: ordenados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final concello = ordenados[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(concello.nombre, style: Theme.of(context).textTheme.titleLarge),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/seguidos/${widget.idConfiguracionClienteTipo}/provincias/'
                            '${widget.idConfiguracionProvincia}/concellos/${concello.idConfiguracionConcello}/clientes',
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
