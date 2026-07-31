import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../avisos/application/avisos_providers.dart';
import '../../../avisos/data/aviso_estadistica.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../publicaciones/data/publicaciones_por_mes.dart';
import '../../../seguidos/application/seguidos_providers.dart';
import '../../../seguidos/data/seguidores_resumen.dart';

class PanelDatosScreen extends ConsumerWidget {
  const PanelDatosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sedesAsync = ref.watch(misSedesProvider);
    final publicacionesAsync = ref.watch(misPublicacionesProvider);
    final publicacionesPorMesAsync = ref.watch(publicacionesPorMesProvider);
    final seguidoresAsync = ref.watch(misSeguidoresPorSedeProvider);
    final avisosAsync = ref.watch(avisosEstadisticasProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SeccionCard(
            icon: Icons.campaign_outlined,
            titulo: context.l10n.panelDatosPublicaciones,
            child: sedesAsync.when(
              data: (sedes) => publicacionesAsync.when(
                data: (publicaciones) {
                  final porSede = {for (final sede in sedes) sede.idClienteSede: 0};
                  for (final publicacion in publicaciones) {
                    porSede[publicacion.idClienteSede] = (porSede[publicacion.idClienteSede] ?? 0) + 1;
                  }
                  final maxCount = porSede.values.isEmpty ? 0 : porSede.values.reduce((a, b) => a > b ? a : b);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${publicaciones.length}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      for (final sede in sedes)
                        _BarraFila(
                          label: '${sede.codigo} · ${sede.nombre}',
                          value: porSede[sede.idClienteSede] ?? 0,
                          maxValue: maxCount,
                        ),
                      const SizedBox(height: 20),
                      Text(context.l10n.panelDatosPublicacionesPorMes, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      publicacionesPorMesAsync.when(
                        data: (porMes) => _PublicacionesPorMesChart(datos: porMes),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ),
          const SizedBox(height: 16),
          _SeccionCard(
            icon: Icons.favorite_border,
            titulo: context.l10n.panelDatosSeguidores,
            child: seguidoresAsync.when(
              data: (porSede) => _SeguidoresContenido(porSede: porSede),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ),
          const SizedBox(height: 16),
          _SeccionCard(
            icon: Icons.notifications_outlined,
            titulo: context.l10n.panelDatosAvisos,
            child: avisosAsync.when(
              data: (avisos) => avisos.isEmpty
                  ? Text(context.l10n.panelDatosAvisosVacio, style: Theme.of(context).textTheme.bodyMedium)
                  : _AvisosChart(datos: avisos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeguidoresContenido extends StatelessWidget {
  final List<SeguidoresPorSede> porSede;
  const _SeguidoresContenido({required this.porSede});

  @override
  Widget build(BuildContext context) {
    final total = porSede.fold<int>(0, (suma, sede) => suma + sede.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$total',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        for (final sede in porSede) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${sede.codigoSede} · ${sede.nombreSede}',
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${sede.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (sede.porConcello.isEmpty) ...[
            const SizedBox(height: 4),
            Text(context.l10n.panelDatosSinSeguidores, style: Theme.of(context).textTheme.bodyMedium),
          ] else ...[
            const SizedBox(height: 8),
            for (final entrada in sede.porConcello)
              _BarraFila(
                label: entrada.key.isEmpty ? context.l10n.panelDatosConcelloDesconocido : entrada.key,
                value: entrada.value,
                maxValue: sede.porConcello.first.value,
              ),
          ],
        ],
      ],
    );
  }
}

/// Publicaciones creadas por mes en los últimos meses: una sola serie, así que un único color
/// basta (sin leyenda: el título de la sección ya dice qué es).
class _PublicacionesPorMesChart extends StatelessWidget {
  final List<PublicacionesPorMes> datos;
  const _PublicacionesPorMesChart({required this.datos});

  @override
  Widget build(BuildContext context) {
    final maxValor = datos.map((d) => d.total).fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = maxValor == 0 ? 1.0 : maxValor * 1.2;
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.round()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= datos.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MM/yy').format(datos[index].mes),
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
                    color: AppColors.black,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Recibidos vs leídos de los últimos avisos enviados: dos segmentos por barra (leído = verde,
/// pendiente = el mismo tono neutro que ya usa el resto de la app para "relleno pendiente" en
/// _BarraFila), con leyenda porque hay dos series.
class _AvisosChart extends StatelessWidget {
  final List<AvisoEstadistica> datos;
  const _AvisosChart({required this.datos});

  @override
  Widget build(BuildContext context) {
    // datos llega del más reciente al más antiguo; se invierte para leer el gráfico de
    // izquierda (más antiguo) a derecha (más reciente), como el de publicaciones por mes.
    final ordenados = datos.reversed.toList();
    final maxValor = ordenados.map((d) => d.recibidos).fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = maxValor == 0 ? 1.0 : maxValor * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= ordenados.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('dd/MM').format(ordenados[index].fechaAlta.toLocal()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final aviso = ordenados[group.x];
                    return BarTooltipItem(
                      '${aviso.titulo}\n${aviso.leidos}/${aviso.recibidos}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < ordenados.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: ordenados[i].recibidos.toDouble(),
                        width: 18,
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        rodStackItems: [
                          BarChartRodStackItem(0, ordenados[i].leidos.toDouble(), AppColors.green),
                          BarChartRodStackItem(
                            ordenados[i].leidos.toDouble(),
                            ordenados[i].recibidos.toDouble(),
                            AppColors.brownLight,
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LeyendaPunto(color: AppColors.green, label: context.l10n.panelDatosAvisosLeidos),
            const SizedBox(width: 16),
            _LeyendaPunto(color: AppColors.brownLight, label: context.l10n.panelDatosAvisosPendientes),
          ],
        ),
      ],
    );
  }
}

class _LeyendaPunto extends StatelessWidget {
  final Color color;
  final String label;
  const _LeyendaPunto({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Widget child;

  const _SeccionCard({required this.icon, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(titulo, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _BarraFila extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const _BarraFila({required this.label, required this.value, required this.maxValue});

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
              Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraccion,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
