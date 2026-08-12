import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../cliente_sedes/data/cliente_sedes_repository.dart';
import '../../sistema_usuarios/data/usuarios_repository.dart';
import '../data/device_sesion_store.dart';
import '../data/sesiones_repository.dart';

/// Implementa "recordarme" sin caducidad por tiempo (app pensada para móvil, donde no se
/// quiere pedir login continuamente):
/// - Sesión abierta con Recordar=true: se reanuda sin pedir credenciales, sin límite de tiempo.
/// - Sesión abierta con Recordar=false, o sin sesión abierta: se fuerza login en cada arranque.
///
/// Un mismo usuario puede tener varias sesiones abiertas a la vez (un cliente con varias sedes
/// puede trabajar desde varios sitios): ya no se cierran las demás al iniciar sesión. Lo que sí
/// hace falta es saber qué fila de "TSistemaSesiones" es la de ESTE dispositivo en concreto
/// (ver [DeviceSesionStore]), y si el usuario es CLIENTE con una única sede, asignársela sola
/// sin preguntar (con varias sedes, quien pregunta es la pantalla "elegir sede" del router).
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
    await _authRepo.signOut();
    return true;
  }

  Future<void> registrarLoginExplicito({
    required String idSistemaUsuario,
    required bool recordar,
    required List<String> roles,
  }) async {
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
      );
      await _deviceSesionStore.guardar(nueva.idSistemaSesion);
      idSistemaSesion = nueva.idSistemaSesion;
    }
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
}

final sesionBootstrapGuardProvider = Provider<SesionBootstrapGuard>(
  (ref) => SesionBootstrapGuard(),
);
