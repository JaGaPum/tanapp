import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../application/terminos_providers.dart';

/// Consulta de solo lectura de los documentos legales vigentes (desde Cuenta), estén ya
/// aceptados o no.
class VerTerminosScreen extends ConsumerWidget {
  const VerTerminosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activosAsync = ref.watch(terminosActivosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.terminosVerEnCuenta)),
      body: activosAsync.when(
        data: (activos) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final termino = activos[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(termino.titulo, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(termino.cuerpo, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
