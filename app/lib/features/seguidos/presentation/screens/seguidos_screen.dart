import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../widgets/big_choice_card.dart';

IconData _iconoTipo(String nombre) => switch (nombre.trim().toLowerCase()) {
  'funeraria' => Icons.local_florist,
  'tanatorio' => Icons.house_outlined,
  _ => Icons.storefront_outlined,
};

const _ordenTipos = ['Tanatorio', 'Funeraria'];

// Tanatorios y funerarias se buscan y siguen igual (a efectos del usuario final son el mismo
// tipo de sitio), así que en "Buscar" se fusionan en una sola tarjeta que devuelve clientes de
// ambos tipos a la vez, en vez de obligar a elegir uno de los dos primero.
const _tiposFusionados = {'Tanatorio', 'Funeraria'};

int _compararOrdenTipos(String a, String b) {
  final ia = _ordenTipos.indexOf(a);
  final ib = _ordenTipos.indexOf(b);
  if (ia == -1 && ib == -1) return a.compareTo(b);
  if (ia == -1) return 1;
  if (ib == -1) return -1;
  return ia.compareTo(ib);
}

class SeguidosScreen extends ConsumerWidget {
  const SeguidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiposAsync = ref.watch(clienteTiposListProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: tiposAsync.when(
        data: (tipos) {
          // "Parroquia" se oculta por ahora en Buscar (se valorará más adelante si se activa),
          // sin tocar su configuración en Sistema > Configuración > Tipos de cliente.
          final activos =
              tipos.where((t) => t.activo && t.nombre != 'Parroquia').toList()
                ..sort((a, b) => _compararOrdenTipos(a.nombre, b.nombre));
          if (activos.isEmpty) {
            return EmptyState(
              message: context.l10n.proximamente,
              icon: Icons.people_outline,
            );
          }
          final fusionados = activos
              .where((t) => _tiposFusionados.contains(t.nombre))
              .toList();
          final sueltos = activos
              .where((t) => !_tiposFusionados.contains(t.nombre))
              .toList();
          final tarjetas = <Widget>[
            if (fusionados.isNotEmpty)
              BigChoiceCard(
                icon: const Icon(Icons.local_florist, size: 48),
                label: fusionados.map((t) => t.nombre).join('/'),
                onTap: () => context.push(
                  '/seguidos/${fusionados.map((t) => t.idConfiguracionClienteTipo).join(',')}/provincias',
                ),
              ),
            ...sueltos.map(
              (tipo) => BigChoiceCard(
                icon: Icon(_iconoTipo(tipo.nombre), size: 48),
                label: tipo.nombre,
                onTap: () => context.push(
                  '/seguidos/${tipo.idConfiguracionClienteTipo}/provincias',
                ),
              ),
            ),
            BigChoiceCard(
              icon: const Icon(Icons.location_on_outlined, size: 48),
              label: context.l10n.zonaTitulo,
              onTap: () => context.push('/seguidos-zona/provincias'),
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.seguidosSeleccionaTipo,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final ladoTarjeta = constraints.maxWidth < 240
                        ? constraints.maxWidth
                        : 240.0;
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final tarjeta in tarjetas) ...[
                              SizedBox(
                                width: ladoTarjeta,
                                height: ladoTarjeta,
                                child: tarjeta,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
