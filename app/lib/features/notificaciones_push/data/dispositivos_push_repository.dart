import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DispositivosPushRepository {
  final SupabaseClient _client;
  DispositivosPushRepository(this._client);

  /// Da de alta (o reasigna, si el mismo dispositivo cambió de cuenta) el token de FCM del
  /// usuario actual. `IdSistemaUsuario` se resuelve en el propio backend a partir del token
  /// de sesión, no hace falta pasarlo.
  Future<void> registrarToken(String token) async {
    final idSistemaUsuario = await _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);

    await _client.from('TSistemaDispositivosPush').upsert(
      {'IdSistemaUsuario': idSistemaUsuario, 'Token': token},
      onConflict: 'Token',
    );
  }
}

final dispositivosPushRepositoryProvider = Provider<DispositivosPushRepository>((ref) {
  return DispositivosPushRepository(Supabase.instance.client);
});
