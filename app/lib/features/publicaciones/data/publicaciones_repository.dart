import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'esquela_escaneada.dart';
import 'publicacion_con_sede.dart';
import 'publicaciones_por_mes.dart';

class PublicacionesRepository {
  final SupabaseClient _client;
  PublicacionesRepository(this._client);

  // "numCondolencias" es un "computed field" de PostgREST (049): llama a
  // FSistemaContarCondolencias, que cuenta TODAS las condolencias (anónimas y privadas
  // incluidas) sin aplicar su RLS, a diferencia del antiguo embed "...Condolencias(count)".
  static const _selectConSede =
      '*, TClienteSedes(Nombre, Concello, Provincia, TSistemaUsuarios(Nombre)), numCondolencias:FSistemaContarCondolencias';

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

  /// Publicaciones de los clientes que sigo o de clientes con sede en una zona que sigo, para
  /// el Taboleiro (que ya no es el tablón global: 045). Vía el RPC "FTablonPersonalizado", que
  /// resuelve el usuario llamante con auth.uid() (no hace falta pasarlo). Paginada para el
  /// scroll infinito: [offset]/[limit] son la página pedida.
  Future<List<PublicacionConSede>> listTablonPersonalizado({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client.rpc(
      'FTablonPersonalizado',
      params: {'p_offset': offset, 'p_limit': limit},
    );
    return (data as List)
        .map((e) => PublicacionConSede.fromSearchRow(e as Map<String, dynamic>))
        .toList();
  }

  /// Busca por [termino] en todo el histórico (no solo entre los clientes/zonas que sigo, ni lo
  /// que ya esté cargado en memoria en el Taboleiro), vía el RPC "FBuscarPublicacionesHistorico".
  Future<List<PublicacionConSede>> buscarHistorico({
    required String termino,
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client.rpc(
      'FBuscarPublicacionesHistorico',
      params: {'p_termino': termino, 'p_offset': offset, 'p_limit': limit},
    );
    return (data as List)
        .map((e) => PublicacionConSede.fromSearchRow(e as Map<String, dynamic>))
        .toList();
  }

  /// Manda la foto de una esquela a la Edge Function "escanear-esquela-imagen" (Claude con
  /// visión) para que extraiga sus datos; lanza si la función responde con error (p. ej. si el
  /// escaneo con IA no está activado), para que quien llame pueda recurrir al OCR local.
  Future<EsquelaEscaneada?> escanearConIa({
    required List<int> bytesImagen,
    required String idioma,
  }) async {
    final respuesta = await _client.functions.invoke(
      'escanear-esquela-imagen',
      body: {
        'imagenBase64': base64Encode(bytesImagen),
        'mimeType': 'image/jpeg',
        'idioma': idioma,
      },
    );
    final data = respuesta.data;
    if (data is! Map || data['campos'] is! Map) {
      throw Exception(
        data is Map
            ? (data['error'] ?? 'Respuesta inesperada')
            : 'Respuesta inesperada',
      );
    }
    return EsquelaEscaneada.fromMap(
      (data['campos'] as Map).cast<String, dynamic>(),
    );
  }

  /// Publicaciones de una lista de sedes concretas: se usa tanto para "mis publicaciones"
  /// (todas las sedes de un cliente) como para las de una única sede seguida.
  Future<List<PublicacionConSede>> listPorSedes(
    List<String> idsClienteSede,
  ) async {
    if (idsClienteSede.isEmpty) return [];
    final data = await _client
        .from('TClientePublicaciones')
        .select(_selectConSede)
        .inFilter('IdClienteSede', idsClienteSede)
        .order('FechaAlta', ascending: false);
    return (data as List)
        .map((e) => PublicacionConSede.fromMap(e as Map<String, dynamic>))
        .toList();
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
    await _client
        .from('TClientePublicaciones')
        .update({
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
        })
        .eq('IdClientePublicacion', idClientePublicacion);
  }

  Future<void> eliminarPublicacion(String idClientePublicacion) async {
    await _client
        .from('TClientePublicaciones')
        .delete()
        .eq('IdClientePublicacion', idClientePublicacion);
  }

  Future<Set<String>> listMisArchivadasIds() async {
    final data = await _client
        .from('TClientePublicacionesArchivadas')
        .select('IdClientePublicacion');
    return (data as List)
        .map(
          (e) => (e as Map<String, dynamic>)['IdClientePublicacion'] as String,
        )
        .toSet();
  }

  Future<List<PublicacionConSede>> listMisArchivadas({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('TClientePublicacionesArchivadas')
        .select('TClientePublicaciones($_selectConSede)')
        .order('FechaAlta', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map(
          (e) => PublicacionConSede.fromMap(
            (e as Map<String, dynamic>)['TClientePublicaciones']
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> archivar({
    required String idSistemaUsuario,
    required String idClientePublicacion,
  }) async {
    await _client.from('TClientePublicacionesArchivadas').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'IdClientePublicacion': idClientePublicacion,
    });
  }

  Future<void> desarchivar({
    required String idSistemaUsuario,
    required String idClientePublicacion,
  }) async {
    await _client
        .from('TClientePublicacionesArchivadas')
        .delete()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .eq('IdClientePublicacion', idClientePublicacion);
  }

  /// Publicaciones creadas por mes en los últimos [meses] meses (incluido el actual), para la
  /// gráfica de actividad del Panel de Datos. Se agrega en Dart en vez de con un RPC en SQL,
  /// mismo criterio que el resto de estadísticas sencillas de la app.
  Future<List<PublicacionesPorMes>> listPublicacionesPorMes(
    List<String> idsClienteSede, {
    int meses = 6,
  }) async {
    if (idsClienteSede.isEmpty) return [];
    final ahora = DateTime.now();
    final desde = DateTime(ahora.year, ahora.month - (meses - 1), 1);
    final data = await _client
        .from('TClientePublicaciones')
        .select('FechaAlta')
        .inFilter('IdClienteSede', idsClienteSede)
        .gte('FechaAlta', desde.toIso8601String());

    final conteos = <String, int>{};
    for (final fila in data as List) {
      final fecha = DateTime.parse(
        (fila as Map<String, dynamic>)['FechaAlta'] as String,
      ).toLocal();
      final clave = '${fecha.year}-${fecha.month}';
      conteos[clave] = (conteos[clave] ?? 0) + 1;
    }

    return List.generate(meses, (i) {
      final mes = DateTime(desde.year, desde.month + i, 1);
      final clave = '${mes.year}-${mes.month}';
      return PublicacionesPorMes(mes: mes, total: conteos[clave] ?? 0);
    });
  }
}

final publicacionesRepositoryProvider = Provider<PublicacionesRepository>((
  ref,
) {
  return PublicacionesRepository(Supabase.instance.client);
});
