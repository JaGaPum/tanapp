import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../publicaciones/data/publicacion_con_sede.dart';
import '../../../publicaciones/presentation/widgets/publicacion_card.dart';

class ArchivoScreen extends ConsumerWidget {
  const ArchivoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivadasAsync = ref.watch(misPublicacionesArchivadasProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: archivadasAsync.cargandoInicial
          ? const Center(child: CircularProgressIndicator())
          : archivadasAsync.error != null
              ? Center(child: Text(context.l10n.errorGenerico(archivadasAsync.error.toString())))
              : archivadasAsync.items.isEmpty
                  ? EmptyState(message: context.l10n.arquivoVacio, icon: Icons.bookmark_border)
                  : PaginatedListView<PublicacionConSede>(
                      items: archivadasAsync.items,
                      cargandoMas: archivadasAsync.cargandoMas,
                      hasMore: archivadasAsync.hasMore,
                      onCargarMas: () => ref.read(misPublicacionesArchivadasProvider.notifier).cargarMas(),
                      itemBuilder: (context, publicacion) => PublicacionCard(publicacion: publicacion),
                    ),
    );
  }
}
