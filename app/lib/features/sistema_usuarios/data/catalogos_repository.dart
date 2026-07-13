import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RolCatalogo {
  final String idSistemaRol;
  final String codigo;
  final String nombre;

  const RolCatalogo({required this.idSistemaRol, required this.codigo, required this.nombre});

  factory RolCatalogo.fromMap(Map<String, dynamic> map) => RolCatalogo(
        idSistemaRol: map['IdSistemaRol'] as String,
        codigo: map['Codigo'] as String,
        nombre: map['Nombre'] as String,
      );
}

class IdiomaCatalogo {
  final String idSistemaIdioma;
  final String codigo;
  final String nombre;

  const IdiomaCatalogo({required this.idSistemaIdioma, required this.codigo, required this.nombre});

  factory IdiomaCatalogo.fromMap(Map<String, dynamic> map) => IdiomaCatalogo(
        idSistemaIdioma: map['IdSistemaIdioma'] as String,
        codigo: map['Codigo'] as String,
        nombre: map['Nombre'] as String,
      );
}

class CatalogosRepository {
  final SupabaseClient _client;
  CatalogosRepository(this._client);

  Future<List<RolCatalogo>> listRoles() async {
    final data = await _client.from('TSistemaRoles').select().order('Nombre');
    return (data as List).map((e) => RolCatalogo.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<IdiomaCatalogo>> listIdiomas() async {
    final data = await _client.from('TSistemaIdiomas').select().order('Nombre');
    return (data as List).map((e) => IdiomaCatalogo.fromMap(e as Map<String, dynamic>)).toList();
  }
}

final catalogosRepositoryProvider = Provider<CatalogosRepository>((ref) {
  return CatalogosRepository(Supabase.instance.client);
});

final rolesCatalogoProvider = FutureProvider<List<RolCatalogo>>((ref) {
  return ref.watch(catalogosRepositoryProvider).listRoles();
});

final idiomasCatalogoProvider = FutureProvider<List<IdiomaCatalogo>>((ref) {
  return ref.watch(catalogosRepositoryProvider).listIdiomas();
});
