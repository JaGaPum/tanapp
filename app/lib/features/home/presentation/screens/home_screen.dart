import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../archivo/presentation/screens/archivo_screen.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../avisos/presentation/screens/avisos_screen.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';
import '../../../notificaciones_push/application/push_service.dart';
import '../../../panel_datos/presentation/screens/panel_datos_screen.dart';
import '../../../publicaciones/presentation/screens/mis_publicaciones_screen.dart';
import '../../../publicar/presentation/screens/publicar_screen.dart';
import '../../../seguidos/presentation/screens/mis_seguidos_screen.dart';
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
  void initState() {
    super.initState();
    // El permiso de notificaciones y el registro del token no deben bloquear el primer frame;
    // si el usuario deniega el permiso o falla el registro, la app sigue funcionando igual.
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializarPush());
  }

  Future<void> _inicializarPush() async {
    // El push es solo Android por ahora: en web no hay Firebase configurado.
    if (kIsWeb) return;
    try {
      await ref.read(pushServiceProvider).inicializar();
      // Notificación tocada con la app en segundo plano, o app abierta desde cero por ella.
      FirebaseMessaging.onMessageOpenedApp.listen(_abrirDesdeNotificacion);
      final mensajeInicial = await FirebaseMessaging.instance.getInitialMessage();
      if (mensajeInicial != null) _abrirDesdeNotificacion(mensajeInicial);
    } catch (_) {
      // Sin conexión o Firebase no disponible: no es crítico.
    }
  }

  void _abrirDesdeNotificacion(RemoteMessage message) {
    final idClienteSede = message.data['idClienteSede'];
    if (idClienteSede != null && idClienteSede.isNotEmpty && mounted) {
      context.push('/publicaciones/$idClienteSede');
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final isCliente = ref.watch(isClienteProvider);
    final esUsuarioOrdinario = ref.watch(esUsuarioOrdinarioProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final pendientes = isAdmin ? ref.watch(solicitudesPendientesCountProvider).value ?? 0 : 0;

    // Un CLIENTE tiene también el rol USUARIO_ORDINARIO (se lo asigna el alta por defecto),
    // pero su navegación es la suya propia, no la de un usuario ordinario cualquiera.
    final mostrarTabsCliente = isCliente;
    final mostrarTabsOrdinario = !isCliente && esUsuarioOrdinario;

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
      body: mostrarTabsCliente
          ? IndexedStack(
              index: _tabIndex,
              children: const [PublicarScreen(), MisPublicacionesScreen(), PanelDatosScreen()],
            )
          : mostrarTabsOrdinario
              ? IndexedStack(
                  index: _tabIndex,
                  children: const [
                    TablonScreen(),
                    SeguidosScreen(),
                    MisSeguidosScreen(),
                    ArchivoScreen(),
                    AvisosScreen(),
                  ],
                )
              : perfilAsync.when(
                  data: (perfil) => ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        context.l10n.holaNombre(perfil?.nombre ?? ''),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
                ),
      bottomNavigationBar: mostrarTabsCliente
          ? BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: (index) => setState(() => _tabIndex = index),
              backgroundColor: AppColors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.white,
              unselectedItemColor: Colors.white70,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.campaign_outlined), label: context.l10n.tabPublicar),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.feed_outlined),
                  label: context.l10n.tabPublicaciones,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard_outlined),
                  label: context.l10n.tabPanelDatos,
                ),
              ],
            )
          : !mostrarTabsOrdinario
              ? null
              : BottomNavigationBar(
                  currentIndex: _tabIndex,
                  onTap: (index) => setState(() => _tabIndex = index),
                  backgroundColor: AppColors.black,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.white,
                  unselectedItemColor: Colors.white70,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.dynamic_feed_outlined),
                      label: context.l10n.tablon,
                    ),
                    BottomNavigationBarItem(icon: const Icon(Icons.search), label: context.l10n.seguidos),
                    BottomNavigationBarItem(icon: const Icon(Icons.hearing), label: context.l10n.siguiendoTab),
                    BottomNavigationBarItem(icon: const Icon(Icons.bookmark_border), label: context.l10n.arquivo),
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
