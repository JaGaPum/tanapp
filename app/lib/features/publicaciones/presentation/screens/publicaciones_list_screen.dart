import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/publicaciones_providers.dart';
import '../widgets/publicacion_card.dart';

/// Lista de publicaciones de más reciente a más vieja. Con [idClienteSede] muestra solo las
/// de esa sede (vista de un seguidor); sin él, todas las de las sedes propias del cliente
/// autenticado (vista "Mis publicaciones" del panel de datos).
class PublicacionesListScreen extends ConsumerWidget {
  final String titulo;
  final String? idClienteSede;

  const PublicacionesListScreen({super.key, required this.titulo, this.idClienteSede});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sede = idClienteSede;
    final publicacionesAsync =
        sede != null ? ref.watch(publicacionesPorSedeProvider(sede)) : ref.watch(misPublicacionesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: publicacionesAsync.when(
        data: (publicaciones) {
          if (publicaciones.isEmpty) {
            return EmptyState(message: context.l10n.publicarSinPublicaciones, icon: Icons.campaign_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
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
