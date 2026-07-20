import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../../seguidos/presentation/widgets/big_choice_card.dart';

const _tiposHabilitados = {'Funeraria', 'Tanatorio'};

class PublicarScreen extends ConsumerWidget {
  const PublicarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final tiposAsync = ref.watch(clienteTiposListProvider);

    return perfilAsync.when(
      data: (perfil) => tiposAsync.when(
        data: (tipos) {
          final tipoNombre = tipos
              .where((t) => t.idConfiguracionClienteTipo == perfil?.idConfiguracionClienteTipo)
              .map((t) => t.nombre)
              .firstOrNull;
          if (tipoNombre == null || !_tiposHabilitados.contains(tipoNombre)) {
            return EmptyState(message: context.l10n.proximamente, icon: Icons.campaign_outlined);
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 16.0;
                final anchoTarjeta = (constraints.maxWidth - spacing) / 2;
                return Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: anchoTarjeta,
                        height: anchoTarjeta,
                        child: BigChoiceCard(
                          icon: const Icon(Icons.document_scanner_outlined, size: 48),
                          label: context.l10n.publicarEscanear,
                          onTap: () => context.push('/publicar/escanear'),
                        ),
                      ),
                      SizedBox(
                        width: anchoTarjeta,
                        height: anchoTarjeta,
                        child: BigChoiceCard(
                          icon: const Icon(Icons.edit_note_outlined, size: 48),
                          label: context.l10n.publicarManual,
                          onTap: () => context.push('/publicar/manual'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}
