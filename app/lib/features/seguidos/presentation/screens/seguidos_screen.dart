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
      'parroquia' => Icons.church,
      _ => Icons.storefront_outlined,
    };

const _ordenTipos = ['Tanatorio', 'Funeraria', 'Parroquia'];

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
          final activos = tipos.where((t) => t.activo).toList()
            ..sort((a, b) => _compararOrdenTipos(a.nombre, b.nombre));
          if (activos.isEmpty) {
            return EmptyState(message: context.l10n.proximamente, icon: Icons.people_outline);
          }
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
                    const spacing = 16.0;
                    final anchoTarjeta = (constraints.maxWidth - spacing) / 2;
                    return SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: spacing,
                        runSpacing: spacing,
                        children: activos
                            .map(
                              (tipo) => SizedBox(
                                width: anchoTarjeta,
                                height: anchoTarjeta,
                                child: BigChoiceCard(
                                  icon: Icon(_iconoTipo(tipo.nombre), size: 48),
                                  label: tipo.nombre,
                                  onTap: () => context
                                      .push('/seguidos/${tipo.idConfiguracionClienteTipo}/provincias'),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
