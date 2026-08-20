import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'termino.dart';
import 'termino_aceptacion_detalle.dart';
import 'termino_documento.dart';

class TerminosRepository {
  final SupabaseClient _client;
  TerminosRepository(this._client);

  static const _select =
      'IdSistemaTermino, Tipo, '
      'TSistemaTerminosIdiomas(IdSistemaIdioma, Titulo, Cuerpo, TSistemaIdiomas(Codigo))';

  static const _selectEditable =
      'IdSistemaTermino, Tipo, Version, Rol, '
      'TSistemaTerminosIdiomas(IdSistemaIdioma, Titulo, Cuerpo, TSistemaIdiomas(Codigo, Nombre))';

  // Cualquier usuario autenticado (particular o CLIENTE) puede dejar condolencias, así que
  // también necesita aceptar TERMINOS_USO -no solo quien publica esquelas- (051): la única
  // exención sigue siendo ADMIN.
  List<String> _tiposRequeridos(List<String> roles) {
    if (roles.contains('ADMIN')) return const [];
    return const ['TERMINOS_USO', 'PRIVACIDAD'];
  }

  /// CLIENTE y USUARIO_ORDINARIO son mutuamente excluyentes (ver 052), así que un usuario no
  /// ADMIN siempre tiene exactamente uno de los dos: es el que decide qué documentos por rol
  /// (060) le aplican.
  String? _rolParaTerminos(List<String> roles) {
    if (roles.contains('CLIENTE')) return 'CLIENTE';
    if (roles.contains('USUARIO_ORDINARIO')) return 'USUARIO_ORDINARIO';
    return null;
  }

  Future<List<Termino>> _fetchActivos(
    List<String> tipos,
    String? rol,
    String idiomaCodigo,
  ) async {
    if (tipos.isEmpty || rol == null) return const [];
    final data = await _client
        .from('TSistemaTerminos')
        .select(_select)
        .eq('Activo', true)
        .eq('Rol', rol)
        .inFilter('Tipo', tipos);
    return data.map((m) => Termino.fromMap(m, idiomaCodigo)).toList();
  }

  /// Documentos activos que le aplican a este usuario (según su rol) y que aún no ha
  /// aceptado. Vacío si no tiene nada pendiente (incluye el caso ADMIN, exento).
  Future<List<Termino>> fetchPendientes(
    String idSistemaUsuario,
    List<String> roles,
    String idiomaCodigo,
  ) async {
    final tipos = _tiposRequeridos(roles);
    final activos = await _fetchActivos(
      tipos,
      _rolParaTerminos(roles),
      idiomaCodigo,
    );
    if (activos.isEmpty) return const [];

    final aceptados = await _client
        .from('TSistemaTerminosAceptaciones')
        .select('IdSistemaTermino')
        .eq('IdSistemaUsuario', idSistemaUsuario);
    final idsAceptados = aceptados
        .map((a) => a['IdSistemaTermino'] as String)
        .toSet();

    return activos
        .where((t) => !idsAceptados.contains(t.idSistemaTermino))
        .toList();
  }

  /// Documentos activos que le aplican a este usuario, aceptados o no (para consultarlos
  /// después desde Cuenta).
  Future<List<Termino>> fetchActivos(List<String> roles, String idiomaCodigo) {
    return _fetchActivos(
      _tiposRequeridos(roles),
      _rolParaTerminos(roles),
      idiomaCodigo,
    );
  }

  /// [terminos] son los documentos tal cual se le mostraron al usuario (con su título/cuerpo/
  /// idioma ya resueltos): se guarda una copia de ese contenido en la propia aceptación (060),
  /// para poder saber después exactamente qué aceptó aunque el admin edite el documento más
  /// adelante.
  Future<void> aceptar(String idSistemaUsuario, List<Termino> terminos) async {
    await _client.from('TSistemaTerminosAceptaciones').insert([
      for (final t in terminos)
        {
          'IdSistemaUsuario': idSistemaUsuario,
          'IdSistemaTermino': t.idSistemaTermino,
          'IdSistemaIdioma': t.idSistemaIdioma,
          'Titulo': t.titulo,
          'Cuerpo': t.cuerpo,
        },
    ]);
  }

  /// Documentos activos (uno por combinación Tipo+Rol) con su contenido en todos los idiomas,
  /// para editarlos desde "Configuración > Términos y condiciones".
  Future<List<TerminoDocumento>> fetchDocumentosEditables() async {
    final data = await _client
        .from('TSistemaTerminos')
        .select(_selectEditable)
        .eq('Activo', true)
        .order('Tipo')
        .order('Rol');
    return (data as List)
        .map((e) => TerminoDocumento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Crea o actualiza el título/cuerpo de un documento en un idioma (upsert: la primera vez que
  /// se edita un idioma sin fila propia todavía, la crea).
  Future<void> guardarContenido({
    required String idSistemaTermino,
    required String idSistemaIdioma,
    required String titulo,
    required String cuerpo,
  }) async {
    await _client.from('TSistemaTerminosIdiomas').upsert({
      'IdSistemaTermino': idSistemaTermino,
      'IdSistemaIdioma': idSistemaIdioma,
      'Titulo': titulo.trim(),
      'Cuerpo': cuerpo.trim(),
    }, onConflict: 'IdSistemaTermino,IdSistemaIdioma');
  }

  /// Detalle documento a documento (con fecha y el texto exacto que se aceptó, si se guardó
  /// -060-) de lo que [idSistemaUsuario] ha aceptado, para la ficha de usuario del admin.
  Future<List<TerminoAceptacionDetalle>> fetchDetalleAceptaciones(
    String idSistemaUsuario,
    List<String> roles,
    String idiomaCodigo,
  ) async {
    final tipos = _tiposRequeridos(roles);
    final activos = await _fetchActivos(
      tipos,
      _rolParaTerminos(roles),
      idiomaCodigo,
    );
    if (activos.isEmpty) return const [];

    final aceptaciones = await _client
        .from('TSistemaTerminosAceptaciones')
        .select(
          'IdSistemaTermino, FechaAceptacion, Titulo, Cuerpo, TSistemaIdiomas(Codigo)',
        )
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .inFilter(
          'IdSistemaTermino',
          activos.map((t) => t.idSistemaTermino).toList(),
        );
    final aceptacionPorTermino = {
      for (final a in aceptaciones) a['IdSistemaTermino'] as String: a,
    };

    return activos.map((t) {
      final aceptacion = aceptacionPorTermino[t.idSistemaTermino];
      final idioma = aceptacion?['TSistemaIdiomas'] as Map<String, dynamic>?;
      return TerminoAceptacionDetalle(
        tipo: t.tipo,
        tituloActual: t.titulo,
        fechaAceptacion: aceptacion == null
            ? null
            : DateTime.parse(aceptacion['FechaAceptacion'] as String),
        tituloAceptado: aceptacion?['Titulo'] as String?,
        cuerpoAceptado: aceptacion?['Cuerpo'] as String?,
        idiomaAceptado: idioma?['Codigo'] as String?,
      );
    }).toList();
  }
}

final terminosRepositoryProvider = Provider<TerminosRepository>((ref) {
  return TerminosRepository(Supabase.instance.client);
});
