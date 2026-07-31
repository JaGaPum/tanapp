import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../application/configuracion_providers.dart';
import '../../data/configuracion_repository.dart';

class ConfiguracionIaScreen extends ConsumerWidget {
  const ConfiguracionIaScreen({super.key});

  Future<void> _toggleImportacionWebIa(BuildContext context, WidgetRef ref, bool activa) async {
    try {
      await ref.read(configuracionRepositoryProvider).actualizarImportacionWebIaActiva(activa);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))));
      }
    } finally {
      ref.invalidate(importacionWebIaActivaProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activaAsync = ref.watch(importacionWebIaActivaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionIaTitulo)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: activaAsync.when(
          data: (activa) => Card(
            child: SwitchListTile(
              title: Text(context.l10n.configuracionIaImportacionWebLabel),
              subtitle: Text(context.l10n.configuracionIaImportacionWebDescripcion),
              value: activa,
              onChanged: (valor) => _toggleImportacionWebIa(context, ref, valor),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
      ),
    );
  }
}
