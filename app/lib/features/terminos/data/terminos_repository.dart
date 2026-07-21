import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'termino.dart';

class TerminosRepository {
  final SupabaseClient _client;
  TerminosRepository(this._client);

  static const _select = 'IdSistemaTermino, Tipo, '
      'TSistemaTerminosIdiomas(Titulo, Cuerpo, TSistemaIdiomas(Codigo))';

  List<String> _tiposRequeridos(List<String> roles) {
    if (roles.contains('ADMIN')) return const [];
    if (roles.contains('CLIENTE')) return const ['TERMINOS_USO', 'PRIVACIDAD'];
    return const ['PRIVACIDAD'];
  }

  Future<List<Termino>> _fetchActivos(List<String> tipos, String idiomaCodigo) async {
    if (tipos.isEmpty) return const [];
    final data = await _client.from('TSistemaTerminos').select(_select).eq('Activo', true).inFilter('Tipo', tipos);
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
    final activos = await _fetchActivos(tipos, idiomaCodigo);
    if (activos.isEmpty) return const [];

    final aceptados = await _client
        .from('TSistemaTerminosAceptaciones')
        .select('IdSistemaTermino')
        .eq('IdSistemaUsuario', idSistemaUsuario);
    final idsAceptados = aceptados.map((a) => a['IdSistemaTermino'] as String).toSet();

    return activos.where((t) => !idsAceptados.contains(t.idSistemaTermino)).toList();
  }

  /// Documentos activos que le aplican a este usuario, aceptados o no (para consultarlos
  /// después desde Cuenta).
  Future<List<Termino>> fetchActivos(List<String> roles, String idiomaCodigo) {
    return _fetchActivos(_tiposRequeridos(roles), idiomaCodigo);
  }

  Future<void> aceptar(String idSistemaUsuario, List<String> idsSistemaTermino) async {
    await _client.from('TSistemaTerminosAceptaciones').insert([
      for (final id in idsSistemaTermino) {'IdSistemaUsuario': idSistemaUsuario, 'IdSistemaTermino': id},
    ]);
  }
}

final terminosRepositoryProvider = Provider<TerminosRepository>((ref) {
  return TerminosRepository(Supabase.instance.client);
});
