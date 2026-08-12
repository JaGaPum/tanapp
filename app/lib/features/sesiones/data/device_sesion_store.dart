import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Qué fila de "TSistemaSesiones" corresponde a ESTE dispositivo, persistido en
/// SharedPreferences. Hace falta porque, al permitir sesiones concurrentes (varias sedes a la
/// vez), "la sesión abierta más reciente del usuario" ya no identifica de forma fiable la
/// sesión de este dispositivo en concreto.
class DeviceSesionStore {
  static const _clave = 'idSistemaSesionActual';

  Future<String?> leer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clave);
  }

  Future<void> guardar(String idSistemaSesion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, idSistemaSesion);
  }

  Future<void> borrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }
}

final deviceSesionStoreProvider = Provider<DeviceSesionStore>(
  (ref) => DeviceSesionStore(),
);
