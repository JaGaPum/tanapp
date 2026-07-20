import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'publicacion_con_sede.dart';

class PublicacionesRepository {
  final SupabaseClient _client;
  PublicacionesRepository(this._client);

  static const _selectConSede =
      '*, TClienteSedes(Nombre, Concello, Provincia, TSistemaUsuarios(Nombre))';

  Future<void> crearPublicacion({
    required String idClienteSede,
    required String nombreFallecido,
    DateTime? fechaFallecimiento,
    int? edad,
    DateTime? fechaFuneral,
    String? horaFuneral,
    String? iglesia,
    String? lugar,
    String? capillaArdiente,
    String? sala,
    String? observaciones,
  }) async {
    await _client.from('TClientePublicaciones').insert({
      'IdClienteSede': idClienteSede,
      'NombreFallecido': nombreFallecido.trim(),
      'FechaFallecimiento': fechaFallecimiento?.toIso8601String(),
      'Edad': edad,
      'FechaFuneral': fechaFuneral?.toIso8601String(),
      'HoraFuneral': _oNull(horaFuneral),
      'Iglesia': _oNull(iglesia),
      'Lugar': _oNull(lugar),
      'CapillaArdiente': _oNull(capillaArdiente),
      'Sala': _oNull(sala),
      'Observaciones': _oNull(observaciones),
    });
  }

  static String? _oNull(String? valor) {
    final recortado = valor?.trim();
    return recortado == null || recortado.isEmpty ? null : recortado;
  }

  /// Todas las publicaciones visibles (la RLS ya solo deja ver las de clientes activos), para
  /// el Taboleiro.
  Future<List<PublicacionConSede>> listTodas() async {
    final data = await _client.from('TClientePublicaciones').select(_selectConSede).order('FechaAlta', ascending: false);
    return (data as List).map((e) => PublicacionConSede.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Publicaciones de una lista de sedes concretas: se usa tanto para "mis publicaciones"
  /// (todas las sedes de un cliente) como para las de una única sede seguida.
  Future<List<PublicacionConSede>> listPorSedes(List<String> idsClienteSede) async {
    if (idsClienteSede.isEmpty) return [];
    final data = await _client
        .from('TClientePublicaciones')
        .select(_selectConSede)
        .inFilter('IdClienteSede', idsClienteSede)
        .order('FechaAlta', ascending: false);
    return (data as List).map((e) => PublicacionConSede.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> actualizarPublicacion({
    required String idClientePublicacion,
    required String idClienteSede,
    required String nombreFallecido,
    DateTime? fechaFallecimiento,
    int? edad,
    DateTime? fechaFuneral,
    String? horaFuneral,
    String? iglesia,
    String? lugar,
    String? capillaArdiente,
    String? sala,
    String? observaciones,
  }) async {
    await _client.from('TClientePublicaciones').update({
      'IdClienteSede': idClienteSede,
      'NombreFallecido': nombreFallecido.trim(),
      'FechaFallecimiento': fechaFallecimiento?.toIso8601String(),
      'Edad': edad,
      'FechaFuneral': fechaFuneral?.toIso8601String(),
      'HoraFuneral': _oNull(horaFuneral),
      'Iglesia': _oNull(iglesia),
      'Lugar': _oNull(lugar),
      'CapillaArdiente': _oNull(capillaArdiente),
      'Sala': _oNull(sala),
      'Observaciones': _oNull(observaciones),
    }).eq('IdClientePublicacion', idClientePublicacion);
  }

  Future<void> eliminarPublicacion(String idClientePublicacion) async {
    await _client.from('TClientePublicaciones').delete().eq('IdClientePublicacion', idClientePublicacion);
  }

  Future<Set<String>> listMisArchivadasIds() async {
    final data = await _client.from('TClientePublicacionesArchivadas').select('IdClientePublicacion');
    return (data as List).map((e) => (e as Map<String, dynamic>)['IdClientePublicacion'] as String).toSet();
  }

  Future<List<PublicacionConSede>> listMisArchivadas() async {
    final data = await _client
        .from('TClientePublicacionesArchivadas')
        .select('TClientePublicaciones($_selectConSede)')
        .order('FechaAlta', ascending: false);
    return (data as List)
        .map((e) => PublicacionConSede.fromMap((e as Map<String, dynamic>)['TClientePublicaciones'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> archivar({required String idSistemaUsuario, required String idClientePublicacion}) async {
    await _client.from('TClientePublicacionesArchivadas').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'IdClientePublicacion': idClientePublicacion,
    });
  }

  Future<void> desarchivar({required String idSistemaUsuario, required String idClientePublicacion}) async {
    await _client
        .from('TClientePublicacionesArchivadas')
        .delete()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('IdClientePublicacion', idClientePublicacion);
  }
}

final publicacionesRepositoryProvider = Provider<PublicacionesRepository>((ref) {
  return PublicacionesRepository(Supabase.instance.client);
});
