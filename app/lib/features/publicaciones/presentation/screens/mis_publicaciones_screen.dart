import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicacion_con_sede.dart';
import '../../data/publicacion_programada.dart';
import '../../data/publicaciones_repository.dart';
import '../widgets/publicacion_card.dart';

const _intervaloActualizacion = Duration(seconds: 30);

/// Refresca sola cada [_intervaloActualizacion] (y al volver de segundo plano), igual que
/// "TablonScreen": sin esto, una publicación/programada que el cron (056) acaba de mover de
/// "Programadas" a real no se reflejaría aquí hasta salir y volver a entrar a la pantalla.
class MisPublicacionesScreen extends ConsumerStatefulWidget {
  const MisPublicacionesScreen({super.key});

  @override
  ConsumerState<MisPublicacionesScreen> createState() =>
      _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState extends ConsumerState<MisPublicacionesScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_intervaloActualizacion, (_) => _refrescar());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refrescar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refrescar() {
    ref.invalidate(misPublicacionesProvider);
    ref.invalidate(misPublicacionesProgramadasProvider);
  }

  @override
  Widget build(BuildContext context) {
    final publicacionesAsync = ref.watch(misPublicacionesProvider);
    final programadasAsync = ref.watch(misPublicacionesProgramadasProvider);

    return publicacionesAsync.when(
      data: (publicaciones) {
        final programadas = programadasAsync.maybeWhen(
          data: (data) => data,
          orElse: () => const <PublicacionProgramada>[],
        );
        if (publicaciones.isEmpty && programadas.isEmpty) {
          return EmptyState(
            message: context.l10n.publicarSinPublicaciones,
            icon: Icons.campaign_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (programadas.isNotEmpty) ...[
              Text(
                context.l10n.publicarProgramadasTitulo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final programada in programadas) ...[
                _PublicacionProgramadaCard(publicacion: programada),
                const SizedBox(height: 8),
              ],
              if (publicaciones.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.publicarPublicadasTitulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
              ],
            ],
            for (final publicacion in publicaciones) ...[
              _MiPublicacionCard(publicacion: publicacion),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.errorGenerico(e.toString()))),
    );
  }
}

/// Tarjeta ligera para una publicación aún en la "cola" (055): no es una esquela real todavía
/// (no la ve nadie salvo su dueño), así que no reutiliza [PublicacionCard].
class _PublicacionProgramadaCard extends ConsumerStatefulWidget {
  final PublicacionProgramada publicacion;
  const _PublicacionProgramadaCard({required this.publicacion});

  @override
  ConsumerState<_PublicacionProgramadaCard> createState() =>
      _PublicacionProgramadaCardState();
}

class _PublicacionProgramadaCardState
    extends ConsumerState<_PublicacionProgramadaCard> {
  bool _eliminando = false;

  Future<void> _editar() async {
    final publicacion = widget.publicacion;
    await context.push(
      '/publicar/manual',
      extra: {
        'idClientePublicacionProgramada':
            publicacion.idClientePublicacionProgramada,
        'idClienteSede': publicacion.idClienteSede,
        'nombre': publicacion.nombreFallecido,
        'fechaFallecimiento': publicacion.fechaFallecimiento?.toIso8601String(),
        'edad': publicacion.edad?.toString(),
        'fechaFuneral': publicacion.fechaFuneral?.toIso8601String(),
        'horaFuneral': publicacion.horaFuneral,
        'iglesia': publicacion.iglesia,
        'lugar': publicacion.lugar,
        'capillaArdiente': publicacion.capillaArdiente,
        'sala': publicacion.sala,
        'observaciones': publicacion.observaciones,
        'fechaProgramada': publicacion.fechaProgramada.toIso8601String(),
        'tipo': publicacion.tipo,
        'idConfiguracionActoTipo': publicacion.idConfiguracionActoTipo,
        'actoTipoOtro': publicacion.actoTipoOtro,
      },
    );
  }

  Future<void> _cancelar() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.publicarCancelarProgramadaTitulo,
      message: context.l10n.publicarCancelarProgramadaMensaje(
        widget.publicacion.nombreFallecido,
      ),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _eliminando = true);
    try {
      await ref
          .read(publicacionesRepositoryProvider)
          .eliminarPublicacionProgramada(
            widget.publicacion.idClientePublicacionProgramada,
          );
      ref.invalidate(misPublicacionesProgramadasProvider);
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicacion = widget.publicacion;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.nombreFallecido,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.publicarProgramadaPara(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(publicacion.fechaProgramada.toLocal()),
                      DateFormat(
                        'HH:mm',
                      ).format(publicacion.fechaProgramada.toLocal()),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${publicacion.codigoSede} · ${publicacion.nombreSede}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (_eliminando)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.editar,
                onPressed: _editar,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.l10n.eliminar,
                onPressed: _cancelar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Delega todo el aspecto visual en [PublicacionCard] (con [PublicacionCard.esPropia]): esta
/// clase solo aporta las acciones propias del dueño (editar/eliminar) y su estado de carga.
class _MiPublicacionCard extends ConsumerStatefulWidget {
  final PublicacionConSede publicacion;
  const _MiPublicacionCard({required this.publicacion});

  @override
  ConsumerState<_MiPublicacionCard> createState() => _MiPublicacionCardState();
}

class _MiPublicacionCardState extends ConsumerState<_MiPublicacionCard> {
  bool _eliminando = false;

  Future<void> _editar() async {
    final publicacion = widget.publicacion;
    await context.push(
      '/publicar/manual',
      extra: {
        'idClientePublicacion': publicacion.idClientePublicacion,
        'idClienteSede': publicacion.idClienteSede,
        'nombre': publicacion.nombreFallecido,
        'fechaFallecimiento': publicacion.fechaFallecimiento?.toIso8601String(),
        'edad': publicacion.edad?.toString(),
        'fechaFuneral': publicacion.fechaFuneral?.toIso8601String(),
        'horaFuneral': publicacion.horaFuneral,
        'iglesia': publicacion.iglesia,
        'lugar': publicacion.lugar,
        'capillaArdiente': publicacion.capillaArdiente,
        'sala': publicacion.sala,
        'observaciones': publicacion.observaciones,
        'tipo': publicacion.tipo,
        'idConfiguracionActoTipo': publicacion.idConfiguracionActoTipo,
        'actoTipoOtro': publicacion.actoTipoOtro,
      },
    );
  }

  Future<void> _eliminar() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.publicarEliminarTitulo,
      message: context.l10n.publicarEliminarMensaje(
        widget.publicacion.nombreFallecido,
      ),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _eliminando = true);
    try {
      await ref
          .read(publicacionesRepositoryProvider)
          .eliminarPublicacion(widget.publicacion.idClientePublicacion);
      ref.invalidate(misPublicacionesProvider);
      ref.invalidate(publicacionesTablonProvider);
      ref.invalidate(
        publicacionesPorSedeProvider(widget.publicacion.idClienteSede),
      );
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PublicacionCard(
      publicacion: widget.publicacion,
      esPropia: true,
      eliminando: _eliminando,
      onEditar: _editar,
      onEliminar: _eliminar,
    );
  }
}
