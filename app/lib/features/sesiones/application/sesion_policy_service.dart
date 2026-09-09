import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../cliente_sedes/data/cliente_sedes_repository.dart';
import '../../sistema_usuarios/data/usuarios_repository.dart';
import '../data/device_info_helper.dart';
import '../data/device_sesion_store.dart';
import '../data/sesiones_repository.dart';

/// Implementa "recordarme" sin caducidad por tiempo (app pensada para móvil, donde no se
/// quiere pedir login continuamente):
/// - Sesión abierta con Recordar=true: se reanuda sin pedir credenciales, sin límite de tiempo.
/// - Sesión abierta con Recordar=false, o sin sesión abierta: se fuerza login en cada arranque.
///
/// Un mismo usuario puede tener varias sesiones abiertas a la vez en dispositivos distintos (un
/// cliente con varias sedes puede trabajar desde varios sitios). Lo que NO puede pasar es que un
/// mismo dispositivo tenga más de una sesión "ABIERTA" a la vez (ver 057 y
/// [DeviceSesionStore.leerOCrearIdDispositivo]): antes de dar por buena una sesión (nueva o
/// reutilizada) se cierran todas las demás que sigan abiertas de ese mismo dispositivo, sea cual
/// sea el usuario al que pertenezcan. Si el usuario es CLIENTE con una única sede, se le asigna
/// sola sin preguntar (con varias sedes, quien pregunta es la pantalla "elegir sede" del router).
class SesionPolicyService {
  final SesionesRepository _sesionesRepo;
  final UsuariosRepository _usuariosRepo;
  final AuthRepository _authRepo;
  final ClienteSedesRepository _sedesRepo;
  final DeviceSesionStore _deviceSesionStore;

  SesionPolicyService(
    this._sesionesRepo,
    this._usuariosRepo,
    this._authRepo,
    this._sedesRepo,
    this._deviceSesionStore,
  );

  /// Devuelve true si se forzó el cierre de sesión (el router debe mandar a /login).
  Future<bool> ejecutarBootstrap() async {
    final user = _authRepo.currentUser;
    if (user == null) return false;

    final perfil = await _usuariosRepo.fetchPerfilByAuthId(user.id);
    if (perfil == null) {
      await _authRepo.signOut();
      return true;
    }

    // Primero se intenta resolver la sesión de ESTE dispositivo por el id guardado en local;
    // si no hay nada guardado (instalación nueva, caché borrada...) se cae al criterio anterior
    // ("la más reciente del usuario") como mejor opción disponible.
    final idLocal = await _deviceSesionStore.leer();
    var abierta = idLocal == null
        ? null
        : await _sesionesRepo.fetchPorId(idLocal);
    if (abierta == null ||
        !abierta.abierta ||
        abierta.idSistemaUsuario != perfil.idSistemaUsuario) {
      abierta = await _sesionesRepo.fetchUltimaSesionAbierta(
        perfil.idSistemaUsuario,
      );
    }
    if (abierta == null) {
      await _authRepo.signOut();
      return true;
    }

    if (abierta.recordar) {
      await _sesionesRepo.tocarSesion(abierta.idSistemaSesion);
      await _deviceSesionStore.guardar(abierta.idSistemaSesion);
      final idDispositivo = await _deviceSesionStore.leerOCrearIdDispositivo();
      await _sesionesRepo.vincularDispositivo(
        abierta.idSistemaSesion,
        idDispositivo,
      );
      await _sesionesRepo.cerrarOtrasSesionesDelDispositivo(
        idDispositivo: idDispositivo,
        excluirIdSistemaSesion: abierta.idSistemaSesion,
      );
      if (abierta.idClienteSede == null) {
        await _autoAsignarSedeUnica(
          idSistemaUsuario: perfil.idSistemaUsuario,
          idSistemaSesion: abierta.idSistemaSesion,
          roles: perfil.roles,
        );
      }
      return false;
    }

    await _sesionesRepo.cerrarSesion(abierta.idSistemaSesion);
    await _deviceSesionStore.borrar();
    await _authRepo.signOut();
    return true;
  }

  /// Cierra por completo la sesión de ESTE dispositivo: la fila de "TSistemaSesiones" (si la
  /// hay), el puntero local en [DeviceSesionStore] y la sesión de Supabase Auth. Antes de esto,
  /// "Cerrar sesión" solo cerraba la sesión de Auth y dejaba la fila de TSistemaSesiones
  /// "ABIERTA" para siempre (se veían sesiones "Abertas"/"En curso" en el panel de admin que en
  /// realidad ya nadie estaba usando).
  Future<void> cerrarSesionActual() async {
    final idLocal = await _deviceSesionStore.leer();
    if (idLocal != null) {
      await _sesionesRepo.cerrarSesion(idLocal);
      await _deviceSesionStore.borrar();
    }
    await _authRepo.signOut();
  }

  Future<void> registrarLoginExplicito({
    required String idSistemaUsuario,
    required bool recordar,
    required List<String> roles,
  }) async {
    final idDispositivo = await _deviceSesionStore.leerOCrearIdDispositivo();

    // Si este dispositivo ya tiene una sesión abierta de este mismo usuario (p. ej. quien
    // vuelve a meter sus credenciales sin haber cerrado sesión antes, como al probar el login
    // varias veces seguidas), se reutiliza esa fila en vez de crear otra: sin esto, cada login
    // explícito abría una "TSistemaSesiones" nueva y dejaba la anterior huérfana (abierta, pero
    // sin que ningún dispositivo apuntase ya a ella).
    final idLocal = await _deviceSesionStore.leer();
    final existente = idLocal == null
        ? null
        : await _sesionesRepo.fetchPorId(idLocal);
    final String idSistemaSesion;
    if (existente != null &&
        existente.abierta &&
        existente.idSistemaUsuario == idSistemaUsuario) {
      await _sesionesRepo.actualizarRecordar(
        existente.idSistemaSesion,
        recordar,
      );
      await _sesionesRepo.tocarSesion(existente.idSistemaSesion);
      idSistemaSesion = existente.idSistemaSesion;
    } else {
      final nueva = await _sesionesRepo.crearSesion(
        idSistemaUsuario: idSistemaUsuario,
        recordar: recordar,
        idDispositivo: idDispositivo,
        dispositivo: await obtenerDescripcionDispositivo(),
      );
      await _deviceSesionStore.guardar(nueva.idSistemaSesion);
      idSistemaSesion = nueva.idSistemaSesion;
    }
    // Vincula el dispositivo (backfill si la fila reutilizada es de antes de 057) y cierra
    // cualquier otra sesión que siga abierta de este mismo dispositivo, sea de este usuario o de
    // otro: así solo puede quedar una sesión "ABIERTA" por dispositivo.
    await _sesionesRepo.vincularDispositivo(idSistemaSesion, idDispositivo);
    await _sesionesRepo.cerrarOtrasSesionesDelDispositivo(
      idDispositivo: idDispositivo,
      excluirIdSistemaSesion: idSistemaSesion,
    );
    await _autoAsignarSedeUnica(
      idSistemaUsuario: idSistemaUsuario,
      idSistemaSesion: idSistemaSesion,
      roles: roles,
    );
  }

  /// Si es CLIENTE y solo tiene una sede, se la asigna sin preguntar: la pantalla de elegir
  /// sede (gate del router) solo hace falta cuando hay más de una entre las que elegir.
  Future<void> _autoAsignarSedeUnica({
    required String idSistemaUsuario,
    required String idSistemaSesion,
    required List<String> roles,
  }) async {
    if (!roles.contains('CLIENTE')) return;
    final sedes = await _sedesRepo.listSedesDeUsuario(idSistemaUsuario);
    if (sedes.length == 1) {
      await _sesionesRepo.asignarSede(
        idSistemaSesion: idSistemaSesion,
        idClienteSede: sedes.single.idClienteSede,
      );
    }
  }
}

final sesionPolicyServiceProvider = Provider<SesionPolicyService>((ref) {
  return SesionPolicyService(
    ref.watch(sesionesRepositoryProvider),
    ref.watch(usuariosRepositoryProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(clienteSedesRepositoryProvider),
    ref.watch(deviceSesionStoreProvider),
  );
});

/// Guard para que el bootstrap de sesión se ejecute una sola vez por carga de app.
class SesionBootstrapGuard {
  bool completado = false;

  /// Si el usuario tiene documentos legales pendientes de aceptar (null = aún sin calcular).
  /// Se calcula aparte de [completado] porque un login explícito salta el bootstrap
  /// (ver `login_screen.dart`) y aun así hay que comprobar los términos.
  bool? necesitaAceptarTerminos;

  /// Si es CLIENTE con más de una sede y esta sesión (la de este dispositivo) todavía no tiene
  /// ninguna asignada (null = aún sin calcular). Igual que [necesitaAceptarTerminos], aparte de
  /// [completado] porque un login explícito también necesita pasar por esta comprobación.
  bool? necesitaElegirSede;

  /// Si el usuario (no ADMIN) todavía no ha pasado por "Elige tu idioma", justo después de
  /// aceptar términos (null = aún sin calcular). Mismo criterio que los dos de arriba.
  bool? necesitaElegirIdioma;

  /// Si el ADMIN le ha marcado "DebeCambiarContrasena" (068, null = aún sin calcular). Cuando es
  /// true se activa [enRecuperacionContrasena] para forzar "/reset-password" con el mismo
  /// mecanismo de abajo, sin tener que volver a consultar la base de datos en cada "redirect".
  bool? necesitaCambiarContrasena;

  /// true entre que se valida el código de "olvidé mi contraseña" y que se guarda la nueva: lo
  /// pone `verify_otp_screen.dart` y lo quita `reset_password_screen.dart` al terminar. Mientras
  /// esté activo, el router fuerza "/reset-password" pase lo que pase (ver `app_router.dart`),
  /// para que a nadie se le pueda colar sin fijar la contraseña nueva primero -no se usa el
  /// último evento de auth para esto porque sigue siendo "passwordRecovery" un buen rato después
  /// de guardar la contraseña, y detectar el evento nuevo llegaría con retraso-.
  bool enRecuperacionContrasena = false;
}

final sesionBootstrapGuardProvider = Provider<SesionBootstrapGuard>(
  (ref) => SesionBootstrapGuard(),
);
