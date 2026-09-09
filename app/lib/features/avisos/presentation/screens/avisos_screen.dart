import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../../acto_tipos/data/acto_tipo.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';
import '../../../publicaciones/data/publicacion_con_sede.dart';
import '../../../publicaciones/data/publicaciones_repository.dart';
import '../../../publicaciones/presentation/widgets/publicacion_card.dart';
import '../../../recordatorios/application/recordatorios_providers.dart';
import '../../../recordatorios/data/recordatorio_publicacion.dart';
import '../../../recordatorios/data/recordatorios_repository.dart';
import '../../../recordatorios/presentation/widgets/recordatorio_modal.dart';
import '../../application/avisos_providers.dart';
import '../../data/aviso_recibido.dart';
import '../../data/avisos_repository.dart';

/// Título de una tarjeta de recordatorio (070): "Esquela" o el nombre del tipo de acto (p. ej.
/// "Misa de Cabo de Ano") en vez de un genérico "Recordatorio" — así se distingue de qué
/// publicación se trata de un vistazo, tanto en "Recibidos" como en el propio push.
String _tituloTipoPublicacion(
  BuildContext context,
  WidgetRef ref,
  PublicacionConSede? publicacion,
) {
  if (publicacion == null) return context.l10n.recordatorioRecibidoTitulo;
  if (!publicacion.esActo) return context.l10n.recordatorioTipoEsquela;
  final List<ActoTipo> actoTipos = ref
      .watch(actoTiposListProvider)
      .maybeWhen(data: (tipos) => tipos, orElse: () => const []);
  return nombreActoTipoDe(publicacion, actoTipos) ??
      context.l10n.publicarActoLabel;
}

/// Muestra solo esta publicación (no la lista entera de su sede) en un panel inferior, con la
/// misma tarjeta de siempre: usado tanto al tocar la notificación push de un recordatorio (070)
/// como al tocar su tarjeta dentro de "Recibidos", para que las dos vías se comporten igual.
Future<void> _mostrarPublicacionSuelta(
  BuildContext context,
  WidgetRef ref,
  String idClientePublicacion,
) async {
  final publicacion = await ref
      .read(publicacionesRepositoryProvider)
      .obtenerPorId(idClientePublicacion);
  if (!context.mounted || publicacion == null) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: PublicacionCard(publicacion: publicacion),
    ),
  );
}

class AvisosScreen extends ConsumerStatefulWidget {
  const AvisosScreen({super.key});

  @override
  ConsumerState<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends ConsumerState<AvisosScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this)
    ..addListener(_alCambiarPestana);
  final _seleccionados = <String>{};
  bool _seleccionando = false;
  bool _procesando = false;

  @override
  void dispose() {
    _tabController.removeListener(_alCambiarPestana);
    _tabController.dispose();
    super.dispose();
  }

  // Red de seguridad además del refresco por push (home_screen.dart): si por lo que sea el push
  // de un recordatorio no llegó a procesarse (notificaciones desactivadas, app recién abierta
  // sin pasar por la notificación...), al menos se refresca solo con volver a esta pestaña.
  void _alCambiarPestana() {
    if (_tabController.indexIsChanging) return;
    ref.invalidate(misRecordatoriosPendientesProvider);
    ref.invalidate(recordatoriosEnviadosProvider);
  }

  /// Al tocar la notificación de un recordatorio (070), HomeScreen deja aquí qué publicación
  /// abrir; se consume una sola vez y se muestra solo esa (no la lista entera de la sede).
  Future<void> _abrirPublicacionDeRecordatorio(
    RecordatorioTocado tocado,
  ) async {
    _tabController.animateTo(0);
    await ref
        .read(recordatoriosRepositoryProvider)
        .marcarLeido(tocado.idClientePublicacionRecordatorio);
    ref.invalidate(recordatoriosEnviadosProvider);
    ref.invalidate(recordatoriosNoLeidosCountProvider);
    // El badge de "Recordatorio" de la propia tarjeta (número de pendientes) cuenta este ya
    // enviado hasta que se refresque: al abrirlo aquí es buen momento para ponerlo al día.
    ref.invalidate(
      recordatoriosPendientesPorPublicacionProvider(
        tocado.idClientePublicacion,
      ),
    );
    if (!mounted) return;
    await _mostrarPublicacionSuelta(context, ref, tocado.idClientePublicacion);
  }

  void _iniciarSeleccion(String idInicial) {
    setState(() {
      _seleccionando = true;
      _seleccionados
        ..clear()
        ..add(idInicial);
    });
  }

  void _alternarSeleccion(String id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
  }

  void _cancelarSeleccion() {
    setState(() {
      _seleccionando = false;
      _seleccionados.clear();
    });
  }

  // Botón explícito para entrar en modo selección, además de poder mantener pulsada una
  // tarjeta: la app la usa gente mayor, y un gesto oculto (mantener pulsado) sin ningún botón
  // visible que lo explique no es fácil de descubrir por su cuenta.
  void _activarSeleccion() {
    setState(() => _seleccionando = true);
  }

  Future<void> _refrescarTrasBorrar() async {
    ref.invalidate(misAvisosRecibidosProvider);
    ref.invalidate(avisosNoLeidosCountProvider);
    ref.invalidate(recordatoriosEnviadosProvider);
    ref.invalidate(recordatoriosNoLeidosCountProvider);
  }

  Future<void> _eliminarUno(AvisoRecibido aviso) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarMensaje(aviso.titulo),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref
          .read(avisosRepositoryProvider)
          .eliminarAviso(aviso.idClienteAvisoDestinatario);
      await _refrescarTrasBorrar();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  /// La selección mezcla ids de dos tablas distintas (avisos y recordatorios ya enviados, 070):
  /// se reparten según a qué lista pertenece cada id ya cargado, y se borra cada grupo con su
  /// propio repositorio.
  Future<void> _eliminarSeleccionados() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarSeleccionadosMensaje(
        _seleccionados.length,
      ),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      final idsAvisos = ref
          .read(misAvisosRecibidosProvider)
          .items
          .map((a) => a.idClienteAvisoDestinatario)
          .where(_seleccionados.contains)
          .toList();
      final idsRecordatorios = ref
          .read(recordatoriosEnviadosProvider)
          .items
          .map((r) => r.idClientePublicacionRecordatorio)
          .where(_seleccionados.contains)
          .toList();
      await Future.wait([
        if (idsAvisos.isNotEmpty)
          ref.read(avisosRepositoryProvider).eliminarAvisos(idsAvisos),
        if (idsRecordatorios.isNotEmpty)
          ref
              .read(recordatoriosRepositoryProvider)
              .eliminarVarios(idsRecordatorios),
      ]);
      await _refrescarTrasBorrar();
      _cancelarSeleccion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _vaciarTodo() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosVaciarTodoTitulo,
      message: context.l10n.avisosVaciarTodoMensaje,
      confirmLabel: context.l10n.avisosVaciarTodoTitulo,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await Future.wait([
        ref.read(avisosRepositoryProvider).eliminarTodosAvisos(),
        ref.read(recordatoriosRepositoryProvider).eliminarTodosEnviados(),
      ]);
      await _refrescarTrasBorrar();
      _cancelarSeleccion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _eliminarRecordatorioEnviado(
    RecordatorioPublicacion recordatorio,
  ) async {
    await ref
        .read(recordatoriosRepositoryProvider)
        .eliminar(recordatorio.idClientePublicacionRecordatorio);
    ref.invalidate(recordatoriosEnviadosProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(recordatorioNotificacionTocadaProvider, (previous, next) {
      if (next == null) return;
      ref.read(recordatorioNotificacionTocadaProvider.notifier).consumir();
      _abrirPublicacionDeRecordatorio(next);
    });
    return Column(
      children: [
        // El TabBarThemeData global pinta las pestañas en blanco (pensado para ir sobre una
        // barra oscura, como el AppBar del Panel de Datos): sin este fondo negro quedaría texto
        // blanco sobre el blanco del cuerpo de la pantalla, ilegible.
        Container(
          color: AppColors.black,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: context.l10n.avisosTabRecibidos),
              Tab(text: context.l10n.avisosTabRecordatorios),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildRecibidos(context), _buildRecordatorios(context)],
          ),
        ),
      ],
    );
  }

  Widget _buildRecibidos(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    // Un ADMIN también puede seguir clientes como cualquier usuario ordinario, así que esta
    // pestaña le muestra las dos cosas: sus solicitudes de cliente pendientes de aprobar (si
    // las hay) Y su propia bandeja de avisos recibidos, no una cosa en vez de la otra.
    final pendientesSolicitudes = isAdmin
        ? ref.watch(solicitudesPendientesCountProvider).value ?? 0
        : 0;
    final resultado = ref.watch(misAvisosRecibidosProvider);
    final recordatoriosEnviados = ref.watch(recordatoriosEnviadosProvider);

    if (resultado.cargandoInicial || recordatoriosEnviados.cargandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (resultado.error != null) {
      return Center(
        child: Text(context.l10n.errorGenerico(resultado.error.toString())),
      );
    }
    final hayRecordatorios = recordatoriosEnviados.items.isNotEmpty;
    final hayAlgoQueGestionar = resultado.items.isNotEmpty || hayRecordatorios;
    if (pendientesSolicitudes == 0 && !hayAlgoQueGestionar) {
      return EmptyState(
        message: context.l10n.avisosVacioRecibidos,
        icon: Icons.notifications_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pendientesSolicitudes > 0) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.assignment_late_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  context.l10n.avisoSolicitudesPendientes(
                    pendientesSolicitudes,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/solicitudes'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // La selección/borrado es una única barra para las dos listas de abajo (avisos y
          // recordatorios ya enviados), así que se muestra si hay algo en cualquiera de las dos,
          // no solo cuando hay avisos.
          if (hayAlgoQueGestionar) ...[
            if (_seleccionando)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.avisosNSeleccionados(_seleccionados.length),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _procesando ? null : _cancelarSeleccion,
                          child: Text(context.l10n.avisosCancelarSeleccion),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: Text(context.l10n.eliminar),
                          onPressed: _procesando || _seleccionados.isEmpty
                              ? null
                              : _eliminarSeleccionados,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.checklist),
                      label: Text(context.l10n.avisosSeleccionar),
                      onPressed: _procesando ? null : _activarSeleccion,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(context.l10n.avisosVaciarTodoTitulo),
                      onPressed: _procesando ? null : _vaciarTodo,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
          ],
          // Recordatorios (070) ya disparados: sección aparte y sin scroll infinito propio (a
          // diferencia de los avisos de abajo) porque en la práctica son pocos — no compensa la
          // complejidad de paginar dos listas independientes dentro del mismo scroll.
          if (hayRecordatorios) ...[
            Text(
              context.l10n.recordatorioRecibidoSeccion,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final recordatorio in recordatoriosEnviados.items)
              _RecordatorioRecibidoCard(
                recordatorio: recordatorio,
                seleccionando: _seleccionando,
                seleccionado: _seleccionados.contains(
                  recordatorio.idClientePublicacionRecordatorio,
                ),
                onIniciarSeleccion: () => _iniciarSeleccion(
                  recordatorio.idClientePublicacionRecordatorio,
                ),
                onAlternarSeleccion: () => _alternarSeleccion(
                  recordatorio.idClientePublicacionRecordatorio,
                ),
                onEliminar: () => _eliminarRecordatorioEnviado(recordatorio),
              ),
            const SizedBox(height: 16),
          ],
          if (resultado.items.isNotEmpty)
            Expanded(
              child: PaginatedListView<AvisoRecibido>(
                items: resultado.items,
                cargandoMas: resultado.cargandoMas,
                hasMore: resultado.hasMore,
                onCargarMas: () =>
                    ref.read(misAvisosRecibidosProvider.notifier).cargarMas(),
                itemBuilder: (context, aviso) => _AvisoRecibidoCard(
                  aviso: aviso,
                  seleccionando: _seleccionando,
                  seleccionado: _seleccionados.contains(
                    aviso.idClienteAvisoDestinatario,
                  ),
                  onIniciarSeleccion: () =>
                      _iniciarSeleccion(aviso.idClienteAvisoDestinatario),
                  onAlternarSeleccion: () =>
                      _alternarSeleccion(aviso.idClienteAvisoDestinatario),
                  onEliminar: () => _eliminarUno(aviso),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordatorios(BuildContext context) {
    final recordatoriosAsync = ref.watch(misRecordatoriosPendientesProvider);
    return recordatoriosAsync.when(
      data: (recordatorios) {
        if (recordatorios.isEmpty) {
          return EmptyState(
            message: context.l10n.recordatorioListaVacia,
            icon: Icons.alarm_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final recordatorio in recordatorios)
              _RecordatorioPendienteCard(
                recordatorio: recordatorio,
                onEditado: () =>
                    ref.invalidate(misRecordatoriosPendientesProvider),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

class _RecordatorioPendienteCard extends ConsumerWidget {
  final RecordatorioPublicacion recordatorio;
  final VoidCallback onEditado;

  const _RecordatorioPendienteCard({
    required this.recordatorio,
    required this.onEditado,
  });

  Future<void> _editar(BuildContext context) async {
    final evento = recordatorio.publicacion?.fechaHoraEvento;
    if (evento == null) return;
    await mostrarRecordatorioModal(
      context,
      idClientePublicacion: recordatorio.idClientePublicacion,
      fechaHoraEvento: evento,
    );
    onEditado();
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.recordatorioEliminarTitulo,
      message: context.l10n.recordatorioEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref
        .read(recordatoriosRepositoryProvider)
        .eliminar(recordatorio.idClientePublicacionRecordatorio);
    onEditado();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicacion = recordatorio.publicacion;
    final titulo = _tituloTipoPublicacion(context, ref, publicacion);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.alarm_outlined),
        title: Text(titulo),
        subtitle: Text(
          '${publicacion?.nombreFallecido ?? ''} · '
          '${context.l10n.recordatorioProgramadoPara(DateFormat('dd/MM/yyyy HH:mm').format(recordatorio.fechaHoraRecordatorio))}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.editar,
              onPressed: () => _editar(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.eliminar,
              onPressed: () => _eliminar(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordatorioRecibidoCard extends ConsumerWidget {
  final RecordatorioPublicacion recordatorio;
  final bool seleccionando;
  final bool seleccionado;
  final VoidCallback onIniciarSeleccion;
  final VoidCallback onAlternarSeleccion;
  final VoidCallback onEliminar;

  const _RecordatorioRecibidoCard({
    required this.recordatorio,
    required this.seleccionando,
    required this.seleccionado,
    required this.onIniciarSeleccion,
    required this.onAlternarSeleccion,
    required this.onEliminar,
  });

  Future<void> _abrir(BuildContext context, WidgetRef ref) async {
    if (!recordatorio.leido) {
      await ref
          .read(recordatoriosRepositoryProvider)
          .marcarLeido(recordatorio.idClientePublicacionRecordatorio);
      ref.invalidate(recordatoriosEnviadosProvider);
      ref.invalidate(recordatoriosNoLeidosCountProvider);
      // Mismo motivo que en "_abrirPublicacionDeRecordatorio": el badge de la tarjeta de la
      // publicación cuenta pendientes, y este ya está enviado.
      ref.invalidate(
        recordatoriosPendientesPorPublicacionProvider(
          recordatorio.idClientePublicacion,
        ),
      );
    }
    if (!context.mounted) return;
    await _mostrarPublicacionSuelta(
      context,
      ref,
      recordatorio.idClientePublicacion,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titulo = _tituloTipoPublicacion(
      context,
      ref,
      recordatorio.publicacion,
    );
    final nombreFallecido = recordatorio.publicacion?.nombreFallecido ?? '';
    return _TarjetaAviso(
      leido: recordatorio.leido,
      icono: Icons.notifications_outlined,
      titulo: titulo,
      subtitulo: nombreFallecido,
      seleccionando: seleccionando,
      seleccionado: seleccionado,
      onAlternarSeleccion: onAlternarSeleccion,
      onIniciarSeleccion: onIniciarSeleccion,
      onEliminar: onEliminar,
      onTap: () => _abrir(context, ref),
    );
  }
}

class _AvisoRecibidoCard extends ConsumerWidget {
  final AvisoRecibido aviso;
  final bool seleccionando;
  final bool seleccionado;
  final VoidCallback onIniciarSeleccion;
  final VoidCallback onAlternarSeleccion;
  final VoidCallback onEliminar;

  const _AvisoRecibidoCard({
    required this.aviso,
    required this.seleccionando,
    required this.seleccionado,
    required this.onIniciarSeleccion,
    required this.onAlternarSeleccion,
    required this.onEliminar,
  });

  Future<void> _abrir(BuildContext context, WidgetRef ref) async {
    if (!aviso.leido) {
      await ref
          .read(avisosRepositoryProvider)
          .marcarLeido(aviso.idClienteAvisoDestinatario);
      ref.invalidate(avisosNoLeidosCountProvider);
      ref.invalidate(misAvisosRecibidosProvider);
    }
    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (_) => _AvisoDetailDialog(aviso: aviso),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TarjetaAviso(
      leido: aviso.leido,
      icono: Icons.mail_outline,
      titulo: aviso.titulo,
      subtitulo:
          '${aviso.nombreCliente} · '
          '${DateFormat('dd/MM/yyyy HH:mm').format(aviso.fechaAlta.toLocal())}',
      seleccionando: seleccionando,
      seleccionado: seleccionado,
      onAlternarSeleccion: onAlternarSeleccion,
      onIniciarSeleccion: onIniciarSeleccion,
      onEliminar: onEliminar,
      onTap: () => _abrir(context, ref),
    );
  }
}

/// Tarjeta compartida por avisos y recordatorios recibidos: mismo tratamiento visual para
/// distinguir de un vistazo lo leído de lo no leído -fondo y borde de color, icono en un
/// círculo de color, texto en negrita- en vez de una diferencia sutil difícil de notar.
class _TarjetaAviso extends StatelessWidget {
  final bool leido;
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool seleccionando;
  final bool seleccionado;
  final VoidCallback onAlternarSeleccion;
  final VoidCallback onIniciarSeleccion;
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const _TarjetaAviso({
    required this.leido,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionando,
    required this.seleccionado,
    required this.onAlternarSeleccion,
    required this.onIniciarSeleccion,
    required this.onEliminar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: leido ? null : AppColors.plumLight.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: leido
            ? BorderSide.none
            : const BorderSide(color: AppColors.plum, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: seleccionando
            ? Checkbox(
                value: seleccionado,
                onChanged: (_) => onAlternarSeleccion(),
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: leido ? AppColors.grayLight : AppColors.plum,
                child: Icon(
                  icono,
                  size: 20,
                  color: leido ? AppColors.gray : AppColors.white,
                ),
              ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: leido ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitulo),
        trailing: seleccionando
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.l10n.eliminar,
                onPressed: onEliminar,
              ),
        onTap: seleccionando ? onAlternarSeleccion : onTap,
        onLongPress: seleccionando ? null : onIniciarSeleccion,
      ),
    );
  }
}

class _AvisoDetailDialog extends StatelessWidget {
  final AvisoRecibido aviso;
  const _AvisoDetailDialog({required this.aviso});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(aviso.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${aviso.nombreCliente} · ${aviso.nombreSede}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Text(aviso.texto),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.avisosCerrar),
        ),
      ],
    );
  }
}
