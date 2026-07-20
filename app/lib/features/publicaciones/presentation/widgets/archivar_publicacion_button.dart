import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicaciones_repository.dart';

/// Icono de guardar/quitar del Arquivo personal. Se usa en Taboleiro, en las publicaciones de
/// una sede seguida y en el propio Arquivo (donde sirve para desarchivar).
class ArchivarPublicacionButton extends ConsumerStatefulWidget {
  final String idClientePublicacion;
  const ArchivarPublicacionButton({super.key, required this.idClientePublicacion});

  @override
  ConsumerState<ArchivarPublicacionButton> createState() => _ArchivarPublicacionButtonState();
}

class _ArchivarPublicacionButtonState extends ConsumerState<ArchivarPublicacionButton> {
  bool _loading = false;

  Future<void> _alternar(bool archivada) async {
    setState(() => _loading = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) return;
      final repo = ref.read(publicacionesRepositoryProvider);
      if (archivada) {
        await repo.desarchivar(idSistemaUsuario: perfil.idSistemaUsuario, idClientePublicacion: widget.idClientePublicacion);
      } else {
        await repo.archivar(idSistemaUsuario: perfil.idSistemaUsuario, idClientePublicacion: widget.idClientePublicacion);
      }
      ref.invalidate(misPublicacionesArchivadasIdsProvider);
      ref.invalidate(misPublicacionesArchivadasProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(archivada ? context.l10n.arquivoEliminado : context.l10n.arquivoGardado)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final archivadasAsync = ref.watch(misPublicacionesArchivadasIdsProvider);
    final archivada = archivadasAsync.maybeWhen(
      data: (ids) => ids.contains(widget.idClientePublicacion),
      orElse: () => false,
    );
    return IconButton(
      icon: Icon(archivada ? Icons.bookmark : Icons.bookmark_border),
      tooltip: archivada ? context.l10n.arquivoTooltipQuitar : context.l10n.arquivoTooltipGardar,
      onPressed: _loading ? null : () => _alternar(archivada),
    );
  }
}
