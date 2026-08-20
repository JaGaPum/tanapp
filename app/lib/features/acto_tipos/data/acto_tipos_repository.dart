import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'acto_tipo.dart';

class ActoTiposRepository {
  final SupabaseClient _client;
  ActoTiposRepository(this._client);

  Future<List<ActoTipo>> listActoTipos() async {
    final data = await _client
        .from('TConfiguracionActoTipos')
        .select()
        .order('Nombre');
    return (data as List)
        .map((e) => ActoTipo.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<ActoTipo> fetchById(String id) async {
    final data = await _client
        .from('TConfiguracionActoTipos')
        .select()
        .eq('IdConfiguracionActoTipo', id)
        .single();
    return ActoTipo.fromMap(data);
  }

  Future<String> crearActoTipo({
    required String nombre,
    required bool activo,
  }) async {
    final data = await _client
        .from('TConfiguracionActoTipos')
        .insert({'Nombre': nombre.trim(), 'Activo': activo})
        .select()
        .single();
    return data['IdConfiguracionActoTipo'] as String;
  }

  Future<void> actualizarActoTipo({
    required String idConfiguracionActoTipo,
    required String nombre,
    required bool activo,
  }) async {
    await _client
        .from('TConfiguracionActoTipos')
        .update({'Nombre': nombre.trim(), 'Activo': activo})
        .eq('IdConfiguracionActoTipo', idConfiguracionActoTipo);
  }

  Future<void> eliminarActoTipo(String idConfiguracionActoTipo) async {
    await _client
        .from('TConfiguracionActoTipos')
        .delete()
        .eq('IdConfiguracionActoTipo', idConfiguracionActoTipo);
  }
}

final actoTiposRepositoryProvider = Provider<ActoTiposRepository>((ref) {
  return ActoTiposRepository(Supabase.instance.client);
});
