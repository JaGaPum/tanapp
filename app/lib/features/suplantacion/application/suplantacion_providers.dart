import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cliente_sedes/data/cliente_sedes_repository.dart';
import '../../sesiones/application/sesion_policy_service.dart';
import '../../sesiones/data/device_sesion_store.dart';
import '../../sesiones/data/sesiones_repository.dart';
import '../data/suplantacion_repository.dart';

/// Quién inició la sesión secundaria activa: determina qué banner/copia mostrar y a qué cuenta
/// corresponde "volver".
enum ModoSesionSecundaria {
  /// Un ADMIN suplantando a otro usuario (ficha de usuario -> "Suplantar usuario").
  admin,

  /// Un CLIENTE en su propia cuenta personal USUARIO_ORDINARIO vinculada (063): puede seguir
  /// clientes/zonas y dejar condolencias con la misma libertad que cualquier otro usuario.
  cuentaPropia,
}

/// Datos que hacen falta mientras hay una sesión secundaria activa (suplantación de admin, o
/// cuenta personal de un cliente): el refresh token de la sesión ORIGINAL (para poder volver) y
/// el id de la fila de "TSistemaSesiones" creada para la sesión secundaria. Esta última es
/// necesaria aparte de la sesión "real" del dispositivo (que sigue intacta y ligada a
/// [DeviceSesionStore] todo el rato): sin una sesión propia, "elegir sede" y cualquier pantalla
/// que dependa de "sesionActualProvider" seguían mirando la sesión original en vez de la nueva.
class SesionSuplantada {
  final String refreshTokenOriginal;
  final String idSistemaSesionSecundaria;
  final ModoSesionSecundaria modo;
  const SesionSuplantada({
    required this.refreshTokenOriginal,
    required this.idSistemaSesionSecundaria,
    required this.modo,
  });
}

class SesionAdminGuardadaNotifier extends Notifier<SesionSuplantada?> {
  @override
  SesionSuplantada? build() => null;

  Future<void> suplantar(String idSistemaUsuarioObjetivo) =>
      _cambiarA(idSistemaUsuarioObjetivo, ModoSesionSecundaria.admin);

  /// Crea (la primera vez) o reutiliza la cuenta personal USUARIO_ORDINARIO vinculada del
  /// CLIENTE actual, y cambia la sesión a ella.
  Future<void> entrarComoCuentaPropia() async {
    final idCuentaPropia = await ref
        .read(suplantacionRepositoryProvider)
        .obtenerOCrearCuentaOrdinariaVinculada();
    await _cambiarA(idCuentaPropia, ModoSesionSecundaria.cuentaPropia);
  }

  Future<void> _cambiarA(
    String idSistemaUsuarioObjetivo,
    ModoSesionSecundaria modo,
  ) async {
    final client = Supabase.instance.client;
    final refreshTokenOriginal = client.auth.currentSession?.refreshToken;
    if (refreshTokenOriginal == null) {
      throw Exception('No hay sesión activa');
    }
    await ref
        .read(suplantacionRepositoryProvider)
        .cambiarSesionA(idSistemaUsuarioObjetivo);

    // A partir de aquí el cliente de Supabase ya está autenticado como el usuario objetivo. Se le
    // crea una sesión propia -mismo dispositivo físico, pero SIN tocar el puntero de
    // DeviceSesionStore, que se deja intacto apuntando a la sesión original- para que "elegir
    // sede" y "sesionActualProvider" funcionen igual que en un login normal. No se marca
    // "Recordar": si se recarga la app a medias, debe pedir volver a entrar, no reanudar solo.
    final sesionesRepo = ref.read(sesionesRepositoryProvider);
    final idDispositivo = await ref
        .read(deviceSesionStoreProvider)
        .leerOCrearIdDispositivo();
    final nueva = await sesionesRepo.crearSesion(
      idSistemaUsuario: idSistemaUsuarioObjetivo,
      recordar: false,
      idDispositivo: idDispositivo,
    );

    // Igual que un login normal: si el usuario objetivo es CLIENTE de una única sede, se le
    // asigna sola; con varias, se deja sin asignar para que el router pida elegirla. Para el modo
    // "cuentaPropia" esto no aplica (no es CLIENTE) y la lista sale vacía sin más.
    final sedes = await ref
        .read(clienteSedesRepositoryProvider)
        .listSedesDeUsuario(idSistemaUsuarioObjetivo);
    if (sedes.length == 1) {
      await sesionesRepo.asignarSede(
        idSistemaSesion: nueva.idSistemaSesion,
        idClienteSede: sedes.single.idClienteSede,
      );
    }

    // El guard de arranque ya está "completado" (viene de cuando entró la identidad original) así
    // que el router no vuelve a pasar por el registro de sesión al ver este cambio de auth -ya lo
    // acabamos de hacer a mano arriba-, pero sus comprobaciones de términos/idioma/sede seguían
    // cacheadas para la identidad original: se limpian para que se recalculen para la nueva.
    final guard = ref.read(sesionBootstrapGuardProvider);
    guard.necesitaAceptarTerminos = null;
    guard.necesitaElegirIdioma = null;
    guard.necesitaElegirSede = null;

    // Solo se guarda una vez confirmado todo lo anterior: si algo lanza, la identidad original se
    // queda en su propia sesión de siempre, sin banner de "volver" a medias.
    state = SesionSuplantada(
      refreshTokenOriginal: refreshTokenOriginal,
      idSistemaSesionSecundaria: nueva.idSistemaSesion,
      modo: modo,
    );
  }

  Future<void> volver() async {
    final actual = state;
    if (actual == null) return;
    state = null;
    // Se cierra mientras todavía se es el usuario de la sesión secundaria (dueño de la fila): más
    // simple que depender del bypass de RLS de ADMIN, que ya no aplica una vez hecho el
    // "setSession" de abajo.
    await ref
        .read(sesionesRepositoryProvider)
        .cerrarSesion(actual.idSistemaSesionSecundaria);
    await Supabase.instance.client.auth.setSession(actual.refreshTokenOriginal);
    final guard = ref.read(sesionBootstrapGuardProvider);
    guard.necesitaAceptarTerminos = null;
    guard.necesitaElegirIdioma = null;
    guard.necesitaElegirSede = null;
  }
}

final sesionAdminGuardadaProvider =
    NotifierProvider<SesionAdminGuardadaNotifier, SesionSuplantada?>(
      SesionAdminGuardadaNotifier.new,
    );
