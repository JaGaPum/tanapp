import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/galician_sort.dart';
import 'concello.dart';
import 'provincia.dart';

class ConfiguracionRepository {
  final SupabaseClient _client;
  ConfiguracionRepository(this._client);

  Future<List<Provincia>> listProvincias() async {
    final data = await _client.from('TConfiguracionProvincias').select();
    final provincias = (data as List)
        .map((e) => Provincia.fromMap(e as Map<String, dynamic>))
        .toList();
    provincias.sort(
      (a, b) =>
          claveOrdenGalego(a.nombre).compareTo(claveOrdenGalego(b.nombre)),
    );
    return provincias;
  }

  Future<List<Concello>> listConcellosPorProvincia(
    String idConfiguracionProvincia,
  ) async {
    final data = await _client
        .from('TConfiguracionConcellos')
        .select()
        .eq('IdConfiguracionProvincia', idConfiguracionProvincia);
    final concellos = (data as List)
        .map((e) => Concello.fromMap(e as Map<String, dynamic>))
        .toList();
    concellos.sort(
      (a, b) =>
          claveOrdenGalego(a.nombre).compareTo(claveOrdenGalego(b.nombre)),
    );
    return concellos;
  }

  Future<void> crearProvincia({
    required String nombre,
    required String prefijoPostal,
  }) async {
    await _client.from('TConfiguracionProvincias').insert({
      'Nombre': nombre.trim(),
      'PrefijoPostal': prefijoPostal.trim(),
    });
  }

  Future<void> actualizarProvincia({
    required String idConfiguracionProvincia,
    required String nombre,
    required String prefijoPostal,
  }) async {
    await _client
        .from('TConfiguracionProvincias')
        .update({
          'Nombre': nombre.trim(),
          'PrefijoPostal': prefijoPostal.trim(),
        })
        .eq('IdConfiguracionProvincia', idConfiguracionProvincia);
  }

  Future<void> eliminarProvincia(String idConfiguracionProvincia) async {
    await _client
        .from('TConfiguracionProvincias')
        .delete()
        .eq('IdConfiguracionProvincia', idConfiguracionProvincia);
  }

  Future<void> crearConcello({
    required String idConfiguracionProvincia,
    required String nombre,
  }) async {
    await _client.from('TConfiguracionConcellos').insert({
      'IdConfiguracionProvincia': idConfiguracionProvincia,
      'Nombre': nombre.trim(),
    });
  }

  Future<void> actualizarConcello({
    required String idConfiguracionConcello,
    required String nombre,
  }) async {
    await _client
        .from('TConfiguracionConcellos')
        .update({'Nombre': nombre.trim()})
        .eq('IdConfiguracionConcello', idConfiguracionConcello);
  }

  Future<void> eliminarConcello(String idConfiguracionConcello) async {
    await _client
        .from('TConfiguracionConcellos')
        .delete()
        .eq('IdConfiguracionConcello', idConfiguracionConcello);
  }

  /// Fila única de parámetros globales (ver migración 030). Se lee sin filtro porque solo existe
  /// esa fila.
  Future<bool> fetchImportacionWebIaActiva() async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .select('ImportacionWebIaActiva')
        .single();
    return data['ImportacionWebIaActiva'] as bool;
  }

  /// Solo hay una fila y no hay policy de INSERT/DELETE que permita que aparezca una segunda,
  /// pero Supabase exige igualmente una cláusula WHERE en todo UPDATE/DELETE (protección
  /// "safeupdate" activada por defecto): de ahí el filtro "no nulo" sobre la clave primaria, que
  /// siempre es cierto. Se fuerza además ".select()" (en vez de dejar el "return=minimal" por
  /// defecto) para poder detectar si la policy de UPDATE bloqueó la fila: en RLS eso no da error,
  /// sencillamente actualiza 0 filas, así que sin esta comprobación el fallo pasaría
  /// desapercibido y el interruptor "no se quedaría marcado" sin explicación.
  Future<void> actualizarImportacionWebIaActiva(bool activa) async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .update({'ImportacionWebIaActiva': activa})
        .not('IdConfiguracionGlobal', 'is', null)
        .select();
    if ((data as List).isEmpty) {
      throw Exception(
        'No se pudo actualizar la configuración global: tu usuario no tiene permiso de administrador '
        '(revisa que tenga el rol ADMIN) o falta aplicar la migración 030.',
      );
    }
  }

  /// Igual que [fetchImportacionWebIaActiva] pero para el escaneo de esquelas por foto
  /// (migración 041): interruptor independiente, se puede activar uno sin el otro.
  Future<bool> fetchEscaneoEsquelaIaActiva() async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .select('EscaneoEsquelaIaActiva')
        .single();
    return data['EscaneoEsquelaIaActiva'] as bool;
  }

  Future<void> actualizarEscaneoEsquelaIaActiva(bool activa) async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .update({'EscaneoEsquelaIaActiva': activa})
        .not('IdConfiguracionGlobal', 'is', null)
        .select();
    if ((data as List).isEmpty) {
      throw Exception(
        'No se pudo actualizar la configuración global: tu usuario no tiene permiso de administrador '
        '(revisa que tenga el rol ADMIN) o falta aplicar la migración 041.',
      );
    }
  }

  /// Igual que [fetchImportacionWebIaActiva] pero para el botón de login con Google (073): se lee
  /// también desde la pantalla de login, sin sesión iniciada todavía.
  Future<bool> fetchGoogleLoginActivo() async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .select('GoogleLoginActivo')
        .single();
    return data['GoogleLoginActivo'] as bool;
  }

  Future<void> actualizarGoogleLoginActivo(bool activo) async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .update({'GoogleLoginActivo': activo})
        .not('IdConfiguracionGlobal', 'is', null)
        .select();
    if ((data as List).isEmpty) {
      throw Exception(
        'No se pudo actualizar la configuración global: tu usuario no tiene permiso de administrador '
        '(revisa que tenga el rol ADMIN) o falta aplicar la migración 073.',
      );
    }
  }

  /// Igual que [fetchGoogleLoginActivo] pero para Facebook (073) — interruptor independiente,
  /// para poder tener uno activo sin el otro (p. ej. mientras Facebook espera la revisión de
  /// Meta).
  Future<bool> fetchFacebookLoginActivo() async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .select('FacebookLoginActivo')
        .single();
    return data['FacebookLoginActivo'] as bool;
  }

  Future<void> actualizarFacebookLoginActivo(bool activo) async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .update({'FacebookLoginActivo': activo})
        .not('IdConfiguracionGlobal', 'is', null)
        .select();
    if ((data as List).isEmpty) {
      throw Exception(
        'No se pudo actualizar la configuración global: tu usuario no tiene permiso de administrador '
        '(revisa que tenga el rol ADMIN) o falta aplicar la migración 073.',
      );
    }
  }

  /// Igual que [fetchGoogleLoginActivo] pero para Apple (074), empieza en false hasta que la
  /// cuenta de Apple Developer y el proveedor en Supabase estén configurados.
  Future<bool> fetchAppleLoginActivo() async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .select('AppleLoginActivo')
        .single();
    return data['AppleLoginActivo'] as bool;
  }

  Future<void> actualizarAppleLoginActivo(bool activo) async {
    final data = await _client
        .from('TConfiguracionGlobal')
        .update({'AppleLoginActivo': activo})
        .not('IdConfiguracionGlobal', 'is', null)
        .select();
    if ((data as List).isEmpty) {
      throw Exception(
        'No se pudo actualizar la configuración global: tu usuario no tiene permiso de administrador '
        '(revisa que tenga el rol ADMIN) o falta aplicar la migración 074.',
      );
    }
  }
}

final configuracionRepositoryProvider = Provider<ConfiguracionRepository>((
  ref,
) {
  return ConfiguracionRepository(Supabase.instance.client);
});
