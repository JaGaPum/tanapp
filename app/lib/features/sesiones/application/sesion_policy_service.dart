import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../sistema_usuarios/data/usuarios_repository.dart';
import '../data/sesiones_repository.dart';

/// Implementa "recordarme" sin caducidad por tiempo (app pensada para móvil, donde no se
/// quiere pedir login continuamente):
/// - Sesión abierta con Recordar=true: se reanuda sin pedir credenciales, sin límite de tiempo.
/// - Sesión abierta con Recordar=false, o sin sesión abierta: se fuerza login en cada arranque.
class SesionPolicyService {
  final SesionesRepository _sesionesRepo;
  final UsuariosRepository _usuariosRepo;
  final AuthRepository _authRepo;

  SesionPolicyService(this._sesionesRepo, this._usuariosRepo, this._authRepo);

  /// Devuelve true si se forzó el cierre de sesión (el router debe mandar a /login).
  Future<bool> ejecutarBootstrap() async {
    final user = _authRepo.currentUser;
    if (user == null) return false;

    final perfil = await _usuariosRepo.fetchPerfilByAuthId(user.id);
    if (perfil == null) {
      await _authRepo.signOut();
      return true;
    }

    final abierta = await _sesionesRepo.fetchUltimaSesionAbierta(perfil.idSistemaUsuario);
    if (abierta == null) {
      await _authRepo.signOut();
      return true;
    }

    if (abierta.recordar) {
      await _sesionesRepo.tocarSesion(abierta.idSistemaSesion);
      return false;
    }

    await _sesionesRepo.cerrarSesion(abierta.idSistemaSesion);
    await _authRepo.signOut();
    return true;
  }

  Future<void> registrarLoginExplicito({required String idSistemaUsuario, required bool recordar}) async {
    await _sesionesRepo.cerrarSesionesAbiertas(idSistemaUsuario);
    await _sesionesRepo.crearSesion(idSistemaUsuario: idSistemaUsuario, recordar: recordar);
  }
}

final sesionPolicyServiceProvider = Provider<SesionPolicyService>((ref) {
  return SesionPolicyService(
    ref.watch(sesionesRepositoryProvider),
    ref.watch(usuariosRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});

/// Guard para que el bootstrap de sesión se ejecute una sola vez por carga de app.
class SesionBootstrapGuard {
  bool completado = false;

  /// Si el usuario tiene documentos legales pendientes de aceptar (null = aún sin calcular).
  /// Se calcula aparte de [completado] porque un login explícito salta el bootstrap
  /// (ver `login_screen.dart`) y aun así hay que comprobar los términos.
  bool? necesitaAceptarTerminos;
}

final sesionBootstrapGuardProvider = Provider<SesionBootstrapGuard>((ref) => SesionBootstrapGuard());
