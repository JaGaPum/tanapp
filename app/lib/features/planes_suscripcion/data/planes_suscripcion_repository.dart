import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';
import 'estado_suscripcion.dart';
import 'pago_suscripcion.dart';
import 'periodo_gratuito.dart';
import 'plan_suscripcion.dart';

class PlanesSuscripcionRepository {
  final SupabaseClient _client;
  PlanesSuscripcionRepository(this._client);

  /// Estado de suscripción del usuario actual (078): null si no es un cliente (p. ej. usuario
  /// ordinario, que no tiene fila propia que resolver en la RPC).
  Future<EstadoSuscripcion?> fetchMiEstadoSuscripcion() async {
    final data = await _client.rpc('FSistemaMiEstadoSuscripcion');
    final lista = data as List;
    if (lista.isEmpty) return null;
    return EstadoSuscripcion.fromMap(lista.first as Map<String, dynamic>);
  }

  Future<List<PlanSuscripcion>> listPlanes() async {
    final data = await _client
        .from('TConfiguracionPlanesSuscripcion')
        .select()
        .order('PrecioMensual');
    return (data as List)
        .map((e) => PlanSuscripcion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Precio, límite de sedes y máximo de escaneos con IA al día por sede (082) son editables
  /// (075): los planes en sí son fijos, no hay alta/baja/renombrado desde la app.
  Future<void> actualizarPlan({
    required String idConfiguracionPlanSuscripcion,
    required double precioMensual,
    required int maxSedes,
    int? maxEscaneosIaPorDia,
  }) async {
    try {
      await _client
          .from('TConfiguracionPlanesSuscripcion')
          .update({
            'PrecioMensual': precioMensual,
            'MaxSedes': maxSedes,
            'MaxEscaneosIaPorDia': maxEscaneosIaPorDia,
          })
          .eq('IdConfiguracionPlanSuscripcion', idConfiguracionPlanSuscripcion);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  /// Periodos gratuitos propios de un cliente (080): pensados para regalarle más tiempo del
  /// general a alguien en concreto. Solo el ADMIN puede gestionarlos (ver RLS de la migración).
  Future<List<PeriodoGratuito>> listPeriodosGratuitosCliente(
    String idSistemaUsuario,
  ) async {
    final data = await _client
        .from('TSistemaUsuarioPeriodosGratuitos')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .order('Inicio', ascending: false);
    return (data as List)
        .map(
          (e) => PeriodoGratuito.fromMap(
            e as Map<String, dynamic>,
            'IdSistemaUsuarioPeriodoGratuito',
          ),
        )
        .toList();
  }

  Future<void> crearPeriodoGratuitoCliente({
    required String idSistemaUsuario,
    required DateTime inicio,
    DateTime? fin,
  }) async {
    try {
      await _client.from('TSistemaUsuarioPeriodosGratuitos').insert({
        'IdSistemaUsuario': idSistemaUsuario,
        'Inicio': inicio.toUtc().toIso8601String(),
        'Fin': fin?.toUtc().toIso8601String(),
      });
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> actualizarPeriodoGratuitoCliente({
    required String idSistemaUsuarioPeriodoGratuito,
    required DateTime inicio,
    DateTime? fin,
  }) async {
    try {
      await _client
          .from('TSistemaUsuarioPeriodosGratuitos')
          .update({
            'Inicio': inicio.toUtc().toIso8601String(),
            'Fin': fin?.toUtc().toIso8601String(),
          })
          .eq(
            'IdSistemaUsuarioPeriodoGratuito',
            idSistemaUsuarioPeriodoGratuito,
          );
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> eliminarPeriodoGratuitoCliente(
    String idSistemaUsuarioPeriodoGratuito,
  ) async {
    await _client
        .from('TSistemaUsuarioPeriodosGratuitos')
        .delete()
        .eq('IdSistemaUsuarioPeriodoGratuito', idSistemaUsuarioPeriodoGratuito);
  }

  /// Historial de pagos de un cliente (083): "FechaFinCobertura" siempre la calcula un trigger
  /// (fechaPago + 30 días), no se manda desde aquí. Solo el ADMIN registra/borra pagos (ver RLS).
  Future<List<PagoSuscripcion>> listPagosCliente(
    String idSistemaUsuario,
  ) async {
    final data = await _client
        .from('TSistemaUsuarioPagos')
        .select()
        .eq('IdSistemaUsuario', idSistemaUsuario)
        .order('FechaPago', ascending: false);
    return (data as List)
        .map((e) => PagoSuscripcion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> registrarPago({
    required String idSistemaUsuario,
    required DateTime fechaPago,
  }) async {
    try {
      await _client.from('TSistemaUsuarioPagos').insert({
        'IdSistemaUsuario': idSistemaUsuario,
        'FechaPago': fechaPago.toUtc().toIso8601String(),
      });
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> eliminarPago(String idSistemaUsuarioPago) async {
    await _client
        .from('TSistemaUsuarioPagos')
        .delete()
        .eq('IdSistemaUsuarioPago', idSistemaUsuarioPago);
  }
}

final planesSuscripcionRepositoryProvider =
    Provider<PlanesSuscripcionRepository>((ref) {
      return PlanesSuscripcionRepository(Supabase.instance.client);
    });
