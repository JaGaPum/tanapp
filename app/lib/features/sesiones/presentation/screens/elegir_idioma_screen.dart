import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../sistema_usuarios/data/catalogos_repository.dart';
import '../../../sistema_usuarios/data/usuarios_repository.dart';
import '../../application/sesion_policy_service.dart';

/// Gate del router (como "aceptar-terminos" o "elegir-sede"): justo después de aceptar
/// términos, cualquier usuario (salvo ADMIN) tiene que elegir explícitamente su idioma, en vez
/// de quedarse sin más con el gallego que se le asigna por defecto al darse de alta (047).
class ElegirIdiomaScreen extends ConsumerStatefulWidget {
  const ElegirIdiomaScreen({super.key});

  @override
  ConsumerState<ElegirIdiomaScreen> createState() => _ElegirIdiomaScreenState();
}

class _ElegirIdiomaScreenState extends ConsumerState<ElegirIdiomaScreen> {
  String? _idIdiomaEligiendo;
  String? _error;

  Future<void> _elegir(String idSistemaIdioma) async {
    setState(() {
      _idIdiomaEligiendo = idSistemaIdioma;
      _error = null;
    });
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null || !mounted) return;
      await ref
          .read(usuariosRepositoryProvider)
          .confirmarIdioma(
            idSistemaUsuario: perfil.idSistemaUsuario,
            idSistemaIdiomaPreferido: idSistemaIdioma,
          );
      ref.invalidate(currentUserProfileProvider);
      if (!mounted) return;
      ref.read(sesionBootstrapGuardProvider).necesitaElegirIdioma = false;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _error = context.l10n.errorGenerico(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _idIdiomaEligiendo = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idiomasAsync = ref.watch(idiomasCatalogoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.elegirIdiomaTitulo),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: idiomasAsync.when(
          data: (idiomas) => ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              if (_error != null) ErrorBanner(message: _error!),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  context.l10n.elegirIdiomaMensaje,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              for (final idioma in idiomas)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(idioma.nombre),
                    trailing: _idIdiomaEligiendo == idioma.idSistemaIdioma
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _idIdiomaEligiendo == null
                        ? () => _elegir(idioma.idSistemaIdioma)
                        : null,
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
      ),
    );
  }
}
