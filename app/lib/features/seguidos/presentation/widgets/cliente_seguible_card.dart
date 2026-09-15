import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/como_llegar_button.dart';
import '../../../../core/widgets/etiqueta_chip.dart';
import '../../../../core/widgets/llamar_button.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/seguidos_providers.dart';
import '../../data/cliente_seguible.dart';
import '../../data/seguidos_repository.dart';
import 'cliente_avatar.dart';

/// Tarjeta de cliente con botón Seguir/Dejar de seguir a modo de interruptor: se usa tanto al
/// explorar por tipo/provincia/concello ([SeguidosClientesScreen]) como en la búsqueda directa
/// por nombre (075, [SeguidosScreen]) - antes estaba duplicada en la primera, ahora es un único
/// widget para las dos.
class ClienteSeguibleCard extends ConsumerStatefulWidget {
  final ClienteSeguible cliente;
  final bool siguiendo;
  const ClienteSeguibleCard({
    super.key,
    required this.cliente,
    required this.siguiendo,
  });

  @override
  ConsumerState<ClienteSeguibleCard> createState() =>
      _ClienteSeguibleCardState();
}

class _ClienteSeguibleCardState extends ConsumerState<ClienteSeguibleCard> {
  bool _loading = false;

  Future<void> _alternarSeguimiento() async {
    setState(() => _loading = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) return;
      final repo = ref.read(seguidosRepositoryProvider);
      if (widget.siguiendo) {
        await repo.dejarDeSeguir(
          idSistemaUsuario: perfil.idSistemaUsuario,
          idClienteSede: widget.cliente.idClienteSede,
        );
      } else {
        await repo.seguir(
          idSistemaUsuario: perfil.idSistemaUsuario,
          idClienteSede: widget.cliente.idClienteSede,
        );
      }
      ref.invalidate(misSeguidosIdsProvider);
      ref.invalidate(misSeguidosClientesProvider);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClienteAvatar(
                  nombre: cliente.nombreCliente,
                  fotoUrl: cliente.fotoUrl,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cliente.nombreCliente,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      EtiquetaChip(texto: cliente.nombreSede),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                EtiquetaChip(
                  texto: widget.siguiendo
                      ? context.l10n.seguidosSiguiendoEtiqueta
                      : context.l10n.seguidosNoSiguiendoEtiqueta,
                  icon: widget.siguiendo
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: widget.siguiendo
                      ? AppColors.green
                      : Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${cliente.concello} (${cliente.provincia})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              cliente.direccion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (cliente.telefono != null) ...[
              const SizedBox(height: 4),
              Text(
                cliente.telefono!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ComoLlegarButton(
                  direccion: cliente.direccion,
                  concello: cliente.concello,
                  provincia: cliente.provincia,
                ),
                if (cliente.telefono != null &&
                    cliente.telefono!.trim().isNotEmpty)
                  LlamarButton(telefono: cliente.telefono!),
                FilledButton.icon(
                  icon: Icon(
                    widget.siguiendo
                        ? Icons.person_remove_outlined
                        : Icons.person_add_alt_1_outlined,
                  ),
                  label: Text(
                    widget.siguiendo
                        ? context.l10n.seguidosDejarDeSeguir
                        : context.l10n.seguidosSeguir,
                  ),
                  onPressed: _loading ? null : _alternarSeguimiento,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
