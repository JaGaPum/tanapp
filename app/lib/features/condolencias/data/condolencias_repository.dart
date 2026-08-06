import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'condolencia.dart';

class CondolenciasRepository {
  final SupabaseClient _client;
  CondolenciasRepository(this._client);

  static const _select = '*, TSistemaUsuarios(Nombre, Apellido1)';

  Future<String> _resolverIdSistemaUsuario() async {
    return _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);
  }

  Future<List<Condolencia>> listCondolencias(
    String idClientePublicacion, {
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('TClientePublicacionesCondolencias')
        .select(_select)
        .eq('IdClientePublicacion', idClientePublicacion)
        .order('FechaAlta', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map((e) => Condolencia.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Todas de golpe (sin paginar), para volcarlas al PDF: un PDF paginado a medias no tendría
  /// sentido, el cliente quiere el libro completo.
  Future<List<Condolencia>> listTodasCondolencias(
    String idClientePublicacion,
  ) async {
    final data = await _client
        .from('TClientePublicacionesCondolencias')
        .select(_select)
        .eq('IdClientePublicacion', idClientePublicacion)
        .order('FechaAlta', ascending: false);
    return (data as List)
        .map((e) => Condolencia.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Consulta aparte de [listCondolencias] (no depende de qué página esté cargada): sirve para
  /// saber con seguridad si el usuario actual ya dejó una condolencia en esta publicación, y
  /// poder editarla en vez de intentar crear una segunda (choca con el índice único).
  Future<Condolencia?> fetchMiCondolencia(String idClientePublicacion) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final data = await _client
        .from('TClientePublicacionesCondolencias')
        .select(_select)
        .eq('IdClientePublicacion', idClientePublicacion)
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();
    return data == null ? null : Condolencia.fromMap(data);
  }

  Future<void> crearCondolencia({
    required String idClientePublicacion,
    required String texto,
  }) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    await _client.from('TClientePublicacionesCondolencias').insert({
      'IdClientePublicacion': idClientePublicacion,
      'IdSistemaUsuario': idSistemaUsuario,
      'Texto': texto.trim(),
    });
  }

  Future<void> actualizarCondolencia({
    required String idClientePublicacionCondolencia,
    required String texto,
  }) async {
    await _client
        .from('TClientePublicacionesCondolencias')
        .update({'Texto': texto.trim()})
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }

  Future<void> eliminarCondolencia(
    String idClientePublicacionCondolencia,
  ) async {
    await _client
        .from('TClientePublicacionesCondolencias')
        .delete()
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }
}

final condolenciasRepositoryProvider = Provider<CondolenciasRepository>((ref) {
  return CondolenciasRepository(Supabase.instance.client);
});
