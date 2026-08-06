import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'zona_seguida.dart';

class ZonasSeguidasRepository {
  final SupabaseClient _client;
  ZonasSeguidasRepository(this._client);

  Future<List<ZonaSeguida>> listMisZonas() async {
    final data = await _client
        .from('TSistemaUsuarioZonas')
        .select()
        .order('Concello');
    return (data as List)
        .map((e) => ZonaSeguida.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Set<String>> listMisZonasConcellos() async {
    final data = await _client.from('TSistemaUsuarioZonas').select('Concello');
    return (data as List)
        .map((e) => (e as Map<String, dynamic>)['Concello'] as String)
        .toSet();
  }

  Future<void> seguirZona({
    required String idSistemaUsuario,
    required String provincia,
    required String concello,
  }) async {
    await _client.from('TSistemaUsuarioZonas').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'Provincia': provincia,
      'Concello': concello,
    });
  }

  Future<void> dejarDeSeguirZona({
    required String idSistemaUsuario,
    required String concello,
  }) async {
    await _client
        .from('TSistemaUsuarioZonas')
        .delete()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('Concello', concello);
  }

  /// Cuántos usuarios siguen cada uno de [concellos] como zona (sin seguir a ningún cliente en
  /// concreto), para el desglose de seguidores del Panel de Datos. La RLS de 039 solo deja ver
  /// esto al cliente dueño de una sede en ese concello.
  Future<Map<String, int>> contarPorConcellos(List<String> concellos) async {
    if (concellos.isEmpty) return {};
    final data = await _client
        .from('TSistemaUsuarioZonas')
        .select('Concello')
        .inFilter('Concello', concellos);
    final conteos = <String, int>{};
    for (final fila in data as List) {
      final concello = (fila as Map<String, dynamic>)['Concello'] as String;
      conteos[concello] = (conteos[concello] ?? 0) + 1;
    }
    return conteos;
  }
}

final zonasSeguidasRepositoryProvider = Provider<ZonasSeguidasRepository>((
  ref,
) {
  return ZonasSeguidasRepository(Supabase.instance.client);
});
