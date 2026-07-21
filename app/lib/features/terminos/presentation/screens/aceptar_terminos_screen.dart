import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../sesiones/application/sesion_policy_service.dart';
import '../../application/terminos_providers.dart';
import '../../data/terminos_repository.dart';

/// Pantalla de bloqueo: no se puede navegar a ningún otro sitio hasta aceptar todos los
/// documentos pendientes (el router redirige aquí, ver `app_router.dart`).
class AceptarTerminosScreen extends ConsumerStatefulWidget {
  const AceptarTerminosScreen({super.key});

  @override
  ConsumerState<AceptarTerminosScreen> createState() => _AceptarTerminosScreenState();
}

class _AceptarTerminosScreenState extends ConsumerState<AceptarTerminosScreen> {
  final Set<String> _aceptados = {};
  bool _guardando = false;

  Future<void> _continuar(List<String> idsSistemaTermino) async {
    setState(() => _guardando = true);
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      await ref.read(terminosRepositoryProvider).aceptar(perfil!.idSistemaUsuario, idsSistemaTermino);
      ref.read(sesionBootstrapGuardProvider).necesitaAceptarTerminos = false;
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendientesAsync = ref.watch(terminosPendientesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.terminosTitulo), automaticallyImplyLeading: false),
      body: SafeArea(
        child: pendientesAsync.when(
          data: (pendientes) {
            final ids = pendientes.map((t) => t.idSistemaTermino).toList();
            final todosAceptados = pendientes.every((t) => _aceptados.contains(t.idSistemaTermino));
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final termino in pendientes) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(termino.titulo, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 260),
                                  child: SingleChildScrollView(
                                    child: Text(termino.cuerpo, style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          value: _aceptados.contains(termino.idSistemaTermino),
                          title: Text(context.l10n.terminosHeAceptado(termino.titulo)),
                          onChanged: (marcado) {
                            setState(() {
                              if (marcado ?? false) {
                                _aceptados.add(termino.idSistemaTermino);
                              } else {
                                _aceptados.remove(termino.idSistemaTermino);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (todosAceptados && !_guardando) ? () => _continuar(ids) : null,
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.terminosContinuar),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
      ),
    );
  }
}
