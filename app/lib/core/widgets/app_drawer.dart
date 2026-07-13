import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/data/auth_repository.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'confirm_dialog.dart';
import 'xaga_labs_logo.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, String location) {
    Navigator.of(context).pop();
    context.push(location);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    // No cerramos el drawer antes del diálogo: se desmontaría este widget e invalidaría `ref`.
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.drawerCerrarSesion,
      message: context.l10n.drawerCerrarSesionMensaje,
      confirmLabel: context.l10n.drawerCerrarSesion,
    );
    if (!confirmado) return;
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Drawer(
      backgroundColor: AppColors.black,
      child: SafeArea(
        child: ListTileTheme(
          data: const ListTileThemeData(iconColor: AppColors.white, textColor: AppColors.white),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.black),
                child: perfilAsync.when(
                  data: (perfil) {
                    final iniciales = [perfil?.nombre, perfil?.apellido1]
                        .where((s) => s != null && s.trim().isNotEmpty)
                        .map((s) => s!.trim()[0].toUpperCase())
                        .join();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.brown,
                          backgroundImage: perfil?.fotoUrl != null ? NetworkImage(perfil!.fotoUrl!) : null,
                          child: perfil?.fotoUrl == null
                              ? Text(
                                  iniciales.isNotEmpty ? iniciales : '?',
                                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          [perfil?.nombre, perfil?.apellido1].where((s) => s != null && s.isNotEmpty).join(' '),
                          style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          perfil?.email ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.white)),
                  error: (e, _) => const Icon(Icons.error_outline, color: AppColors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(context.l10n.drawerMiCuenta),
                onTap: () => _navigate(context, '/account'),
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(context.l10n.drawerSistema),
                  onTap: () => _navigate(context, '/admin'),
                ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(context.l10n.drawerConfiguracion),
                  onTap: () => _navigate(context, '/admin/configuracion'),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Transform.scale(scale: 0.7, child: const XagaLabsLogo(dark: true)),
                ),
              ),
              const Divider(height: 1, color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(context.l10n.drawerCerrarSesion),
                onTap: () => _signOut(context, ref),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
