import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';

class SuplantacionRepository {
  final SupabaseClient _client;
  SuplantacionRepository(this._client);

  /// Pide a la Edge Function "suplantar-usuario" un token de acceso al usuario indicado y lo
  /// canjea de inmediato por una sesión real: a partir de aquí el cliente de Supabase queda
  /// logueado como ese usuario. La función acepta dos casos (ver su cabecera): un ADMIN
  /// suplantando a cualquier otro usuario, o un CLIENTE entrando en su propia cuenta personal ya
  /// vinculada (063) — esta misma llamada sirve para ambos, la función decide según quién llama.
  Future<void> cambiarSesionA(String idSistemaUsuarioObjetivo) async {
    final Map data;
    try {
      final respuesta = await _client.functions.invoke(
        'suplantar-usuario',
        body: {'idSistemaUsuarioObjetivo': idSistemaUsuarioObjetivo},
      );
      if (respuesta.data is! Map) {
        throw AppException('Respuesta inesperada del servidor');
      }
      data = respuesta.data as Map;
    } on FunctionException catch (e) {
      // Cualquier respuesta con código distinto de 2xx (401/403/400/404/500 de la función) llega
      // aquí como excepción, no como "respuesta.data": hay que sacar el mensaje real de "details"
      // (el cuerpo JSON {"error": "..."} que devuelve la función) para no mostrar un genérico
      // "error inesperado" que oculta por qué ha fallado de verdad.
      final details = e.details;
      final mensaje = details is Map && details['error'] != null
          ? details['error'].toString()
          : (e.reasonPhrase ?? 'Error ${e.status}');
      throw AppException(mensaje);
    }
    if (data['tokenHash'] is! String) {
      throw AppException(
        data['error']?.toString() ?? 'Respuesta inesperada del servidor',
      );
    }
    await _client.auth.verifyOTP(
      type: OtpType.magiclink,
      tokenHash: data['tokenHash'] as String,
    );
  }

  /// Pide a la Edge Function "crear-cuenta-ordinaria-vinculada" el id de la cuenta personal
  /// USUARIO_ORDINARIO del CLIENTE que llama, creándola la primera vez que hace falta (063).
  Future<String> obtenerOCrearCuentaOrdinariaVinculada() async {
    final Map data;
    try {
      final respuesta = await _client.functions.invoke(
        'crear-cuenta-ordinaria-vinculada',
      );
      if (respuesta.data is! Map) {
        throw AppException('Respuesta inesperada del servidor');
      }
      data = respuesta.data as Map;
    } on FunctionException catch (e) {
      final details = e.details;
      final mensaje = details is Map && details['error'] != null
          ? details['error'].toString()
          : (e.reasonPhrase ?? 'Error ${e.status}');
      throw AppException(mensaje);
    }
    if (data['idSistemaUsuarioOrdinarioVinculado'] is! String) {
      throw AppException(
        data['error']?.toString() ?? 'Respuesta inesperada del servidor',
      );
    }
    return data['idSistemaUsuarioOrdinarioVinculado'] as String;
  }
}

final suplantacionRepositoryProvider = Provider<SuplantacionRepository>((ref) {
  return SuplantacionRepository(Supabase.instance.client);
});
