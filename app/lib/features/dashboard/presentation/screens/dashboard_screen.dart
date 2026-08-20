import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../sesiones/application/sesiones_providers.dart';
import '../../../sesiones/data/sesion.dart';
import '../../../sesiones/data/sesiones_repository.dart';
import '../../application/dashboard_providers.dart';
import '../../data/conteo_por_periodo.dart';
import '../../data/ia_stats.dart';

/// Paleta al estilo de los templates de administración habituales (AdminLTE/CoreUI/Bootstrap):
/// un color de acento distinto por tarjeta/gráfica, en vez del monocromo del resto de la app.
class _DashColors {
  static const azul = Color(0xFF0D6EFD);
  static const verde = Color(0xFF198754);
  static const naranja = Color(0xFFFD7E14);
  static const rojo = Color(0xFFDC3545);
  static const cian = Color(0xFF0DCAF0);
  static const morado = Color(0xFF6F42C1);
  static const amarillo = Color(0xFFFFC107);
  static const fondoPagina = Color(0xFFF4F6F9);
}

// La API de Anthropic factura en dólares; no hay forma de consultar el cambio en vivo desde
// aquí, así que se usa un tipo de cambio fijo aproximado (revisar de vez en cuando a mano).
const _usdAEur = 0.92;

String _formatCosto(double valorUsd) {
  final decimales = valorUsd < 1 ? 4 : 2;
  final valorEur = valorUsd * _usdAEur;
  return '\$${valorUsd.toStringAsFixed(decimales)} (≈${valorEur.toStringAsFixed(decimales)} €)';
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: _DashColors.fondoPagina,
        appBar: AppBar(
          title: Text(context.l10n.dashboardTitulo),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.storefront_outlined),
                text: context.l10n.dashboardTabClientes,
              ),
              Tab(
                icon: const Icon(Icons.people_outline),
                text: context.l10n.dashboardTabUsuarios,
              ),
              Tab(
                icon: const Icon(Icons.smart_toy_outlined),
                text: context.l10n.dashboardTabIa,
              ),
              Tab(
                icon: const Icon(Icons.sensors),
                text: context.l10n.dashboardTabEnVivo,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ClientesTab(), _UsuariosTab(), _IaTab(), _EnVivoTab()],
        ),
      ),
    );
  }
}

class _ClientesTab extends ConsumerWidget {
  const _ClientesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(clientesStatsProvider);
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatGrid(
              tiles: [
                _StatTile(
                  label: context.l10n.dashboardClientesActivos,
                  value: '${stats.totalActivos}',
                  icon: Icons.storefront,
                  color: _DashColors.verde,
                ),
                _StatTile(
                  label: context.l10n.dashboardClientesInactivos,
                  value: '${stats.totalInactivos}',
                  icon: Icons.storefront_outlined,
                  color: _DashColors.rojo,
                ),
                _StatTile(
                  label: context.l10n.dashboardSedesTotal,
                  value: '${stats.totalSedes}',
                  icon: Icons.location_city_outlined,
                  color: _DashColors.azul,
                ),
                _StatTile(
                  label: context.l10n.dashboardPublicacionesTotal,
                  value: '${stats.totalPublicaciones}',
                  icon: Icons.campaign_outlined,
                  color: _DashColors.morado,
                ),
                _StatTile(
                  label: context.l10n.dashboardAvisosTotal,
                  value: '${stats.totalAvisos}',
                  icon: Icons.notifications_active_outlined,
                  color: _DashColors.naranja,
                ),
                _StatTile(
                  label: context.l10n.dashboardCondolenciasTotal,
                  value: '${stats.totalCondolencias}',
                  icon: Icons.volunteer_activism_outlined,
                  color: _DashColors.cian,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardClientesPorTipo,
              icon: Icons.pie_chart_outline,
              color: _DashColors.azul,
              child: stats.porTipo.isEmpty
                  ? Text(context.l10n.dashboardSinDatos)
                  : Column(
                      children: [
                        for (final entrada in stats.porTipo)
                          _BarraFila(
                            label: entrada.key,
                            value: entrada.value,
                            maxValue: stats.porTipo.first.value,
                            color: _DashColors.azul,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardPublicacionesPorMes,
              icon: Icons.show_chart,
              color: _DashColors.morado,
              child: _ConteoPorMesChart(
                datos: stats.publicacionesPorMes,
                color: _DashColors.morado,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardAvisosPorMes,
              icon: Icons.show_chart,
              color: _DashColors.naranja,
              child: _ConteoPorMesChart(
                datos: stats.avisosPorMes,
                color: _DashColors.naranja,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardAltasPorMes,
              icon: Icons.show_chart,
              color: _DashColors.verde,
              child: _ConteoPorMesChart(
                datos: stats.altasPorMes,
                color: _DashColors.verde,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardBajasPorMes,
              icon: Icons.show_chart,
              color: _DashColors.rojo,
              child: _ConteoPorMesChart(
                datos: stats.bajasPorMes,
                color: _DashColors.rojo,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardTopClientes,
              icon: Icons.emoji_events_outlined,
              color: _DashColors.amarillo,
              child: stats.topClientesPorPublicaciones.isEmpty
                  ? Text(context.l10n.dashboardSinDatos)
                  : Column(
                      children: [
                        for (final entrada in stats.topClientesPorPublicaciones)
                          _BarraFila(
                            label: entrada.key,
                            value: entrada.value,
                            maxValue:
                                stats.topClientesPorPublicaciones.first.value,
                            color: _DashColors.morado,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

class _UsuariosTab extends ConsumerWidget {
  const _UsuariosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(usuariosStatsProvider);
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatGrid(
              tiles: [
                _StatTile(
                  label: context.l10n.dashboardUsuariosActivos,
                  value: '${stats.totalActivos}',
                  icon: Icons.person_outline,
                  color: _DashColors.verde,
                ),
                _StatTile(
                  label: context.l10n.dashboardUsuariosInactivos,
                  value: '${stats.totalInactivos}',
                  icon: Icons.person_off_outlined,
                  color: _DashColors.rojo,
                ),
                _StatTile(
                  label: context.l10n.dashboardUsuariosConPush,
                  value: '${stats.totalConNotificacionesPush}',
                  icon: Icons.notifications_outlined,
                  color: _DashColors.cian,
                ),
                _StatTile(
                  label: context.l10n.dashboardSeguimientosTotal,
                  value: '${stats.totalSeguimientos}',
                  icon: Icons.favorite_border,
                  color: _DashColors.morado,
                ),
                _StatTile(
                  label: context.l10n.dashboardZonasSeguidasTotal,
                  value: '${stats.totalZonasSeguidas}',
                  icon: Icons.location_on_outlined,
                  color: _DashColors.naranja,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardUsuariosPorIdioma,
              icon: Icons.language,
              color: _DashColors.cian,
              child: stats.porIdioma.isEmpty
                  ? Text(context.l10n.dashboardSinDatos)
                  : Column(
                      children: [
                        for (final entrada in stats.porIdioma)
                          _BarraFila(
                            label: entrada.key,
                            value: entrada.value,
                            maxValue: stats.porIdioma.first.value,
                            color: _DashColors.cian,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardAltasPorMes,
              icon: Icons.show_chart,
              color: _DashColors.verde,
              child: _ConteoPorMesChart(
                datos: stats.altasPorMes,
                color: _DashColors.verde,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardBajasPorMes,
              icon: Icons.show_chart,
              color: _DashColors.rojo,
              child: _ConteoPorMesChart(
                datos: stats.bajasPorMes,
                color: _DashColors.rojo,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardTopConcellos,
              icon: Icons.map_outlined,
              color: _DashColors.naranja,
              child: stats.topConcellos.isEmpty
                  ? Text(context.l10n.dashboardSinDatos)
                  : Column(
                      children: [
                        for (final entrada in stats.topConcellos)
                          _BarraFila(
                            label: entrada.key,
                            value: entrada.value,
                            maxValue: stats.topConcellos.first.value,
                            color: _DashColors.naranja,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

class _IaTab extends ConsumerWidget {
  const _IaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(iaStatsProvider);
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: _DashColors.azul.withValues(alpha: 0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _DashColors.azul.withValues(alpha: 0.25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _DashColors.azul, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.dashboardIaAviso,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatGrid(
              tiles: [
                _StatTile(
                  label: context.l10n.dashboardIaPeticionesHoy,
                  value: '${stats.peticionesHoy}',
                  icon: Icons.today_outlined,
                  color: _DashColors.azul,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaCostoHoy,
                  value: _formatCosto(stats.costoHoy),
                  icon: Icons.attach_money,
                  color: _DashColors.verde,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaPeticionesMes,
                  value: '${stats.peticionesMes}',
                  icon: Icons.calendar_month_outlined,
                  color: _DashColors.azul,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaCostoMes,
                  value: _formatCosto(stats.costoMes),
                  icon: Icons.savings_outlined,
                  color: _DashColors.verde,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaPeticionesTotal,
                  value: '${stats.peticionesTotal}',
                  icon: Icons.bar_chart_outlined,
                  color: _DashColors.morado,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaCostoTotal,
                  value: _formatCosto(stats.costoTotal),
                  icon: Icons.account_balance_wallet_outlined,
                  color: _DashColors.naranja,
                ),
                _StatTile(
                  label: context.l10n.dashboardIaTasaExito,
                  value: '${(stats.tasaExito * 100).toStringAsFixed(0)}%',
                  icon: Icons.check_circle_outline,
                  color: _DashColors.cian,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardIaPeticionesPorDia,
              icon: Icons.show_chart,
              color: _DashColors.naranja,
              child: _ConteoPorDiaChart(
                datos: stats.peticionesPorDia,
                color: _DashColors.naranja,
              ),
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: context.l10n.dashboardIaUsoPorUsuario,
              icon: Icons.groups_outlined,
              color: _DashColors.morado,
              child: stats.usoPorUsuarioEsteMes.isEmpty
                  ? Text(context.l10n.dashboardSinDatos)
                  : _UsoPorUsuarioTabla(datos: stats.usoPorUsuarioEsteMes),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

class _UsoPorUsuarioTabla extends StatelessWidget {
  final List<IaUsoPorUsuario> datos;
  const _UsoPorUsuarioTabla({required this.datos});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          _DashColors.morado.withValues(alpha: 0.08),
        ),
        columns: [
          DataColumn(label: Text(context.l10n.dashboardIaColUsuario)),
          DataColumn(
            label: Text(context.l10n.dashboardIaColPeticiones),
            numeric: true,
          ),
          DataColumn(
            label: Text(context.l10n.dashboardIaColCosto),
            numeric: true,
          ),
        ],
        rows: datos
            .map(
              (fila) => DataRow(
                cells: [
                  DataCell(Text(fila.nombreUsuario)),
                  DataCell(Text('${fila.peticiones}')),
                  DataCell(
                    Text(
                      _formatCosto(fila.costoEstimado),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _DashColors.morado,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Rejilla responsive de tarjetas de estadística: 2 columnas en móvil, más en pantallas anchas
/// (como un dashboard de verdad, no una lista vertical de tarjetas a toda anchura).
class _StatGrid extends StatelessWidget {
  final List<Widget> tiles;
  const _StatGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = (constraints.maxWidth / 220).floor().clamp(2, 5);
        const espacio = 12.0;
        final ancho =
            (constraints.maxWidth - espacio * (columnas - 1)) / columnas;
        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: [
            for (final tile in tiles) SizedBox(width: ancho, child: tile),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
        ],
      ),
    );
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? contenido
          : InkWell(onTap: onTap, child: contenido),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color color;
  final Widget child;
  const _SeccionCard({
    required this.titulo,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

class _BarraFila extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  const _BarraFila({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraccion = maxValue == 0 ? 0.0 : value / maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraccion,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConteoPorMesChart extends StatelessWidget {
  final List<ConteoPorPeriodo> datos;
  final Color color;
  const _ConteoPorMesChart({required this.datos, required this.color});

  @override
  Widget build(BuildContext context) {
    return _BarChartGenerico(
      datos: datos,
      formatoEtiqueta: (fecha) => DateFormat('MM/yy').format(fecha),
      color: color,
    );
  }
}

class _ConteoPorDiaChart extends StatelessWidget {
  final List<ConteoPorPeriodo> datos;
  final Color color;
  const _ConteoPorDiaChart({required this.datos, required this.color});

  @override
  Widget build(BuildContext context) {
    return _BarChartGenerico(
      datos: datos,
      formatoEtiqueta: (fecha) => DateFormat('dd/MM').format(fecha),
      cadaCuantasEtiquetas: 5,
      color: color,
    );
  }
}

class _BarChartGenerico extends StatelessWidget {
  final List<ConteoPorPeriodo> datos;
  final String Function(DateTime) formatoEtiqueta;
  final Color color;
  final int cadaCuantasEtiquetas;
  const _BarChartGenerico({
    required this.datos,
    required this.formatoEtiqueta,
    required this.color,
    this.cadaCuantasEtiquetas = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (datos.every((d) => d.total == 0)) {
      return Text(context.l10n.dashboardSinDatos);
    }
    final maxValor = datos
        .map((d) => d.total)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = maxValor == 0 ? 1.0 : maxValor * 1.2;
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFE9ECEF), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => color,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    '${rod.toY.round()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= datos.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % cadaCuantasEtiquetas != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      formatoEtiqueta(datos[index].periodo),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < datos.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: datos[i].total.toDouble(),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [color.withValues(alpha: 0.55), color],
                    ),
                    width: cadaCuantasEtiquetas > 1 ? 6 : 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Refresco periódico en vez de Realtime de verdad: el resto de la app funciona igual (pedir y
// cachear, sin websockets), así que se mantiene el mismo patrón aquí; si algún día hiciera
// falta ver los cambios al instante, este es el sitio para pasar a una subscripción Realtime.
const _enVivoIntervaloRefresco = Duration(seconds: 20);

class _EnVivoTab extends ConsumerStatefulWidget {
  const _EnVivoTab();

  @override
  ConsumerState<_EnVivoTab> createState() => _EnVivoTabState();
}

class _EnVivoTabState extends ConsumerState<_EnVivoTab> {
  Timer? _timer;
  bool _mostrarListado = false;
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      _enVivoIntervaloRefresco,
      (_) => ref.invalidate(sesionesAbiertasProvider),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cerrar(SesionAbierta sesion) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.enVivoCerrarSesionTitulo,
      message: context.l10n.enVivoCerrarSesionMensaje(sesion.nombreUsuario),
      confirmLabel: context.l10n.enVivoCerrarSesionTitulo,
    );
    if (!confirmado) return;
    await ref
        .read(sesionesRepositoryProvider)
        .cerrarSesion(sesion.idSistemaSesion);
    ref.invalidate(sesionesAbiertasProvider);
  }

  List<SesionAbierta> _filtrar(List<SesionAbierta> sesiones) {
    final termino = _busquedaController.text.trim().toLowerCase();
    if (termino.isEmpty) return sesiones;
    return sesiones
        .where((s) => s.nombreUsuario.toLowerCase().contains(termino))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sesionesAsync = ref.watch(sesionesAbiertasProvider);
    return sesionesAsync.when(
      data: (sesiones) {
        final filtradas = _filtrar(sesiones);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatGrid(
                tiles: [
                  _StatTile(
                    label: context.l10n.enVivoConexionesAbiertas,
                    value: '${sesiones.length}',
                    icon: Icons.sensors,
                    color: _DashColors.verde,
                    onTap: () =>
                        setState(() => _mostrarListado = !_mostrarListado),
                  ),
                ],
              ),
              if (_mostrarListado) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    labelText: context.l10n.enVivoFiltrarPorCliente,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                if (sesiones.isEmpty)
                  EmptyState(
                    message: context.l10n.enVivoVacio,
                    icon: Icons.sensors_off_outlined,
                  )
                else if (filtradas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(context.l10n.enVivoSinCoincidencias),
                  )
                else
                  Column(
                    children: [
                      for (final sesion in filtradas) ...[
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.circle,
                              color: _DashColors.verde,
                              size: 14,
                            ),
                            title: Text(sesion.nombreUsuario),
                            subtitle: Text(
                              '${sesion.emailUsuario}\n'
                              '${sesion.nombreSede ?? context.l10n.enVivoSinSede} · '
                              '${context.l10n.enVivoUltimoAcceso(DateFormat('dd/MM HH:mm').format(sesion.fechaUltimoAcceso.toLocal()))}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.logout),
                              tooltip: context.l10n.enVivoCerrarSesionTitulo,
                              onPressed: () => _cerrar(sesion),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}
