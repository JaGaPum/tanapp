import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente_tipo.dart';

class ClienteTiposRepository {
  final SupabaseClient _client;
  ClienteTiposRepository(this._client);

  static const _select = '*, TConfiguracionClienteTiposIdiomas(*, TSistemaIdiomas(IdSistemaIdioma, Codigo, Nombre))';

  Future<List<ClienteTipo>> listClienteTipos() async {
    final data = await _client.from('TConfiguracionClienteTipos').select(_select).order('Nombre');
    return (data as List).map((e) => ClienteTipo.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<ClienteTipo> fetchById(String id) async {
    final data = await _client
        .from('TConfiguracionClienteTipos')
        .select(_select)
        .eq('IdConfiguracionClienteTipo', id)
        .single();
    return ClienteTipo.fromMap(data);
  }

  Future<String> crearClienteTipo({required String nombre, required bool activo}) async {
    final data = await _client.from('TConfiguracionClienteTipos').insert({
      'Nombre': nombre.trim(),
      'Activo': activo,
    }).select().single();
    return data['IdConfiguracionClienteTipo'] as String;
  }

  Future<void> actualizarClienteTipo({
    required String idConfiguracionClienteTipo,
    required String nombre,
    required bool activo,
  }) async {
    await _client.from('TConfiguracionClienteTipos').update({
      'Nombre': nombre.trim(),
      'Activo': activo,
    }).eq('IdConfiguracionClienteTipo', idConfiguracionClienteTipo);
  }

  Future<void> eliminarClienteTipo(String idConfiguracionClienteTipo) async {
    await _client
        .from('TConfiguracionClienteTipos')
        .delete()
        .eq('IdConfiguracionClienteTipo', idConfiguracionClienteTipo);
  }

  Future<void> guardarTraduccion({
    required String idConfiguracionClienteTipo,
    required String idSistemaIdioma,
    required String nombre,
  }) async {
    await _client.from('TConfiguracionClienteTiposIdiomas').upsert(
      {
        'IdConfiguracionClienteTipo': idConfiguracionClienteTipo,
        'IdSistemaIdioma': idSistemaIdioma,
        'Nombre': nombre.trim(),
      },
      onConflict: 'IdConfiguracionClienteTipo,IdSistemaIdioma',
    );
  }
}

final clienteTiposRepositoryProvider = Provider<ClienteTiposRepository>((ref) {
  return ClienteTiposRepository(Supabase.instance.client);
});
