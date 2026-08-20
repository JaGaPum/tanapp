import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../archivo/presentation/screens/archivo_screen.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../avisos/application/avisos_providers.dart';
import '../../../avisos/presentation/screens/avisos_enviados_screen.dart';
import '../../../avisos/presentation/screens/avisos_screen.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';
import '../../../notificaciones_push/application/push_service.dart';
import '../../../panel_datos/presentation/screens/panel_datos_screen.dart';
import '../../../publicaciones/presentation/screens/mis_publicaciones_screen.dart';
import '../../../publicar/presentation/screens/publicar_screen.dart';
import '../../../seguidos/presentation/screens/mis_seguidos_screen.dart';
import '../../../sesiones/presentation/widgets/sede_actual_banner.dart';
import '../../../suplantacion/presentation/widgets/banner_suplantacion.dart';
import '../../../tablon/presentation/screens/tablon_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  // Índice de la pestaña "Avisos" dentro de la barra inferior de un usuario ordinario/seguidor
  // (TablonScreen, MisSeguidosScreen, ArchivoScreen, AvisosScreen): solo un seguidor puede
  // recibir un push de aviso (es a quien el trigger le crea el destinatario), así que al tocar
  // esa notificación siempre es esta la pestaña a la que hay que saltar.
  static const _tabIndexAvisosSeguidor = 3;

  int _tabIndex = 0;
  String? _idSesionAnterior;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // El permiso de notificaciones y el registro del token no deben bloquear el primer frame;
    // si el usuario deniega el permiso o falla el registro, la app sigue funcionando igual.
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializarPush());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Igual que hace TablonScreen con las publicaciones: al volver a primer plano, refrescamos
    // el buzón de avisos por si ha llegado algo mientras la app estaba en segundo plano y el
    // usuario no ha tocado la notificación (la ha visto y ha abierto la app directamente).
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(avisosNoLeidosCountProvider);
      ref.invalidate(misAvisosRecibidosProvider);
    }
  }

  Future<void> _inicializarPush() async {
    // El push es solo Android por ahora: en web no hay Firebase configurado.
    if (kIsWeb) return;
    try {
      await ref.read(pushServiceProvider).inicializar();
      // Mensaje recibido con la app abierta en primer plano: no hay ninguna notificación que
      // tocar, pero el buzón de avisos hay que refrescarlo igualmente para que el badge y la
      // lista se enteren sin esperar a que el usuario reabra la app.
      FirebaseMessaging.onMessage.listen(_alRecibirEnPrimerPlano);
      // Notificación tocada con la app en segundo plano, o app abierta desde cero por ella.
      FirebaseMessaging.onMessageOpenedApp.listen(_abrirDesdeNotificacion);
      final mensajeInicial = await FirebaseMessaging.instance
          .getInitialMessage();
      if (mensajeInicial != null) _abrirDesdeNotificacion(mensajeInicial);
    } catch (e) {
      // Sin conexión o Firebase no disponible: no es crítico, pero se deja constancia para
      // poder diagnosticar por qué un dispositivo concreto no llega a registrar su token.
      debugPrint('No se pudo inicializar el push: $e');
    }
  }

  void _alRecibirEnPrimerPlano(RemoteMessage message) {
    if (message.data['idClienteAviso'] != null) {
      ref.invalidate(avisosNoLeidosCountProvider);
      ref.invalidate(misAvisosRecibidosProvider);
    }
  }

  void _abrirDesdeNotificacion(RemoteMessage message) {
    if (!mounted) return;
    final idClienteAviso = message.data['idClienteAviso'];
    if (idClienteAviso != null && idClienteAviso.isNotEmpty) {
      ref.invalidate(avisosNoLeidosCountProvider);
      ref.invalidate(misAvisosRecibidosProvider);
      // Solo un seguidor (no un cliente) tiene esta pestaña en esa posición; si por lo que sea
      // llega este dato con otro tipo de cuenta, no tocamos el índice para no salirnos de rango.
      final esCliente = ref.read(isClienteProvider);
      final esOrdinario = ref.read(esUsuarioOrdinarioProvider);
      if (!esCliente && esOrdinario) {
        setState(() => _tabIndex = _tabIndexAvisosSeguidor);
      }
      return;
    }
    final idClientesSolicitud = message.data['idClientesSolicitud'];
    if (idClientesSolicitud != null && idClientesSolicitud.isNotEmpty) {
      context.push('/admin/solicitudes/$idClientesSolicitud');
      return;
    }
    final idClienteSede = message.data['idClienteSede'];
    if (idClienteSede != null && idClienteSede.isNotEmpty) {
      context.push('/publicaciones/$idClienteSede');
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(currentUserProfileProvider);
    final isCliente = ref.watch(isClienteProvider);
    final esUsuarioOrdinario = ref.watch(esUsuarioOrdinarioProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final avisosNoLeidos = ref.watch(avisosNoLeidosCountProvider).value ?? 0;
    // Un admin suele tener también el rol USUARIO_ORDINARIO, así que al suplantar a otro
    // usuario ordinario la rama de pestañas mostrada no cambia y el IndexedStack de abajo no se
    // reconstruye por sí solo: sin esta key, TablonScreen/SeguidosScreen/etc. seguirían vivos
    // con los datos ya cargados de la sesión anterior. Al cambiar la key con el id de sesión
    // real, Flutter tira todo el subárbol y lo reconstruye desde cero con la sesión nueva.
    ref.watch(authStateChangesProvider);
    final idSesionActual = Supabase.instance.client.auth.currentUser?.id;
    // La pestaña seleccionada no tiene por qué seguir teniendo sentido tras un cambio de
    // identidad (suplantación o volver): se reinicia a la primera para no dejar al usuario
    // suplantado en una pestaña que ni siquiera tiene (p. ej. "Panel de datos" de un cliente).
    if (_idSesionAnterior != null && _idSesionAnterior != idSesionActual) {
      _tabIndex = 0;
    }
    _idSesionAnterior = idSesionActual;

    // Un CLIENTE tiene también el rol USUARIO_ORDINARIO (se lo asigna el alta por defecto),
    // pero su navegación es la suya propia, no la de un usuario ordinario cualquiera.
    final mostrarTabsCliente = isCliente;
    final mostrarTabsOrdinario = !isCliente && esUsuarioOrdinario;
    // Un ADMIN puede además seguir clientes como cualquier usuario ordinario, así que el badge de
    // "Avisos" suma las dos cosas: solicitudes de cliente pendientes de aprobar (solo ADMIN) y
    // avisos propios sin leer (solo si se ven las pestañas de seguidor; los clientes tienen su
    // propia pestaña "Avisos" con el histórico de enviados, sin badge de pendientes).
    final pendientesSolicitudes = isAdmin
        ? ref.watch(solicitudesPendientesCountProvider).value ?? 0
        : 0;
    final pendientes =
        pendientesSolicitudes + (mostrarTabsOrdinario ? avisosNoLeidos : 0);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_florist_outlined,
              color: AppColors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.appTitle,
              style: const TextStyle(color: AppColors.white),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const BannerSuplantacion(),
          const SedeActualBanner(),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(idSesionActual),
              child: mostrarTabsCliente
                  ? IndexedStack(
                      index: _tabIndex,
                      children: const [
                        PublicarScreen(),
                        MisPublicacionesScreen(),
                        AvisosEnviadosScreen(),
                        PanelDatosScreen(),
                      ],
                    )
                  : mostrarTabsOrdinario
                  ? IndexedStack(
                      index: _tabIndex,
                      children: const [
                        TablonScreen(),
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
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text(context.l10n.errorGenerico(e.toString())),
                      ),
                    ),
            ),
          ),
        ],
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
                BottomNavigationBarItem(
                  icon: const Icon(Icons.campaign_outlined),
                  label: context.l10n.tabPublicar,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.feed_outlined),
                  label: context.l10n.tabPublicaciones,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications_outlined),
                  label: context.l10n.avisos,
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
                BottomNavigationBarItem(
                  icon: const Icon(Icons.hearing),
                  label: context.l10n.siguiendoTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bookmark_border),
                  label: context.l10n.arquivo,
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: pendientes > 0,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  label: context.l10n.avisos,
                ),
              ],
            ),
    );
  }
}
