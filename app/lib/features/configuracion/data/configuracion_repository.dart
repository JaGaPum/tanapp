import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'concello.dart';
import 'provincia.dart';

final _articuloInicial = RegExp(r'^(A|O|As|Os)\s+', caseSensitive: false);

/// Clave de orden que ignora el artículo gallego inicial (A/O/As/Os), para que
/// "A Coruña" se ordene junto a las C y no se amontone al principio bajo la "A".
String _claveOrdenGalego(String nombre) => nombre.replaceFirst(_articuloInicial, '').toLowerCase();

class ConfiguracionRepository {
  final SupabaseClient _client;
  ConfiguracionRepository(this._client);

  Future<List<Provincia>> listProvincias() async {
    final data = await _client.from('TConfiguracionProvincias').select();
    final provincias = (data as List).map((e) => Provincia.fromMap(e as Map<String, dynamic>)).toList();
    provincias.sort((a, b) => _claveOrdenGalego(a.nombre).compareTo(_claveOrdenGalego(b.nombre)));
    return provincias;
  }

  Future<List<Concello>> listConcellosPorProvincia(String idConfiguracionProvincia) async {
    final data = await _client
        .from('TConfiguracionConcellos')
        .select()
        .eq('IdConfiguracionProvincia', idConfiguracionProvincia);
    final concellos = (data as List).map((e) => Concello.fromMap(e as Map<String, dynamic>)).toList();
    concellos.sort((a, b) => _claveOrdenGalego(a.nombre).compareTo(_claveOrdenGalego(b.nombre)));
    return concellos;
  }

  Future<void> crearProvincia({required String nombre, required String prefijoPostal}) async {
    await _client.from('TConfiguracionProvincias').insert({
      'Nombre': nombre.trim(),
      'PrefijoPostal': prefijoPostal.trim(),
    });
  }

  Future<void> actualizarProvincia({
    required String idConfiguracionProvincia,
    required String nombre,
    required String prefijoPostal,
  }) async {
    await _client.from('TConfiguracionProvincias').update({
      'Nombre': nombre.trim(),
      'PrefijoPostal': prefijoPostal.trim(),
    }).eq('IdConfiguracionProvincia', idConfiguracionProvincia);
  }

  Future<void> eliminarProvincia(String idConfiguracionProvincia) async {
    await _client.from('TConfiguracionProvincias').delete().eq(
          'IdConfiguracionProvincia',
          idConfiguracionProvincia,
        );
  }

  Future<void> crearConcello({required String idConfiguracionProvincia, required String nombre}) async {
    await _client.from('TConfiguracionConcellos').insert({
      'IdConfiguracionProvincia': idConfiguracionProvincia,
      'Nombre': nombre.trim(),
    });
  }

  Future<void> actualizarConcello({required String idConfiguracionConcello, required String nombre}) async {
    await _client.from('TConfiguracionConcellos').update({'Nombre': nombre.trim()}).eq(
          'IdConfiguracionConcello',
          idConfiguracionConcello,
        );
  }

  Future<void> eliminarConcello(String idConfiguracionConcello) async {
    await _client.from('TConfiguracionConcellos').delete().eq('IdConfiguracionConcello', idConfiguracionConcello);
  }
}

final configuracionRepositoryProvider = Provider<ConfiguracionRepository>((ref) {
  return ConfiguracionRepository(Supabase.instance.client);
});
