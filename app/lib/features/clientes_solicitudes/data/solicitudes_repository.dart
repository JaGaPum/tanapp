import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'solicitud_cliente.dart';

class SolicitudesRepository {
  final SupabaseClient _client;
  SolicitudesRepository(this._client);

  Future<void> crearSolicitud({
    required String razonSocial,
    required String nifCif,
    required String nombreContacto,
    required String emailContacto,
    required String telefonoContacto,
    String? localidad,
    String? provincia,
    String? observaciones,
  }) async {
    await _client.from('TClienteSolicitudes').insert({
      'RazonSocial': razonSocial.trim(),
      'NifCif': nifCif.trim(),
      'NombreContacto': nombreContacto.trim(),
      'EmailContacto': emailContacto.trim(),
      'TelefonoContacto': telefonoContacto.trim(),
      'Localidad': _blankToNull(localidad),
      'Provincia': _blankToNull(provincia),
      'Observaciones': _blankToNull(observaciones),
    });
  }

  Future<List<SolicitudCliente>> listSolicitudes({String? estado}) async {
    var query = _client.from('TClienteSolicitudes').select();
    if (estado != null) {
      query = query.eq('Estado', estado);
    }
    final data = await query.order('FechaAlta', ascending: false);
    return (data as List).map((e) => SolicitudCliente.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<SolicitudCliente> fetchById(String id) async {
    final data =
        await _client.from('TClienteSolicitudes').select().eq('IdClientesSolicitud', id).single();
    return SolicitudCliente.fromMap(data);
  }

  Future<void> resolver({
    required String id,
    required bool aprobar,
    String? observacionesResolucion,
    required String idSistemaUsuarioResolucion,
  }) async {
    await _client.from('TClienteSolicitudes').update({
      'Estado': aprobar ? 'APROBADA' : 'RECHAZADA',
      'ObservacionesResolucion': _blankToNull(observacionesResolucion),
      'FechaResolucion': DateTime.now().toIso8601String(),
      'IdSistemaUsuarioResolucion': idSistemaUsuarioResolucion,
    }).eq('IdClientesSolicitud', id);
  }

  Future<void> eliminarSolicitud(String id) async {
    await _client.from('TClienteSolicitudes').delete().eq('IdClientesSolicitud', id);
  }

  /// Invoca la Edge Function que crea la cuenta de Supabase Auth del cliente aprobado
  /// (sin contraseña; el cliente la establece con "¿Olvidaste tu contraseña?").
  /// Requiere que la función 'aprobar-solicitud-cliente' esté desplegada en Supabase.
  Future<void> crearUsuarioCliente(String idClientesSolicitud) async {
    await _client.functions.invoke(
      'aprobar-solicitud-cliente',
      body: {'idClientesSolicitud': idClientesSolicitud},
    );
  }

  String? _blankToNull(String? value) => (value == null || value.trim().isEmpty) ? null : value.trim();
}

final solicitudesRepositoryProvider = Provider<SolicitudesRepository>((ref) {
  return SolicitudesRepository(Supabase.instance.client);
});
