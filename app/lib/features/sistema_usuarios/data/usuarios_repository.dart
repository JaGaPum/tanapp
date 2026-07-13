import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'usuario_perfil.dart';

class UsuariosRepository {
  final SupabaseClient _client;
  UsuariosRepository(this._client);

  // El hint !FK_... es obligatorio: TSistemaUsuariosRoles tiene 3 FKs distintas hacia
  // TSistemaUsuarios (la relación + IdSistemaUsuarioAlta/Modificacion de auditoría),
  // así que PostgREST no puede resolver el embed sin que le digamos cuál usar.
  static const _perfilSelect =
      '*, TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario'
      '(IdSistemaUsuarioRol, IdSistemaRol, TSistemaRoles(IdSistemaRol, Codigo, Nombre))';

  Future<UsuarioPerfil?> fetchPerfilByAuthId(String authId) async {
    final data = await _client
        .from('TSistemaUsuarios')
        .select(_perfilSelect)
        .eq('IdAuthSupabase', authId)
        .maybeSingle();
    if (data == null) return null;
    return UsuarioPerfil.fromMap(data);
  }

  Future<UsuarioPerfil> fetchPerfilById(String idSistemaUsuario) async {
    final data = await _client
        .from('TSistemaUsuarios')
        .select(_perfilSelect)
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .single();
    return UsuarioPerfil.fromMap(data);
  }

  Future<List<UsuarioPerfil>> listUsuarios({
    String? busqueda,
    String? rolCodigo,
    bool? soloActivos,
  }) async {
    var query = _client.from('TSistemaUsuarios').select(_perfilSelect);

    final term = busqueda?.trim() ?? '';
    if (term.isNotEmpty) {
      query = query.or('Nombre.ilike.%$term%,Email.ilike.%$term%');
    }
    if (soloActivos != null) {
      query = query.eq('Activo', soloActivos);
    }

    final data = await query.order('Nombre');
    var lista = (data as List).map((e) => UsuarioPerfil.fromMap(e as Map<String, dynamic>)).toList();

    if (rolCodigo != null && rolCodigo.isNotEmpty) {
      lista = lista.where((u) => u.roles.contains(rolCodigo)).toList();
    }
    return lista;
  }

  Future<void> updatePerfil({
    required String idSistemaUsuario,
    required String nombre,
    required String apellido1,
    String? apellido2,
    String? telefono,
    String? concello,
    String? provincia,
    String? idSistemaIdiomaPreferido,
    required bool activo,
  }) async {
    String? normalizado(String? valor) => (valor == null || valor.trim().isEmpty) ? null : valor.trim();

    await _client.from('TSistemaUsuarios').update({
      'Nombre': nombre.trim(),
      'Apellido1': apellido1.trim(),
      'Apellido2': normalizado(apellido2),
      'Telefono': normalizado(telefono),
      'Concello': normalizado(concello),
      'Provincia': normalizado(provincia),
      'IdSistemaIdiomaPreferido': idSistemaIdiomaPreferido,
      'Activo': activo,
    }).eq('IdSistemaUsuario', idSistemaUsuario);
  }

  Future<String> subirFoto({
    required String idSistemaUsuario,
    required String authId,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    final path = '$authId/avatar.$extension';
    await _client.storage.from('avatares').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );
    final publicUrl = _client.storage.from('avatares').getPublicUrl(path);
    final urlConCache = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('TSistemaUsuarios').update({'FotoUrl': urlConCache}).eq(
          'IdSistemaUsuario',
          idSistemaUsuario,
        );
    return urlConCache;
  }

  Future<void> asignarRol({required String idSistemaUsuario, required String idSistemaRol}) async {
    await _client.from('TSistemaUsuariosRoles').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'IdSistemaRol': idSistemaRol,
    });
  }

  Future<void> quitarRol({required String idSistemaUsuarioRol}) async {
    await _client.from('TSistemaUsuariosRoles').delete().eq('IdSistemaUsuarioRol', idSistemaUsuarioRol);
  }

  Future<void> confirmarEmail(String idSistemaUsuario) async {
    await _client.rpc('FSistemaAdminConfirmarEmail', params: {'id_sistema_usuario': idSistemaUsuario});
  }

  Future<void> eliminarUsuario(String idSistemaUsuario) async {
    await _client.from('TSistemaUsuariosRoles').delete().eq('IdSistemaUsuario', idSistemaUsuario);
    await _client.from('TSistemaUsuarios').delete().eq('IdSistemaUsuario', idSistemaUsuario);
  }
}

final usuariosRepositoryProvider = Provider<UsuariosRepository>((ref) {
  return UsuariosRepository(Supabase.instance.client);
});
