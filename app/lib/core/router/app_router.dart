import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/avisos/presentation/screens/aviso_form_screen.dart';
import '../../features/cliente_sedes/presentation/screens/mis_sedes_screen.dart';
import '../../features/clientes_solicitudes/presentation/screens/solicitud_cliente_form_screen.dart';
import '../../features/clientes_solicitudes/presentation/screens/solicitud_detail_screen.dart';
import '../../features/clientes_solicitudes/presentation/screens/solicitudes_list_screen.dart';
import '../../features/condolencias/presentation/screens/condolencias_screen.dart';
import '../../features/configuracion/presentation/screens/cliente_tipo_detail_screen.dart';
import '../../features/configuracion/presentation/screens/comunicacion_detail_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_cliente_tipos_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_comunicaciones_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_concellos_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_ia_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_provincias_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/importacion_web/presentation/screens/configurar_importacion_web_screen.dart';
import '../../features/propuestas_publicaciones/presentation/screens/propuestas_screen.dart';
import '../../features/publicaciones/presentation/screens/publicacion_escanear_screen.dart';
import '../../features/publicaciones/presentation/screens/publicacion_form_screen.dart';
import '../../features/publicaciones/presentation/screens/publicaciones_list_screen.dart';
import '../../features/seguidos/presentation/screens/seguidos_clientes_screen.dart';
import '../../features/seguidos/presentation/screens/seguidos_concellos_screen.dart';
import '../../features/seguidos/presentation/screens/seguidos_provincias_screen.dart';
import '../../features/zonas_seguidas/presentation/screens/zona_concellos_screen.dart';
import '../../features/seguidos/presentation/screens/buscar_cliente_screen.dart';
import '../../features/zonas_seguidas/presentation/screens/zona_provincias_screen.dart';
import '../../features/sesiones/application/sesion_policy_service.dart';
import '../../features/sistema/presentation/screens/sistema_screen.dart';
import '../../features/sistema_usuarios/data/usuarios_repository.dart';
import '../../features/sistema_usuarios/presentation/screens/usuario_detail_screen.dart';
import '../../features/sistema_usuarios/presentation/screens/usuarios_list_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/terminos/data/terminos_repository.dart';
import '../../features/terminos/presentation/screens/aceptar_terminos_screen.dart';
import '../../features/terminos/presentation/screens/ver_terminos_screen.dart';
import '../l10n/l10n_extensions.dart';
import '../l10n/locale_provider.dart';

const _publicLocations = {
  '/login',
  '/register',
  '/register/verify',
  '/forgot-password',
  '/forgot-password/verify',
  '/reset-password',
  '/solicitud-cliente',
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = Supabase.instance.client.auth.onAuthStateChange;
  final refreshStream = GoRouterRefreshStream(authStream);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshStream,
    redirect: (context, state) async {
      final location = state.matchedLocation;
      // La splash decide ella misma cuándo pasar a "/login" (tras su duración mínima); hasta
      // entonces no se debe evaluar sesión ni nada más, para no saltársela.
      if (location == '/splash') return null;

      var session = Supabase.instance.client.auth.currentSession;
      final isPublic = _publicLocations.contains(location);

      final guard = ref.read(sesionBootstrapGuardProvider);
      if (session != null && !guard.completado) {
        guard.completado = true;
        // El login por contraseña (login_screen.dart) ya marca "completado = true" ANTES de
        // pedir el login y registra la sesión él mismo, así que nunca llega aquí. El login con
        // Google (signInWithOAuth) no puede hacer eso de antemano -no hay forma de saber cuándo
        // volverá el navegador-, así que es aquí, al ver un "signedIn" recién llegado que nadie
        // ha registrado todavía, donde se hace el equivalente a
        // "sesionPolicy.registrarLoginExplicito(...)" del login manual. Un "initialSession" (o
        // cualquier otro evento) en cambio es la sesión persistida de un arranque en frío
        // normal, y sigue el camino de siempre.
        if (refreshStream.ultimoEvento == AuthChangeEvent.signedIn) {
          final perfil = await ref
              .read(usuariosRepositoryProvider)
              .fetchPerfilByAuthId(session.user.id);
          if (perfil != null && perfil.activo) {
            await ref
                .read(sesionPolicyServiceProvider)
                .registrarLoginExplicito(
                  idSistemaUsuario: perfil.idSistemaUsuario,
                  recordar: true,
                );
          } else {
            // Mismo criterio silencioso que ejecutarBootstrap() para perfil nulo: sin perfil o
            // con la cuenta desactivada, se cierra sesión sin más. A diferencia del login por
            // contraseña, aquí no hay una pantalla "a medio enviar" donde mostrar el motivo.
            await Supabase.instance.client.auth.signOut();
          }
        } else {
          await ref.read(sesionPolicyServiceProvider).ejecutarBootstrap();
        }
        session = Supabase.instance.client.auth.currentSession;
      }

      if (session == null) {
        return isPublic ? null : '/login';
      }

      if (isPublic && location != '/reset-password') {
        return '/home';
      }

      // Se calcula aparte del bootstrap de arriba: un login explícito lo salta (ver
      // login_screen.dart), así que hay que comprobarlo también aquí, una sola vez por carga
      // de la app (el resultado queda cacheado en el guard).
      if (guard.necesitaAceptarTerminos == null) {
        try {
          final perfil = await ref
              .read(usuariosRepositoryProvider)
              .fetchPerfilByAuthId(session.user.id);
          if (perfil == null) {
            guard.necesitaAceptarTerminos = false;
          } else {
            final idiomaCodigo =
                ref.read(appLocaleProvider).languageCode == 'gl' ? 'GL' : 'ES';
            final pendientes = await ref
                .read(terminosRepositoryProvider)
                .fetchPendientes(
                  perfil.idSistemaUsuario,
                  perfil.roles,
                  idiomaCodigo,
                );
            guard.necesitaAceptarTerminos = pendientes.isNotEmpty;
          }
        } catch (e) {
          // Si la migración de TSistemaTerminos aún no está aplicada (u otro fallo puntual),
          // no se debe bloquear el acceso a toda la app por esto: se reintenta en la próxima
          // navegación (necesitaAceptarTerminos sigue en null).
          debugPrint('No se pudo comprobar los términos pendientes: $e');
        }
      }

      final necesitaAceptarTerminos = guard.necesitaAceptarTerminos ?? false;
      if (necesitaAceptarTerminos && location != '/aceptar-terminos') {
        return '/aceptar-terminos';
      }
      if (!necesitaAceptarTerminos && location == '/aceptar-terminos') {
        return '/home';
      }

      if (location.startsWith('/admin')) {
        final repo = ref.read(usuariosRepositoryProvider);
        final perfil = await repo.fetchPerfilByAuthId(session.user.id);
        final isAdmin = perfil?.roles.contains('ADMIN') ?? false;
        if (!isAdmin) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register/verify',
        builder: (context, state) => VerifyOtpScreen(
          email: state.extra as String? ?? '',
          purpose: OtpPurpose.signup,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password/verify',
        builder: (context, state) => VerifyOtpScreen(
          email: state.extra as String? ?? '',
          purpose: OtpPurpose.recovery,
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/solicitud-cliente',
        builder: (context, state) => const SolicitudClienteFormScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/aceptar-terminos',
        builder: (context, state) => const AceptarTerminosScreen(),
      ),
      GoRoute(
        path: '/terminos',
        builder: (context, state) => const VerTerminosScreen(),
      ),
      GoRoute(
        path: '/mis-sedes',
        builder: (context, state) => const MisSedesScreen(),
      ),
      GoRoute(
        path: '/publicar/manual',
        builder: (context, state) {
          final datos = state.extra as Map<String, String?>?;
          final fechaFallecimiento = datos?['fechaFallecimiento'];
          final edad = datos?['edad'];
          final fechaFuneral = datos?['fechaFuneral'];
          return PublicacionFormScreen(
            idClientePublicacion: datos?['idClientePublicacion'],
            idClienteSedeInicial: datos?['idClienteSede'],
            nombreInicial: datos?['nombre'],
            fechaFallecimientoInicial: fechaFallecimiento != null
                ? DateTime.parse(fechaFallecimiento)
                : null,
            edadInicial: edad != null ? int.tryParse(edad) : null,
            fechaFuneralInicial: fechaFuneral != null
                ? DateTime.parse(fechaFuneral)
                : null,
            horaFuneralInicial: datos?['horaFuneral'],
            iglesiaInicial: datos?['iglesia'],
            lugarInicial: datos?['lugar'],
            capillaArdienteInicial: datos?['capillaArdiente'],
            salaInicial: datos?['sala'],
            observacionesInicial: datos?['observaciones'],
            avisoInicial: datos?['avisoOcr'],
            idClientePublicacionPropuestaInicial:
                datos?['idClientePublicacionPropuesta'],
          );
        },
      ),
      GoRoute(
        path: '/publicar/escanear',
        builder: (context, state) => const PublicacionEscanearScreen(),
      ),
      GoRoute(
        path: '/publicar/importar-web',
        builder: (context, state) => const ConfigurarImportacionWebScreen(),
      ),
      GoRoute(
        path: '/publicar/propuestas',
        builder: (context, state) => const PropuestasScreen(),
      ),
      GoRoute(
        path: '/publicar/avisos',
        builder: (context, state) => const AvisoFormScreen(),
      ),
      GoRoute(
        path: '/publicaciones/:sedeId',
        builder: (context, state) => PublicacionesListScreen(
          titulo:
              state.extra as String? ?? context.l10n.publicarNuevaPublicacion,
          idClienteSede: state.pathParameters['sedeId']!,
        ),
      ),
      GoRoute(
        path: '/publicacion/:idClientePublicacion/condolencias',
        builder: (context, state) {
          final datos = state.extra as Map<String, String?>?;
          return CondolenciasScreen(
            idClientePublicacion: state.pathParameters['idClientePublicacion']!,
            nombreFallecido: datos?['nombreFallecido'] ?? '',
            idClienteSede: datos?['idClienteSede'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const SistemaScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin/configuracion',
        builder: (context, state) => const ConfiguracionScreen(),
        routes: [
          GoRoute(
            path: 'provincias',
            builder: (context, state) => const ConfiguracionProvinciasScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => ConfiguracionConcellosScreen(
                  idConfiguracionProvincia: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'comunicaciones',
            builder: (context, state) =>
                const ConfiguracionComunicacionesScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (context, state) => const ComunicacionDetailScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ComunicacionDetailScreen(
                  idConfiguracionComunicacion: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'tipos-cliente',
            builder: (context, state) =>
                const ConfiguracionClienteTiposScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (context, state) => const ClienteTipoDetailScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ClienteTipoDetailScreen(
                  idConfiguracionClienteTipo: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'ia',
            builder: (context, state) => const ConfiguracionIaScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/usuarios',
        builder: (context, state) => const UsuariosListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => UsuarioDetailScreen(
              idSistemaUsuario: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/seguidos/:tipoId/provincias',
        builder: (context, state) => SeguidosProvinciasScreen(
          idConfiguracionClienteTipo: state.pathParameters['tipoId']!,
        ),
        routes: [
          GoRoute(
            path: ':provinciaId/concellos',
            builder: (context, state) => SeguidosConcellosScreen(
              idConfiguracionClienteTipo: state.pathParameters['tipoId']!,
              idConfiguracionProvincia: state.pathParameters['provinciaId']!,
            ),
            routes: [
              GoRoute(
                path: ':concelloId/clientes',
                builder: (context, state) => SeguidosClientesScreen(
                  idConfiguracionClienteTipo: state.pathParameters['tipoId']!,
                  idConfiguracionProvincia:
                      state.pathParameters['provinciaId']!,
                  idConfiguracionConcello: state.pathParameters['concelloId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/seguidos-nuevo',
        builder: (context, state) => const BuscarClienteScreen(),
      ),
      GoRoute(
        path: '/seguidos-zona/provincias',
        builder: (context, state) => const ZonaProvinciasScreen(),
        routes: [
          GoRoute(
            path: ':provinciaId/concellos',
            builder: (context, state) => ZonaConcellosScreen(
              idConfiguracionProvincia: state.pathParameters['provinciaId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/solicitudes',
        builder: (context, state) => const SolicitudesListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => SolicitudDetailScreen(
              idClientesSolicitud: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  /// El evento que trajo el último cambio de sesión: permite distinguir en el `redirect` de
  /// arriba un "signedIn" recién llegado (login interactivo, incluido el de Google) de un
  /// "initialSession" (sesión persistida recuperada en un arranque en frío normal).
  AuthChangeEvent? ultimoEvento;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((estado) {
      ultimoEvento = estado.event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
