import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../seguidos/presentation/widgets/big_choice_card.dart';
import '../../../seguidos/presentation/widgets/provincia_shape_icon.dart';

class ZonaProvinciasScreen extends ConsumerWidget {
  const ZonaProvinciasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.seguidosSeleccionaProvincia)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provinciasAsync.when(
          data: (provincias) => GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: provincias
                .map(
                  (p) => BigChoiceCard(
                    icon: ProvinciaShapeIcon(provincia: p.nombre, size: 48),
                    label: p.nombre,
                    onTap: () => context.push(
                      '/seguidos-zona/provincias/${p.idConfiguracionProvincia}/concellos',
                    ),
                  ),
                )
                .toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
      ),
    );
  }
}
