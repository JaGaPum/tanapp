import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'aviso_estadistica.dart';
import 'aviso_programado.dart';
import 'aviso_recibido.dart';
import 'cliente_aviso.dart';

class AvisosRepository {
  final SupabaseClient _client;
  AvisosRepository(this._client);

  static const _selectConSede = '*, TClienteSedes(Nombre)';
  static const _selectRecibido =
      '*, TClienteAvisos(*, TClienteSedes(Nombre, TSistemaUsuarios(Nombre)))';

  Future<void> crearAviso({
    required String idClienteSede,
    required String titulo,
    required String texto,
  }) async {
    await _client.from('TClienteAvisos').insert({
      'IdClienteSede': idClienteSede,
      'Titulo': titulo.trim(),
      'Texto': texto.trim(),
    });
  }

  static const _selectProgramadoConSede = '*, TClienteSedes(Codigo, Nombre)';

  /// Guarda el aviso en la "cola" (055) en vez de enviarlo ya: un job de la base de datos lo
  /// mueve solo a "TClienteAvisos" en cuanto llegue [fechaProgramada], disparando el envío
  /// igual que uno inmediato (056).
  Future<void> crearAvisoProgramado({
    required String idClienteSede,
    required String titulo,
    required String texto,
    required DateTime fechaProgramada,
  }) async {
    await _client.from('TClienteAvisosProgramados').insert({
      'IdClienteSede': idClienteSede,
      'Titulo': titulo.trim(),
      'Texto': texto.trim(),
      'FechaProgramada': fechaProgramada.toUtc().toIso8601String(),
    });
  }

  Future<void> actualizarAvisoProgramado({
    required String idClienteAvisoProgramado,
    required String idClienteSede,
    required String titulo,
    required String texto,
    required DateTime fechaProgramada,
  }) async {
    await _client
        .from('TClienteAvisosProgramados')
        .update({
          'IdClienteSede': idClienteSede,
          'Titulo': titulo.trim(),
          'Texto': texto.trim(),
          'FechaProgramada': fechaProgramada.toUtc().toIso8601String(),
        })
        .eq('IdClienteAvisoProgramado', idClienteAvisoProgramado);
  }

  Future<void> eliminarAvisoProgramado(String idClienteAvisoProgramado) async {
    await _client
        .from('TClienteAvisosProgramados')
        .delete()
        .eq('IdClienteAvisoProgramado', idClienteAvisoProgramado);
  }

  Future<List<AvisoProgramado>> listAvisosProgramados(
    List<String> idsClienteSede,
  ) async {
    if (idsClienteSede.isEmpty) return [];
    final data = await _client
        .from('TClienteAvisosProgramados')
        .select(_selectProgramadoConSede)
        .inFilter('IdClienteSede', idsClienteSede)
        .order('FechaProgramada', ascending: true);
    return (data as List)
        .map((e) => AvisoProgramado.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Histórico de avisos enviados desde cualquiera de las sedes indicadas (las del cliente
  /// actual), para su pestaña "Avisos". No incluye los que el propio cliente haya eliminado de
  /// su histórico (siguen intactos en el buzón de quien los recibió).
  Future<List<ClienteAviso>> listMisAvisosEnviados(
    List<String> idsClienteSede, {
    int offset = 0,
    int limit = 20,
  }) async {
    if (idsClienteSede.isEmpty) return [];
    final data = await _client
        .from('TClienteAvisos')
        .select(_selectConSede)
        .inFilter('IdClienteSede', idsClienteSede)
        .eq('EliminadoCliente', false)
        .order('FechaAlta', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map((e) => ClienteAviso.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// No borra "TClienteAvisos" de verdad (arrastraría por cascada el buzón de todos los
  /// destinatarios, ver migración 033): solo lo oculta del histórico del propio remitente.
  Future<void> eliminarAvisoEnviado(String idClienteAviso) async {
    await _client
        .from('TClienteAvisos')
        .update({'EliminadoCliente': true})
        .eq('IdClienteAviso', idClienteAviso);
  }

  Future<void> eliminarAvisosEnviados(List<String> idsClienteAviso) async {
    if (idsClienteAviso.isEmpty) return;
    await _client
        .from('TClienteAvisos')
        .update({'EliminadoCliente': true})
        .inFilter('IdClienteAviso', idsClienteAviso);
  }

  Future<void> eliminarTodosAvisosEnviados(List<String> idsClienteSede) async {
    if (idsClienteSede.isEmpty) return;
    await _client
        .from('TClienteAvisos')
        .update({'EliminadoCliente': true})
        .inFilter('IdClienteSede', idsClienteSede);
  }

  /// Bandeja del usuario actual (la RLS ya solo deja ver los propios), para la pestaña "Avisos"
  /// de un seguidor.
  Future<List<AvisoRecibido>> listMisAvisosRecibidos({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('TClienteAvisosDestinatarios')
        .select(_selectRecibido)
        .order('FechaAlta', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map((e) => AvisoRecibido.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> contarAvisosNoLeidos() async {
    final res = await _client
        .from('TClienteAvisosDestinatarios')
        .select('IdClienteAvisoDestinatario')
        .eq('Leido', false)
        .count(CountOption.exact);
    return res.count;
  }

  Future<void> marcarLeido(String idClienteAvisoDestinatario) async {
    await _client
        .from('TClienteAvisosDestinatarios')
        .update({'Leido': true})
        .eq('IdClienteAvisoDestinatario', idClienteAvisoDestinatario);
  }

  Future<void> eliminarAviso(String idClienteAvisoDestinatario) async {
    await _client
        .from('TClienteAvisosDestinatarios')
        .delete()
        .eq('IdClienteAvisoDestinatario', idClienteAvisoDestinatario);
  }

  Future<void> eliminarAvisos(List<String> idsClienteAvisoDestinatario) async {
    if (idsClienteAvisoDestinatario.isEmpty) return;
    await _client
        .from('TClienteAvisosDestinatarios')
        .delete()
        .inFilter('IdClienteAvisoDestinatario', idsClienteAvisoDestinatario);
  }

  /// Vacía toda la bandeja del usuario actual. Supabase exige una cláusula WHERE en todo
  /// DELETE (protección "safeupdate"); la RLS ya limita esto a los avisos propios, así que
  /// basta un filtro siempre verdadero sobre la clave primaria.
  Future<void> eliminarTodosAvisos() async {
    await _client
        .from('TClienteAvisosDestinatarios')
        .delete()
        .not('IdClienteAvisoDestinatario', 'is', null);
  }

  /// Recibidos/leídos de los últimos [limit] avisos enviados desde las sedes indicadas, para la
  /// gráfica del Panel de Datos. Se hace en dos pasos y se agrega en Dart (en vez de un RPC en
  /// SQL) porque es el mismo patrón ya usado en el resto de la app para agregaciones sencillas
  /// (ver "listSeguidoresPorSedes").
  Future<List<AvisoEstadistica>> listEstadisticasAvisos(
    List<String> idsClienteSede, {
    int limit = 8,
  }) async {
    if (idsClienteSede.isEmpty) return [];
    final avisos = await _client
        .from('TClienteAvisos')
        .select('IdClienteAviso, Titulo, FechaAlta')
        .inFilter('IdClienteSede', idsClienteSede)
        .eq('EliminadoCliente', false)
        .order('FechaAlta', ascending: false)
        .limit(limit);
    final avisosList = (avisos as List).cast<Map<String, dynamic>>();
    final ids = avisosList.map((e) => e['IdClienteAviso'] as String).toList();
    if (ids.isEmpty) return [];

    final destinatarios = await _client
        .from('TClienteAvisosDestinatarios')
        .select('IdClienteAviso, Leido')
        .inFilter('IdClienteAviso', ids);
    final leidosPorAviso = <String, List<bool>>{};
    for (final fila in destinatarios as List) {
      final map = fila as Map<String, dynamic>;
      final id = map['IdClienteAviso'] as String;
      (leidosPorAviso[id] ??= []).add(map['Leido'] as bool);
    }

    return avisosList.map((map) {
      final id = map['IdClienteAviso'] as String;
      final destinatariosDeEste = leidosPorAviso[id] ?? const [];
      return AvisoEstadistica(
        idClienteAviso: id,
        titulo: map['Titulo'] as String,
        fechaAlta: DateTime.parse(map['FechaAlta'] as String),
        recibidos: destinatariosDeEste.length,
        leidos: destinatariosDeEste.where((leido) => leido).length,
      );
    }).toList();
  }
}

final avisosRepositoryProvider = Provider<AvisosRepository>((ref) {
  return AvisosRepository(Supabase.instance.client);
});
