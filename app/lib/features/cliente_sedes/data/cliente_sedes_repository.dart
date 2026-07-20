import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente_sede.dart';

class ClienteSedesRepository {
  final SupabaseClient _client;
  ClienteSedesRepository(this._client);

  /// La RLS ya restringe a las sedes propias (o todas, si quien llama es ADMIN); lo usa tanto
  /// el propio cliente en autoservicio como el ADMIN viendo la ficha de un usuario.
  Future<List<ClienteSede>> listSedesDeUsuario(String idSistemaUsuario) async {
    final data = await _client
        .from('TClienteSedes')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .order('Nombre');
    return (data as List).map((e) => ClienteSede.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> crearSede({
    required String idSistemaUsuario,
    required String codigo,
    required String nombre,
    required String provincia,
    required String concello,
    required String direccion,
  }) async {
    await _client.from('TClienteSedes').insert({
      'IdSistemaUsuario': idSistemaUsuario,
      'Codigo': codigo.trim(),
      'Nombre': nombre.trim(),
      'Provincia': provincia,
      'Concello': concello,
      'Direccion': direccion.trim(),
    });
  }

  Future<void> actualizarSede({
    required String idClienteSede,
    required String codigo,
    required String nombre,
    required String provincia,
    required String concello,
    required String direccion,
  }) async {
    await _client.from('TClienteSedes').update({
      'Codigo': codigo.trim(),
      'Nombre': nombre.trim(),
      'Provincia': provincia,
      'Concello': concello,
      'Direccion': direccion.trim(),
    }).eq('IdClienteSede', idClienteSede);
  }

  Future<void> eliminarSede(String idClienteSede) async {
    await _client.from('TClienteSedes').delete().eq('IdClienteSede', idClienteSede);
  }
}

final clienteSedesRepositoryProvider = Provider<ClienteSedesRepository>((ref) {
  return ClienteSedesRepository(Supabase.instance.client);
});
