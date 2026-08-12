import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/xaga_labs_logo.dart';

/// Primera pantalla para quien no tiene sesión (splash -> aquí): separa el camino de un usuario
/// cualquiera que solo quiere seguir esquelas del de una funeraria/tanatorio, para que cada uno
/// vea solo lo suyo en el login/registro en vez de tener que descartar opciones de negocio (o al
/// revés) mezcladas en una sola pantalla.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 40),
                  _OpcionAcceso(
                    icon: Icons.groups_outlined,
                    titulo: context.l10n.bienvenidaOpcionParticularTitulo,
                    subtitulo: context.l10n.bienvenidaOpcionParticularSubtitulo,
                    onTap: () => context.push('/login'),
                  ),
                  const SizedBox(height: 16),
                  _OpcionAcceso(
                    icon: Icons.church_outlined,
                    titulo: context.l10n.bienvenidaOpcionClienteTitulo,
                    subtitulo: context.l10n.bienvenidaOpcionClienteSubtitulo,
                    onTap: () => context.push('/login-cliente'),
                  ),
                  const SizedBox(height: 40),
                  const Center(child: XagaLabsLogo()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionAcceso extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionAcceso({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
