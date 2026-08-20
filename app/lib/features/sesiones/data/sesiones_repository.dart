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

  Future<Sesion?> fetchPorId(String idSistemaSesion) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select()
        .eq('IdSistemaSesion', idSistemaSesion)
        .maybeSingle();
    if (data == null) return null;
    return Sesion.fromMap(data);
  }

  Future<Sesion> crearSesion({
    required String idSistemaUsuario,
    required bool recordar,
    required String idDispositivo,
    String? dispositivo,
  }) async {
    final data = await _client
        .from('TSistemaSesiones')
        .insert({
          'IdSistemaUsuario': idSistemaUsuario,
          'Recordar': recordar,
          'IdDispositivo': idDispositivo,
          'Dispositivo': dispositivo,
        })
        .select()
        .single();
    return Sesion.fromMap(data);
  }

  /// Cierra cualquier otra sesión "ABIERTA" de este mismo dispositivo (sea del mismo usuario o
  /// de otro): así solo puede quedar una sesión abierta por dispositivo (ver 057). Vía RPC
  /// (SECURITY DEFINER) porque puede hacer falta cerrar la sesión de OTRO usuario, cosa que la
  /// policy de UPDATE normal no permite.
  Future<void> cerrarOtrasSesionesDelDispositivo({
    required String idDispositivo,
    required String excluirIdSistemaSesion,
  }) async {
    await _client.rpc(
      'FSistemaCerrarSesionesDispositivo',
      params: {
        'id_dispositivo': idDispositivo,
        'id_sistema_sesion_excluir': excluirIdSistemaSesion,
      },
    );
  }

  Future<void> tocarSesion(String idSistemaSesion) async {
    await _client
        .from('TSistemaSesiones')
        .update({'FechaUltimoAcceso': DateTime.now().toUtc().toIso8601String()})
        .eq('IdSistemaSesion', idSistemaSesion);
  }

  /// Al reutilizar una sesión ya abierta en un login explícito (ver
  /// "SesionPolicyService.registrarLoginExplicito"), por si el "Recordarme" elegido esta vez es
  /// distinto del que tenía la sesión que se reutiliza.
  Future<void> actualizarRecordar(String idSistemaSesion, bool recordar) async {
    await _client
        .from('TSistemaSesiones')
        .update({'Recordar': recordar})
        .eq('IdSistemaSesion', idSistemaSesion);
  }

  /// Deja constancia de qué dispositivo es dueño de esta sesión (ver 057): se llama tanto al
  /// crear una sesión como al reutilizar una ya existente, para que las filas de antes de esta
  /// migración (sin "IdDispositivo") también queden vinculadas en cuanto vuelvan a tocarse.
  Future<void> vincularDispositivo(
    String idSistemaSesion,
    String idDispositivo,
  ) async {
    await _client
        .from('TSistemaSesiones')
        .update({'IdDispositivo': idDispositivo})
        .eq('IdSistemaSesion', idSistemaSesion);
  }

  Future<void> cerrarSesion(String idSistemaSesion) async {
    await _client
        .from('TSistemaSesiones')
        .update({
          'Estado': 'CERRADA',
          'FechaFin': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('IdSistemaSesion', idSistemaSesion);
  }

  Future<void> cerrarSesionesAbiertas(String idSistemaUsuario) async {
    await _client
        .from('TSistemaSesiones')
        .update({
          'Estado': 'CERRADA',
          'FechaFin': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('Estado', 'ABIERTA');
  }

  Future<List<Sesion>> listSesionesUsuario(String idSistemaUsuario) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .order('FechaInicio', ascending: false);
    return (data as List)
        .map((e) => Sesion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Cuántas sesiones (de este mismo usuario, sin contar [excluirIdSistemaSesion]) están ahora
  /// mismo trabajando "como" [idClienteSede] — para el límite de 2 sesiones por sede.
  Future<int> contarOtrasSesionesAbiertasSede({
    required String idSistemaUsuario,
    required String idClienteSede,
    required String excluirIdSistemaSesion,
  }) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select('IdSistemaSesion')
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('IdClienteSede', idClienteSede)
        .eq('Estado', 'ABIERTA')
        .neq('IdSistemaSesion', excluirIdSistemaSesion);
    return (data as List).length;
  }

  /// Cierra la sesión más antigua entre las que ya están trabajando como [idClienteSede], para
  /// dejar hueco antes de asignarle esa misma sede a una sesión nueva.
  Future<void> cerrarSesionMasAntiguaDeSede({
    required String idSistemaUsuario,
    required String idClienteSede,
    required String excluirIdSistemaSesion,
  }) async {
    final data = await _client
        .from('TSistemaSesiones')
        .select('IdSistemaSesion')
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('IdClienteSede', idClienteSede)
        .eq('Estado', 'ABIERTA')
        .neq('IdSistemaSesion', excluirIdSistemaSesion)
        .order('FechaInicio', ascending: true)
        .limit(1)
        .maybeSingle();
    if (data != null) {
      await cerrarSesion(data['IdSistemaSesion'] as String);
    }
  }

  /// Asigna una sede a la sesión y deja constancia en el historial (TSistemaSesionesSedesLog):
  /// no sustituye filas anteriores, cada asignación/cambio queda como una fila nueva.
  Future<void> asignarSede({
    required String idSistemaSesion,
    required String idClienteSede,
  }) async {
    await _client
        .from('TSistemaSesiones')
        .update({'IdClienteSede': idClienteSede})
        .eq('IdSistemaSesion', idSistemaSesion);
    await _client.from('TSistemaSesionesSedesLog').insert({
      'IdSistemaSesion': idSistemaSesion,
      'IdClienteSede': idClienteSede,
    });
  }

  /// Pestaña "En vivo" del admin: todas las sesiones abiertas de todos los usuarios.
  Future<List<SesionAbierta>> listSesionesAbiertas() async {
    final data = await _client.rpc('FSistemaSesionesAbiertas');
    return (data as List)
        .map((e) => SesionAbierta.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

final sesionesRepositoryProvider = Provider<SesionesRepository>((ref) {
  return SesionesRepository(Supabase.instance.client);
});
