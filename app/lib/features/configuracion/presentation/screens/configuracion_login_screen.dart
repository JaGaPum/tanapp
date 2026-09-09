import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../application/configuracion_providers.dart';
import '../../data/configuracion_repository.dart';

class ConfiguracionLoginScreen extends ConsumerWidget {
  const ConfiguracionLoginScreen({super.key});

  Future<void> _toggleGoogle(
    BuildContext context,
    WidgetRef ref,
    bool activo,
  ) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .actualizarGoogleLoginActivo(activo);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      ref.invalidate(googleLoginActivoProvider);
    }
  }

  Future<void> _toggleFacebook(
    BuildContext context,
    WidgetRef ref,
    bool activo,
  ) async {
    try {
      await ref
          .read(configuracionRepositoryProvider)
          .actualizarFacebookLoginActivo(activo);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      ref.invalidate(facebookLoginActivoProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleActivoAsync = ref.watch(googleLoginActivoProvider);
    final facebookActivoAsync = ref.watch(facebookLoginActivoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionLoginTitulo)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: googleActivoAsync.when(
                data: (activo) => SwitchListTile(
                  title: Text(context.l10n.configuracionLoginGoogleLabel),
                  subtitle: Text(
                    context.l10n.configuracionLoginGoogleDescripcion,
                  ),
                  value: activo,
                  onChanged: (valor) => _toggleGoogle(context, ref, valor),
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
              child: facebookActivoAsync.when(
                data: (activo) => SwitchListTile(
                  title: Text(context.l10n.configuracionLoginFacebookLabel),
                  subtitle: Text(
                    context.l10n.configuracionLoginFacebookDescripcion,
                  ),
                  value: activo,
                  onChanged: (valor) => _toggleFacebook(context, ref, valor),
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
