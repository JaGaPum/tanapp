import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../publicaciones/data/publicaciones_por_mes.dart';
import 'condolencia.dart';

class CondolenciasRepository {
  final SupabaseClient _client;
  CondolenciasRepository(this._client);

  // Las lecturas van contra la vista "VClientePublicacionesCondolencias" (049), que ya resuelve
  // el nombre del autor y lo oculta si es anónima, y solo incluye las privadas que quien
  // consulta puede ver. Las escrituras siguen yendo contra la tabla base (la vista no es
  // actualizable: tiene joins y CASE).
  static const _tablaLectura = 'VClientePublicacionesCondolencias';
  static const _tablaEscritura = 'TClientePublicacionesCondolencias';

  Future<String> _resolverIdSistemaUsuario() async {
    return _client
        .from('TSistemaUsuarios')
        .select('IdSistemaUsuario')
        .eq('IdAuthSupabase', _client.auth.currentUser!.id)
        .single()
        .then((row) => row['IdSistemaUsuario'] as String);
  }

  Future<List<Condolencia>> listCondolencias(
    String idClientePublicacion, {
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from(_tablaLectura)
        .select()
        .eq('IdClientePublicacion', idClientePublicacion)
        .order('FechaAlta', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List)
        .map((e) => Condolencia.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Todas de golpe (sin paginar), para volcarlas al PDF: un PDF paginado a medias no tendría
  /// sentido, el cliente quiere el libro completo.
  Future<List<Condolencia>> listTodasCondolencias(
    String idClientePublicacion,
  ) async {
    final data = await _client
        .from(_tablaLectura)
        .select()
        .eq('IdClientePublicacion', idClientePublicacion)
        .order('FechaAlta', ascending: false);
    return (data as List)
        .map((e) => Condolencia.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Consulta aparte de [listCondolencias] (no depende de qué página esté cargada): sirve para
  /// saber con seguridad si el usuario actual ya dejó una condolencia en esta publicación, y
  /// poder editarla en vez de intentar crear una segunda (choca con el índice único).
  Future<Condolencia?> fetchMiCondolencia(String idClientePublicacion) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    final data = await _client
        .from(_tablaLectura)
        .select()
        .eq('IdClientePublicacion', idClientePublicacion)
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .maybeSingle();
    return data == null ? null : Condolencia.fromMap(data);
  }

  Future<void> crearCondolencia({
    required String idClientePublicacion,
    required String texto,
    required bool anonima,
    required bool privada,
  }) async {
    final idSistemaUsuario = await _resolverIdSistemaUsuario();
    await _client.from(_tablaEscritura).insert({
      'IdClientePublicacion': idClientePublicacion,
      'IdSistemaUsuario': idSistemaUsuario,
      'Texto': texto.trim(),
      'Anonima': anonima,
      'Privada': privada,
    });
  }

  Future<void> actualizarCondolencia({
    required String idClientePublicacionCondolencia,
    required String texto,
    required bool anonima,
    required bool privada,
  }) async {
    await _client
        .from(_tablaEscritura)
        .update({
          'Texto': texto.trim(),
          'Anonima': anonima,
          'Privada': privada,
          // El propio autor vuelve a tocar el texto: cualquier aviso de "el cliente lo modificó"
          // queda obsoleto, lo que se ve ahora es lo que él mismo acaba de escribir.
          'ModeradaEditada': false,
        })
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }

  Future<void> eliminarCondolencia(
    String idClientePublicacionCondolencia,
  ) async {
    await _client
        .from(_tablaEscritura)
        .delete()
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }

  /// Moderación del cliente dueño de la esquela sobre una condolencia ajena: borrado lógico
  /// ("ModeradaOculta"), no un DELETE real -así el propio autor puede seguir viendo un aviso de
  /// que se retiró, en vez de que desaparezca sin explicación (ver "VClientePublicacionesCondolencias").
  Future<void> moderarEliminar(String idClientePublicacionCondolencia) async {
    await _client
        .from(_tablaEscritura)
        .update({'ModeradaOculta': true})
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }

  /// Moderación del cliente dueño de la esquela: reescribe el texto de una condolencia ajena
  /// (p. ej. para quitar una parte inapropiada) y marca "ModeradaEditada" para que el autor vea
  /// el aviso correspondiente.
  Future<void> moderarEditar({
    required String idClientePublicacionCondolencia,
    required String texto,
  }) async {
    await _client
        .from(_tablaEscritura)
        .update({'Texto': texto.trim(), 'ModeradaEditada': true})
        .eq('IdClientePublicacionCondolencia', idClientePublicacionCondolencia);
  }

  /// Condolencias recibidas por mes en las publicaciones del cliente (para el Panel de Datos,
  /// dentro de "Publicaciones"), en los últimos [meses] meses. Va contra la tabla base (no la
  /// vista): su RLS ya deja ver al dueño todas las suyas, privadas incluidas (050), y aquí solo
  /// hace falta la fecha, no el nombre/enmascarado del autor.
  Future<List<PublicacionesPorMes>> listCondolenciasPorMes(
    List<String> idsClientePublicacion, {
    int meses = 6,
  }) async {
    if (idsClientePublicacion.isEmpty) return [];
    final ahora = DateTime.now();
    final desde = DateTime(ahora.year, ahora.month - (meses - 1), 1);
    final data = await _client
        .from(_tablaEscritura)
        .select('FechaAlta')
        .eq('ModeradaOculta', false)
        .inFilter('IdClientePublicacion', idsClientePublicacion)
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

final condolenciasRepositoryProvider = Provider<CondolenciasRepository>((ref) {
  return CondolenciasRepository(Supabase.instance.client);
});
