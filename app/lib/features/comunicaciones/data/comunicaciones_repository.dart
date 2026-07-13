import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'comunicacion.dart';

class ComunicacionesRepository {
  final SupabaseClient _client;
  ComunicacionesRepository(this._client);

  static const _select = '*, TConfiguracionComunicacionesIdiomas(*, TSistemaIdiomas(IdSistemaIdioma, Codigo, Nombre))';

  Future<List<Comunicacion>> listComunicaciones() async {
    final data = await _client.from('TConfiguracionComunicaciones').select(_select).order('NombreComunicacion');
    return (data as List).map((e) => Comunicacion.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Comunicacion> fetchById(String id) async {
    final data = await _client
        .from('TConfiguracionComunicaciones')
        .select(_select)
        .eq('IdConfiguracionComunicacion', id)
        .single();
    return Comunicacion.fromMap(data);
  }

  /// Busca una comunicación por su código (p.ej. 'SOLICITUD_APROBADA') junto con sus
  /// traducciones. La usará el futuro envío real de emails/notificaciones.
  Future<Comunicacion?> buscarPorCodigo(String codComunicacion) async {
    final data = await _client
        .from('TConfiguracionComunicaciones')
        .select(_select)
        .eq('CodComunicacion', codComunicacion)
        .maybeSingle();
    if (data == null) return null;
    return Comunicacion.fromMap(data);
  }

  Future<String> crearComunicacion({
    required String tipoComunicacion,
    required String codComunicacion,
    required String nombreComunicacion,
    String? remitente,
    required bool activo,
  }) async {
    final data = await _client.from('TConfiguracionComunicaciones').insert({
      'TipoComunicacion': tipoComunicacion,
      'CodComunicacion': codComunicacion.trim(),
      'NombreComunicacion': nombreComunicacion.trim(),
      'Remitente': (remitente == null || remitente.trim().isEmpty) ? null : remitente.trim(),
      'Activo': activo,
    }).select().single();
    return data['IdConfiguracionComunicacion'] as String;
  }

  Future<void> actualizarComunicacion({
    required String idConfiguracionComunicacion,
    required String tipoComunicacion,
    required String codComunicacion,
    required String nombreComunicacion,
    String? remitente,
    required bool activo,
  }) async {
    await _client.from('TConfiguracionComunicaciones').update({
      'TipoComunicacion': tipoComunicacion,
      'CodComunicacion': codComunicacion.trim(),
      'NombreComunicacion': nombreComunicacion.trim(),
      'Remitente': (remitente == null || remitente.trim().isEmpty) ? null : remitente.trim(),
      'Activo': activo,
    }).eq('IdConfiguracionComunicacion', idConfiguracionComunicacion);
  }

  Future<void> eliminarComunicacion(String idConfiguracionComunicacion) async {
    await _client
        .from('TConfiguracionComunicaciones')
        .delete()
        .eq('IdConfiguracionComunicacion', idConfiguracionComunicacion);
  }

  Future<void> guardarTraduccion({
    required String idConfiguracionComunicacion,
    required String idSistemaIdioma,
    String? asunto,
    required String cuerpo,
  }) async {
    await _client.from('TConfiguracionComunicacionesIdiomas').upsert(
      {
        'IdConfiguracionComunicacion': idConfiguracionComunicacion,
        'IdSistemaIdioma': idSistemaIdioma,
        'Asunto': (asunto == null || asunto.trim().isEmpty) ? null : asunto.trim(),
        'Cuerpo': cuerpo.trim(),
      },
      onConflict: 'IdConfiguracionComunicacion,IdSistemaIdioma',
    );
  }
}

final comunicacionesRepositoryProvider = Provider<ComunicacionesRepository>((ref) {
  return ComunicacionesRepository(Supabase.instance.client);
});
