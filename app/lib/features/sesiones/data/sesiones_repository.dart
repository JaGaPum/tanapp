import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sesion.dart';

class SesionesRepository {
  final SupabaseClient _client;
  SesionesRepository(this._client);

  Future<Sesion?> fetchUltimaSesionAbierta(String idSistemaUsuario) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('Estado', 'ABIERTA')
        .order('FechaUltimoAcceso', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return Sesion.fromMap(data);
  }

  Future<Sesion> crearSesion({required String idSistemaUsuario, required bool recordar}) async {
    final data = await _client
        .from('TSistemaSesiones')
        .insert({'IdSistemaUsuario': idSistemaUsuario, 'Recordar': recordar})
        .select()
        .single();
    return Sesion.fromMap(data);
  }

  Future<void> tocarSesion(String idSistemaSesion) async {
    await _client
        .from('TSistemaSesiones')
        .update({'FechaUltimoAcceso': DateTime.now().toUtc().toIso8601String()})
        .eq('IdSistemaSesion', idSistemaSesion);
  }

  Future<void> cerrarSesion(String idSistemaSesion) async {
    await _client.from('TSistemaSesiones').update({
      'Estado': 'CERRADA',
      'FechaFin': DateTime.now().toUtc().toIso8601String(),
    }).eq('IdSistemaSesion', idSistemaSesion);
  }

  Future<void> cerrarSesionesAbiertas(String idSistemaUsuario) async {
    await _client.from('TSistemaSesiones').update({
      'Estado': 'CERRADA',
      'FechaFin': DateTime.now().toUtc().toIso8601String(),
    }).eq('IdSistemaUsuario', idSistemaUsuario).eq('Estado', 'ABIERTA');
  }

  Future<List<Sesion>> listSesionesUsuario(String idSistemaUsuario) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .order('FechaInicio', ascending: false);
    return (data as List).map((e) => Sesion.fromMap(e as Map<String, dynamic>)).toList();
  }
}

final sesionesRepositoryProvider = Provider<SesionesRepository>((ref) {
  return SesionesRepository(Supabase.instance.client);
});
