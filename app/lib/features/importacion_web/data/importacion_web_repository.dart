import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente_importacion_web.dart';

class ImportacionWebRepository {
  final SupabaseClient _client;
  ImportacionWebRepository(this._client);

  Future<String> _resolverIdSistemaUsuario() async {
    return _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);
  }

  Future<ClienteImportacionWeb?> fetchPropia() async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final data = await _client
        .from('TClienteImportacionWeb')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();
    return data == null ? null : ClienteImportacionWeb.fromMap(data);
  }

  /// Da de alta la configuración (primera vez) o actualiza la URL de una ya existente,
  /// reactivándola si estaba desactivada. La fecha de autorización original no se toca al
  /// actualizar, solo se fija la primera vez (por defecto en la propia base de datos).
  Future<void> guardar(String url) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final existente = await _client
        .from('TClienteImportacionWeb')
        .select('IdClienteImportacionWeb')
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();

    if (existente == null) {
      await _client.from('TClienteImportacionWeb').insert({
        'IdSistemaUsuario': idSistemaUsuario,
        'Url': url,
        'Activo': true,
      });
    } else {
      await _client
          .from('TClienteImportacionWeb')
          .update({'Url': url, 'Activo': true}).eq('IdSistemaUsuario', idSistemaUsuario);
    }
  }

  Future<void> desactivar() async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    await _client.from('TClienteImportacionWeb').update({'Activo': false}).eq(
      'IdSistemaUsuario',
      idSistemaUsuario,
    );
  }
}

final importacionWebRepositoryProvider = Provider<ImportacionWebRepository>((ref) {
  return ImportacionWebRepository(Supabase.instance.client);
});
