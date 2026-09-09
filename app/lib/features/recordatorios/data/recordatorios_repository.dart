import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'recordatorio_publicacion.dart';

class RecordatoriosRepository {
  final SupabaseClient _client;
  RecordatoriosRepository(this._client);

  // Mismo shape que "_selectConSede" en publicaciones_repository.dart: lo necesita
  // PublicacionConSede.fromMap para construirse a partir de la publicación embebida.
  static const _selectConPublicacion =
      '*, TClientePublicaciones('
      '*, TClienteSedes(Nombre, Concello, Provincia, TSistemaUsuarios(Nombre)), '
      'numCondolencias:FSistemaContarCondolencias'
      ')';

  /// Recordatorios pendientes (no enviados) de esta publicación para el usuario actual (la RLS
  /// ya solo deja ver los propios) — hasta 2, para el diálogo de "configurar recordatorio" de la
  /// tarjeta.
  Future<List<RecordatorioPublicacion>> listPendientesPorPublicacion(
    String idClientePublicacion,
  ) async {
    final data = await _client
        .from('TClientePublicacionesRecordatorios')
        .select()
        .eq('IdClientePublicacion', idClientePublicacion)
        .eq('Enviado', false)
        .order('FechaHoraRecordatorio', ascending: true);
    return (data as List)
        .map((e) => RecordatorioPublicacion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Todos los recordatorios pendientes del usuario actual, de cualquier publicación, para "Mis
  /// recordatorios" — ordenados por cuál toca antes.
  Future<List<RecordatorioPublicacion>> listMisPendientes() async {
    final data = await _client
        .from('TClientePublicacionesRecordatorios')
        .select(_selectConPublicacion)
        .eq('Enviado', false)
        .order('FechaHoraRecordatorio', ascending: true);
    return (data as List)
        .map(
          (e) => RecordatorioPublicacion.fromMapConPublicacion(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Recordatorios ya enviados del usuario actual, para verlos como notificación recibida en la
  /// pestaña "Avisos".
  Future<List<RecordatorioPublicacion>> listMisEnviados({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('TClientePublicacionesRecordatorios')
        .select(_selectConPublicacion)
        .eq('Enviado', true)
        .order('FechaEnviado', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map(
          (e) => RecordatorioPublicacion.fromMapConPublicacion(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> crear({
    required String idSistemaUsuario,
    required String idClientePublicacion,
    required DateTime fechaHoraRecordatorio,
  }) async {
    await _client.from('TClientePublicacionesRecordatorios').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'IdClientePublicacion': idClientePublicacion,
      'FechaHoraRecordatorio': fechaHoraRecordatorio.toUtc().toIso8601String(),
    });
  }

  Future<void> actualizar({
    required String idClientePublicacionRecordatorio,
    required DateTime fechaHoraRecordatorio,
  }) async {
    await _client
        .from('TClientePublicacionesRecordatorios')
        .update({
          'FechaHoraRecordatorio': fechaHoraRecordatorio
              .toUtc()
              .toIso8601String(),
        })
        .eq(
          'IdClientePublicacionRecordatorio',
          idClientePublicacionRecordatorio,
        );
  }

  Future<void> eliminar(String idClientePublicacionRecordatorio) async {
    await _client
        .from('TClientePublicacionesRecordatorios')
        .delete()
        .eq(
          'IdClientePublicacionRecordatorio',
          idClientePublicacionRecordatorio,
        );
  }

  Future<void> eliminarVarios(
    List<String> idsClientePublicacionRecordatorio,
  ) async {
    if (idsClientePublicacionRecordatorio.isEmpty) return;
    await _client
        .from('TClientePublicacionesRecordatorios')
        .delete()
        .inFilter(
          'IdClientePublicacionRecordatorio',
          idsClientePublicacionRecordatorio,
        );
  }

  /// Vacía todos los recordatorios ya enviados del usuario actual (la RLS ya limita esto a los
  /// propios) — los pendientes no se tocan, solo tiene sentido "vaciar" lo que ya se ha visto.
  Future<void> eliminarTodosEnviados() async {
    await _client
        .from('TClientePublicacionesRecordatorios')
        .delete()
        .eq('Enviado', true);
  }

  Future<void> marcarLeido(String idClientePublicacionRecordatorio) async {
    await _client
        .from('TClientePublicacionesRecordatorios')
        .update({'Leido': true})
        .eq(
          'IdClientePublicacionRecordatorio',
          idClientePublicacionRecordatorio,
        );
  }

  /// Recordatorios ya enviados y todavía sin abrir del usuario actual, para el badge de la
  /// pestaña "Avisos" (junto con los avisos sin leer).
  Future<int> contarNoLeidos() async {
    final res = await _client
        .from('TClientePublicacionesRecordatorios')
        .select('IdClientePublicacionRecordatorio')
        .eq('Enviado', true)
        .eq('Leido', false)
        .count(CountOption.exact);
    return res.count;
  }
}

final recordatoriosRepositoryProvider = Provider<RecordatoriosRepository>((
  ref,
) {
  return RecordatoriosRepository(Supabase.instance.client);
});
