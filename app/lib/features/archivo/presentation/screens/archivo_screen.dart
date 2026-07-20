import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../publicaciones/presentation/widgets/publicacion_card.dart';

class ArchivoScreen extends ConsumerWidget {
  const ArchivoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivadasAsync = ref.watch(misPublicacionesArchivadasProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: archivadasAsync.when(
        data: (publicaciones) {
          if (publicaciones.isEmpty) {
            return EmptyState(message: context.l10n.arquivoVacio, icon: Icons.bookmark_border);
          }
          return ListView.separated(
            itemCount: publicaciones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => PublicacionCard(publicacion: publicaciones[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
