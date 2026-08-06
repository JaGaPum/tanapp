import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../application/configuracion_providers.dart';
import '../../data/configuracion_repository.dart';

class ConfiguracionIaScreen extends ConsumerWidget {
  const ConfiguracionIaScreen({super.key});

  Future<void> _toggleImportacionWebIa(
    BuildContext context,
    WidgetRef ref,
    bool activa,
  ) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .actualizarImportacionWebIaActiva(activa);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      ref.invalidate(importacionWebIaActivaProvider);
    }
  }

  Future<void> _toggleEscaneoEsquelaIa(
    BuildContext context,
    WidgetRef ref,
    bool activa,
  ) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .actualizarEscaneoEsquelaIaActiva(activa);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      ref.invalidate(escaneoEsquelaIaActivaProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importacionWebActivaAsync = ref.watch(importacionWebIaActivaProvider);
    final escaneoActivaAsync = ref.watch(escaneoEsquelaIaActivaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionIaTitulo)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: importacionWebActivaAsync.when(
                data: (activa) => SwitchListTile(
                  title: Text(context.l10n.configuracionIaImportacionWebLabel),
                  subtitle: Text(
                    context.l10n.configuracionIaImportacionWebDescripcion,
                  ),
                  value: activa,
                  onChanged: (valor) =>
                      _toggleImportacionWebIa(context, ref, valor),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.l10n.errorGenerico(e.toString())),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: escaneoActivaAsync.when(
                data: (activa) => SwitchListTile(
                  title: Text(context.l10n.configuracionIaEscaneoEsquelaLabel),
                  subtitle: Text(
                    context.l10n.configuracionIaEscaneoEsquelaDescripcion,
                  ),
                  value: activa,
                  onChanged: (valor) =>
                      _toggleEscaneoEsquelaIa(context, ref, valor),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.l10n.errorGenerico(e.toString())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
