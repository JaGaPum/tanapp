import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DispositivosPushRepository {
  final SupabaseClient _client;
  DispositivosPushRepository(this._client);

  /// Da de alta (o reasigna, si el mismo dispositivo cambió de cuenta) el token de FCM del
  /// usuario actual. Vía RPC (066) en vez de un upsert directo: un upsert normal no puede
  /// reasignar una fila que ya pertenece a OTRO usuario, porque ese usuario no la "ve" según la
  /// policy de SELECT (propia), y sin verla Postgres no puede resolver el conflicto. La función
  /// resuelve el usuario actual ella misma a partir de la sesión, no hace falta pasarlo.
  Future<void> registrarToken(String token) async {
    await _client.rpc('FSistemaRegistrarTokenPush', params: {'p_token': token});
  }
}

final dispositivosPushRepositoryProvider = Provider<DispositivosPushRepository>(
  (ref) {
    return DispositivosPushRepository(Supabase.instance.client);
  },
);
