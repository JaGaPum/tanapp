import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Qué fila de "TSistemaSesiones" corresponde a ESTE dispositivo, persistido en
/// SharedPreferences. Hace falta porque, al permitir sesiones concurrentes (varias sedes a la
/// vez), "la sesión abierta más reciente del usuario" ya no identifica de forma fiable la
/// sesión de este dispositivo en concreto.
class DeviceSesionStore {
  static const _clave = 'idSistemaSesionActual';

  /// Identificador estable del dispositivo (no de la sesión): se genera una sola vez y se
  /// mantiene igual aunque se cierre sesión, para poder cerrar en el servidor cualquier otra
  /// sesión abierta de este mismo dispositivo (ver 057), sea del mismo usuario o de otro.
  static const _claveDispositivo = 'idDispositivo';

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

  Future<String> leerOCrearIdDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final existente = prefs.getString(_claveDispositivo);
    if (existente != null) return existente;
    final nuevo = const Uuid().v4();
    await prefs.setString(_claveDispositivo, nuevo);
    return nuevo;
  }
}

final deviceSesionStoreProvider = Provider<DeviceSesionStore>(
  (ref) => DeviceSesionStore(),
);
