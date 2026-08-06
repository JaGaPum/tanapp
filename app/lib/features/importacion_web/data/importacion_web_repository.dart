import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente_importacion_web.dart';

class ImportacionWebRepository {
  final SupabaseClient _client;
  ImportacionWebRepository(this._client);

  Future<String> _resolverIdSistemaUsuario() async {
    return _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);
  }

  Future<ClienteImportacionWeb?> fetchPropia() async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final data = await _client
        .from('TClienteImportacionWeb')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();
    return data == null ? null : ClienteImportacionWeb.fromMap(data);
  }

  /// Da de alta la configuración (primera vez) o actualiza la URL de una ya existente,
  /// reactivándola si estaba desactivada. La fecha de autorización original no se toca al
  /// actualizar, solo se fija la primera vez (por defecto en la propia base de datos).
  Future<void> guardar(String url) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final existente = await _client
        .from('TClienteImportacionWeb')
        .select('IdClienteImportacionWeb')
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();

    if (existente == null) {
      await _client.from('TClienteImportacionWeb').insert({
        'IdSistemaUsuario': idSistemaUsuario,
        'Url': url,
        'Activo': true,
      });
    } else {
      await _client
          .from('TClienteImportacionWeb')
          .update({'Url': url, 'Activo': true})
          .eq('IdSistemaUsuario', idSistemaUsuario);
    }
  }

  Future<void> desactivar() async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    await _client
        .from('TClienteImportacionWeb')
        .update({'Activo': false})
        .eq('IdSistemaUsuario', idSistemaUsuario);
  }

  /// Para el administrador: consulta/activa/desactiva la configuración de un cliente
  /// cualquiera (no el usuario logueado), permitido por las policies de ADMIN de la 029.
  Future<ClienteImportacionWeb?> fetchPorUsuario(
    String idSistemaUsuario,
  ) async {
    final data = await _client
        .from('TClienteImportacionWeb')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();
    return data == null ? null : ClienteImportacionWeb.fromMap(data);
  }

  Future<void> actualizarActivoAdmin(
    String idSistemaUsuario,
    bool activo,
  ) async {
    await _client
        .from('TClienteImportacionWeb')
        .update({'Activo': activo})
        .eq('IdSistemaUsuario', idSistemaUsuario);
  }

  /// Dispara el rastreo de la propia web ahora mismo (sin esperar al cron diario). Devuelve
  /// cuántas esquelas encontró y cuántas eran nuevas, o lanza si la función responde con error
  /// (p. ej. si la importación no está activa).
  Future<({int encontradas, int nuevas})> ejecutarAhora() async {
    final respuesta = await _client.functions.invoke('escanear-webs-clientes');
    final data = respuesta.data;
    if (data is! Map ||
        data['resultados'] is! List ||
        (data['resultados'] as List).isEmpty) {
      throw Exception(
        data is Map
            ? (data['error'] ?? 'Respuesta inesperada')
            : 'Respuesta inesperada',
      );
    }
    final resultado = (data['resultados'] as List).first as Map;
    if (resultado['error'] != null) {
      throw Exception(resultado['error']);
    }
    return (
      encontradas: resultado['encontradas'] as int? ?? 0,
      nuevas: resultado['nuevas'] as int? ?? 0,
    );
  }
}

final importacionWebRepositoryProvider = Provider<ImportacionWebRepository>((
  ref,
) {
  return ImportacionWebRepository(Supabase.instance.client);
});
