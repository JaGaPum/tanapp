import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'clientes_stats.dart';
import 'conteo_por_periodo.dart';
import 'ia_stats.dart';
import 'usuarios_stats.dart';

/// Mismo criterio que el resto de estadísticas de la app (Panel de Datos del cliente): se traen
/// las filas ya filtradas por rango de fechas cuando aplica, y se agregan en Dart, en vez de con
/// funciones SQL a medida.
class DashboardRepository {
  final SupabaseClient _client;
  DashboardRepository(this._client);

  static const _perfilConRolSelect =
      '*, TSistemaUsuariosRoles!FK_TSistemaUsuariosRoles_IdSistemaUsuario(TSistemaRoles(Codigo))';

  Future<List<Map<String, dynamic>>> _listUsuariosPorRol(
    String rolCodigo,
  ) async {
    final data = await _client
        .from('TSistemaUsuarios')
        .select(_perfilConRolSelect);
    return (data as List).map((e) => e as Map<String, dynamic>).where((
      usuario,
    ) {
      final roles = (usuario['TSistemaUsuariosRoles'] as List? ?? const [])
          .map(
            (r) => ((r as Map)['TSistemaRoles'] as Map?)?['Codigo'] as String?,
          )
          .toSet();
      return roles.contains(rolCodigo);
    }).toList();
  }

  List<ConteoPorPeriodo> _agruparPorMes(List<DateTime> fechas, int meses) {
    final ahora = DateTime.now();
    final desde = DateTime(ahora.year, ahora.month - (meses - 1), 1);
    final conteos = <String, int>{};
    for (final fecha in fechas) {
      final local = fecha.toLocal();
      if (local.isBefore(desde)) continue;
      conteos['${local.year}-${local.month}'] =
          (conteos['${local.year}-${local.month}'] ?? 0) + 1;
    }
    return List.generate(meses, (i) {
      final mes = DateTime(desde.year, desde.month + i, 1);
      return ConteoPorPeriodo(
        periodo: mes,
        total: conteos['${mes.year}-${mes.month}'] ?? 0,
      );
    });
  }

  Future<List<DateTime>> _fetchBajasPorRol(String rolCodigo) async {
    final data = await _client
        .from('TSistemaBajas')
        .select('FechaAlta')
        .eq('Rol', rolCodigo);
    return (data as List)
        .map(
          (e) => DateTime.parse(
            (e as Map<String, dynamic>)['FechaAlta'] as String,
          ),
        )
        .toList();
  }

  Future<ClientesStats> fetchClientesStats() async {
    final clientes = await _listUsuariosPorRol('CLIENTE');
    final activos = clientes.where((c) => c['Activo'] == true).length;

    final sedesCount = await _client
        .from('TClienteSedes')
        .select('IdClienteSede')
        .count(CountOption.exact);

    final publicaciones = await _client
        .from('TClientePublicaciones')
        .select('FechaAlta, TClienteSedes(TSistemaUsuarios(Nombre))')
        .order('FechaAlta', ascending: false);
    final publicacionesList = (publicaciones as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    final avisos = await _client
        .from('TClienteAvisos')
        .select('FechaAlta')
        .order('FechaAlta', ascending: false);
    final avisosList = (avisos as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Las ocultas por moderación (050) no cuentan, igual que en "FSistemaContarCondolencias".
    final condolenciasCount = await _client
        .from('TClientePublicacionesCondolencias')
        .select('IdClientePublicacionCondolencia')
        .eq('ModeradaOculta', false)
        .count(CountOption.exact);

    final porTipoConteo = <String, int>{};
    for (final cliente in clientes) {
      final tipo = cliente['IdConfiguracionClienteTipo'] as String?;
      final clave = tipo ?? '—';
      porTipoConteo[clave] = (porTipoConteo[clave] ?? 0) + 1;
    }

    final porClienteConteo = <String, int>{};
    for (final publicacion in publicacionesList) {
      final sede = publicacion['TClienteSedes'] as Map<String, dynamic>?;
      final nombreCliente =
          (sede?['TSistemaUsuarios'] as Map<String, dynamic>?)?['Nombre']
              as String?;
      if (nombreCliente == null) continue;
      porClienteConteo[nombreCliente] =
          (porClienteConteo[nombreCliente] ?? 0) + 1;
    }
    final topClientes = porClienteConteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bajas = await _fetchBajasPorRol('CLIENTE');

    return ClientesStats(
      totalActivos: activos,
      totalInactivos: clientes.length - activos,
      totalSedes: sedesCount.count,
      totalPublicaciones: publicacionesList.length,
      totalAvisos: avisosList.length,
      totalCondolencias: condolenciasCount.count,
      // El nombre de cada tipo se resuelve aparte (catálogo de tipos de cliente), aquí solo se
      // agrupa por id: lo hace el provider, que ya tiene ambos datos.
      porTipo: porTipoConteo.entries.toList(),
      publicacionesPorMes: _agruparPorMes(
        publicacionesList
            .map((p) => DateTime.parse(p['FechaAlta'] as String))
            .toList(),
        6,
      ),
      avisosPorMes: _agruparPorMes(
        avisosList
            .map((a) => DateTime.parse(a['FechaAlta'] as String))
            .toList(),
        6,
      ),
      altasPorMes: _agruparPorMes(
        clientes.map((c) => DateTime.parse(c['FechaAlta'] as String)).toList(),
        6,
      ),
      bajasPorMes: _agruparPorMes(bajas, 6),
      topClientesPorPublicaciones: topClientes.take(5).toList(),
    );
  }

  Future<UsuariosStats> fetchUsuariosStats() async {
    final usuarios = await _listUsuariosPorRol('USUARIO_ORDINARIO');
    final activos = usuarios.where((u) => u['Activo'] == true).length;
    final conPush = usuarios
        .where((u) => u['NotificacionesPushActivas'] == true)
        .length;

    final seguimientosCount = await _client
        .from('TClienteSeguimientos')
        .select('IdClienteSeguimiento')
        .count(CountOption.exact);
    final zonasCount = await _client
        .from('TSistemaUsuarioZonas')
        .select('IdSistemaUsuarioZona')
        .count(CountOption.exact);

    final porIdiomaConteo = <String, int>{};
    for (final usuario in usuarios) {
      final idioma = usuario['IdSistemaIdiomaPreferido'] as String?;
      final clave = idioma ?? '—';
      porIdiomaConteo[clave] = (porIdiomaConteo[clave] ?? 0) + 1;
    }

    final porConcelloConteo = <String, int>{};
    for (final usuario in usuarios) {
      final concello = usuario['Concello'] as String?;
      if (concello == null || concello.trim().isEmpty) continue;
      porConcelloConteo[concello] = (porConcelloConteo[concello] ?? 0) + 1;
    }
    final topConcellos = porConcelloConteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bajas = await _fetchBajasPorRol('USUARIO_ORDINARIO');

    return UsuariosStats(
      totalActivos: activos,
      totalInactivos: usuarios.length - activos,
      totalConNotificacionesPush: conPush,
      altasPorMes: _agruparPorMes(
        usuarios.map((u) => DateTime.parse(u['FechaAlta'] as String)).toList(),
        6,
      ),
      bajasPorMes: _agruparPorMes(bajas, 6),
      totalSeguimientos: seguimientosCount.count,
      totalZonasSeguidas: zonasCount.count,
      // Igual que porTipo en ClientesStats: aquí se agrupa por id de idioma, el provider lo
      // traduce a nombre con el catálogo.
      porIdioma: porIdiomaConteo.entries.toList(),
      topConcellos: topConcellos.take(8).toList(),
    );
  }

  Future<IaStats> fetchIaStats() async {
    final data = await _client
        .from('TSistemaUsuarioEscaneoIaLog')
        .select(
          'IdSistemaUsuario, Exito, TokensEntrada, TokensSalida, FechaAlta, TSistemaUsuarios(Nombre)',
        )
        .order('FechaAlta', ascending: false);
    final filas = (data as List).map((e) => e as Map<String, dynamic>).toList();

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    var peticionesHoy = 0;
    var peticionesMes = 0;
    var costoHoy = 0.0;
    var costoMes = 0.0;
    var costoTotal = 0.0;
    var exitosas = 0;
    final porDiaConteo = <DateTime, int>{};
    final porUsuarioEsteMes =
        <String, ({String nombre, int peticiones, double costo})>{};

    for (final fila in filas) {
      final fecha = DateTime.parse(fila['FechaAlta'] as String).toLocal();
      final tokensEntrada = fila['TokensEntrada'] as int? ?? 0;
      final tokensSalida = fila['TokensSalida'] as int? ?? 0;
      final costo = costoEstimado(
        tokensEntrada: tokensEntrada,
        tokensSalida: tokensSalida,
      );
      final esHoy =
          fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day;
      final esEsteMes = fecha.year == ahora.year && fecha.month == ahora.month;
      if (fila['Exito'] == true) exitosas++;

      costoTotal += costo;
      if (esHoy) {
        peticionesHoy++;
        costoHoy += costo;
      }
      if (esEsteMes) {
        peticionesMes++;
        costoMes += costo;

        final idUsuario = fila['IdSistemaUsuario'] as String;
        final nombre =
            (fila['TSistemaUsuarios'] as Map<String, dynamic>?)?['Nombre']
                as String? ??
            '—';
        final actual = porUsuarioEsteMes[idUsuario];
        porUsuarioEsteMes[idUsuario] = (
          nombre: nombre,
          peticiones: (actual?.peticiones ?? 0) + 1,
          costo: (actual?.costo ?? 0) + costo,
        );
      }

      if (fecha.isAfter(hoy.subtract(const Duration(days: 30)))) {
        final dia = DateTime(fecha.year, fecha.month, fecha.day);
        porDiaConteo[dia] = (porDiaConteo[dia] ?? 0) + 1;
      }
    }

    final peticionesPorDia = List.generate(30, (i) {
      final dia = hoy.subtract(Duration(days: 29 - i));
      return ConteoPorPeriodo(periodo: dia, total: porDiaConteo[dia] ?? 0);
    });

    final usoPorUsuario =
        porUsuarioEsteMes.entries
            .map(
              (e) => IaUsoPorUsuario(
                idSistemaUsuario: e.key,
                nombreUsuario: e.value.nombre,
                peticiones: e.value.peticiones,
                costoEstimado: e.value.costo,
              ),
            )
            .toList()
          ..sort((a, b) => b.costoEstimado.compareTo(a.costoEstimado));

    return IaStats(
      peticionesHoy: peticionesHoy,
      peticionesMes: peticionesMes,
      peticionesTotal: filas.length,
      costoHoy: costoHoy,
      costoMes: costoMes,
      costoTotal: costoTotal,
      tasaExito: filas.isEmpty ? 1 : exitosas / filas.length,
      peticionesPorDia: peticionesPorDia,
      usoPorUsuarioEsteMes: usoPorUsuario,
    );
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});
