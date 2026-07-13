import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../avisos/presentation/screens/avisos_screen.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';
import '../../../seguidos/presentation/screens/seguidos_screen.dart';
import '../../../tablon/presentation/screens/tablon_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final esUsuarioOrdinario = ref.watch(esUsuarioOrdinarioProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final pendientes = isAdmin ? ref.watch(solicitudesPendientesCountProvider).value ?? 0 : 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_florist_outlined, color: AppColors.white, size: 28),
            const SizedBox(width: 8),
            Text(context.l10n.appTitle, style: const TextStyle(color: AppColors.white)),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: esUsuarioOrdinario
          ? IndexedStack(
              index: _tabIndex,
              children: const [TablonScreen(), SeguidosScreen(), AvisosScreen()],
            )
          : perfilAsync.when(
              data: (perfil) => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(context.l10n.holaNombre(perfil?.nombre ?? ''), style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
            ),
      bottomNavigationBar: !esUsuarioOrdinario
          ? null
          : BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: (index) => setState(() => _tabIndex = index),
              backgroundColor: AppColors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.white,
              unselectedItemColor: Colors.white70,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.dynamic_feed_outlined), label: context.l10n.tablon),
                BottomNavigationBarItem(icon: const Icon(Icons.people_outline), label: context.l10n.seguidos),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: pendientes > 0,
                    backgroundColor: const Color(0xFFD50000),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  label: context.l10n.avisos,
                ),
              ],
            ),
    );
  }
}
