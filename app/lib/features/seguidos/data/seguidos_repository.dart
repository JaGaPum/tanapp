import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente_seguible.dart';
import 'seguimiento_sede_info.dart';

class SeguidosRepository {
  final SupabaseClient _client;
  SeguidosRepository(this._client);

  /// Busca sedes (no clientes) que encajen con el tipo/provincia/concello elegidos. La RLS
  /// "select_clientes_activos_TClienteSedes" ya solo deja ver sedes de clientes activos; el
  /// filtro por tipo de cliente y por si sigue activo se aplica aquí en Dart en vez de con un
  /// filtro de PostgREST sobre el recurso embebido (más simple y no depende de esa sintaxis).
  Future<List<ClienteSeguible>> listClientesPorFiltro({
    required String idConfiguracionClienteTipo,
    required String provincia,
    required String concello,
  }) async {
    final data = await _client
        .from('TClienteSedes')
        .select('*, TSistemaUsuarios(*)')
        .eq('Provincia', provincia)
        .eq('Concello', concello)
        .order('Nombre');
    return (data as List)
        .map((e) => e as Map<String, dynamic>)
        .where((sede) {
          final cliente = sede['TSistemaUsuarios'] as Map<String, dynamic>?;
          return cliente != null &&
              cliente['Activo'] == true &&
              cliente['IdConfiguracionClienteTipo'] == idConfiguracionClienteTipo;
        })
        .map(ClienteSeguible.fromSedeMap)
        .toList();
  }

  Future<Set<String>> listMisSeguidosIds() async {
    final data = await _client.from('TClienteSeguimientos').select('IdClienteSede');
    return (data as List).map((e) => (e as Map<String, dynamic>)['IdClienteSede'] as String).toSet();
  }

  /// Sedes que sigue el usuario actual, con el cliente dueño embebido para poder mostrar su
  /// nombre/teléfono/avatar junto a los datos propios de la sede.
  Future<List<ClienteSeguible>> listMisSeguidosClientes() async {
    final data = await _client
        .from('TClienteSeguimientos')
        .select('*, TClienteSedes(*, TSistemaUsuarios(*))')
        .order('FechaAlta', ascending: false);
    return (data as List)
        .map((e) => ClienteSeguible.fromSedeMap((e as Map<String, dynamic>)['TClienteSedes'] as Map<String, dynamic>))
        .toList();
  }

  /// Un seguimiento por fila (a qué sede propia sigue + concello del propio seguidor, no el de
  /// la sede), para poder desglosar el número de seguidores de cada sede por concello.
  Future<List<SeguimientoSedeInfo>> listSeguidoresPorSedes(List<String> idsClienteSede) async {
    if (idsClienteSede.isEmpty) return [];
    final data = await _client
        .from('TClienteSeguimientos')
        .select('IdSistemaUsuario, IdClienteSede, TSistemaUsuarios(Concello)')
        .inFilter('IdClienteSede', idsClienteSede);
    return (data as List).map((e) {
      final row = e as Map<String, dynamic>;
      final seguidor = row['TSistemaUsuarios'] as Map<String, dynamic>;
      return SeguimientoSedeInfo(
        idSistemaUsuario: row['IdSistemaUsuario'] as String,
        idClienteSede: row['IdClienteSede'] as String,
        concelloSeguidor: seguidor['Concello'] as String?,
      );
    }).toList();
  }

  Future<void> seguir({required String idSistemaUsuario, required String idClienteSede}) async {
    await _client.from('TClienteSeguimientos').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'IdClienteSede': idClienteSede,
    });
  }

  Future<void> dejarDeSeguir({required String idSistemaUsuario, required String idClienteSede}) async {
    await _client
        .from('TClienteSeguimientos')
        .delete()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('IdClienteSede', idClienteSede);
  }
}

final seguidosRepositoryProvider = Provider<SeguidosRepository>((ref) {
  return SeguidosRepository(Supabase.instance.client);
});
