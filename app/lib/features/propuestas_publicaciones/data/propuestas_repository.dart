import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'publicacion_propuesta.dart';

class PropuestasRepository {
  final SupabaseClient _client;
  PropuestasRepository(this._client);

  Future<String> _resolverIdSistemaUsuario() async {
    return _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);
  }

  Future<List<PublicacionPropuesta>> listPendientes() async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final data = await _client
        .from('TClientePublicacionesPropuestas')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('Estado', 'PENDIENTE')
        .order('FechaAlta', ascending: false);
    return data.map((m) => PublicacionPropuesta.fromMap(m)).toList();
  }

  Future<void> descartar(String idClientePublicacionPropuesta) async {
    await _client
        .from('TClientePublicacionesPropuestas')
        .update({'Estado': 'DESCARTADA'}).eq('IdClientePublicacionPropuesta', idClientePublicacionPropuesta);
  }

  Future<void> marcarPublicada(String idClientePublicacionPropuesta) async {
    await _client
        .from('TClientePublicacionesPropuestas')
        .update({'Estado': 'PUBLICADA'}).eq('IdClientePublicacionPropuesta', idClientePublicacionPropuesta);
  }
}

final propuestasRepositoryProvider = Provider<PropuestasRepository>((ref) {
  return PropuestasRepository(Supabase.instance.client);
});
