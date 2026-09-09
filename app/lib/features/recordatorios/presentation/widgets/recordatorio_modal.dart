import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/recordatorios_providers.dart';
import '../../data/recordatorio_publicacion.dart';
import '../../data/recordatorios_repository.dart';

/// Diálogo de "configurar recordatorio" de una publicación (070): hasta 2 por usuario, cada uno
/// con su propia fecha/hora, editable/eliminable, siempre anterior a [fechaHoraEvento].
Future<void> mostrarRecordatorioModal(
  BuildContext context, {
  required String idClientePublicacion,
  required DateTime fechaHoraEvento,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _RecordatorioModal(
      idClientePublicacion: idClientePublicacion,
      fechaHoraEvento: fechaHoraEvento,
    ),
  );
}

class _RecordatorioModal extends ConsumerStatefulWidget {
  final String idClientePublicacion;
  final DateTime fechaHoraEvento;
  const _RecordatorioModal({
    required this.idClientePublicacion,
    required this.fechaHoraEvento,
  });

  @override
  ConsumerState<_RecordatorioModal> createState() => _RecordatorioModalState();
}

class _RecordatorioModalState extends ConsumerState<_RecordatorioModal> {
  bool _guardando = false;

  void _refrescar() {
    ref.invalidate(
      recordatoriosPendientesPorPublicacionProvider(
        widget.idClientePublicacion,
      ),
    );
    // "Mis recordatorios" (pestaña de Avisos) es una lista aparte, con su propio fetch: sin esto
    // seguiría enseñando lo que había antes de crear/editar/eliminar desde aquí.
    ref.invalidate(misRecordatoriosPendientesProvider);
  }

  /// Pide fecha y luego hora (dos pasos, mismo patrón que el resto de la app), acotadas entre
  /// ahora y el evento; devuelve null si el usuario cancela cualquiera de los dos pasos.
  Future<DateTime?> _elegirFechaHora(DateTime? inicial) async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial ?? ahora,
      firstDate: ahora,
      lastDate: widget.fechaHoraEvento,
    );
    if (fecha == null || !mounted) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: inicial != null
          ? TimeOfDay.fromDateTime(inicial)
          : TimeOfDay.now(),
    );
    if (hora == null) return null;
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  bool _fechaValida(DateTime elegida) {
    return elegida.isAfter(DateTime.now()) &&
        elegida.isBefore(widget.fechaHoraEvento);
  }

  Future<void> _anadir() async {
    final elegida = await _elegirFechaHora(null);
    if (elegida == null || !mounted) return;
    if (!_fechaValida(elegida)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordatorioFechaInvalida)),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      final idSistemaUsuario = ref
          .read(currentUserProfileProvider)
          .value
          ?.idSistemaUsuario;
      if (idSistemaUsuario == null) return;
      await ref
          .read(recordatoriosRepositoryProvider)
          .crear(
            idSistemaUsuario: idSistemaUsuario,
            idClientePublicacion: widget.idClientePublicacion,
            fechaHoraRecordatorio: elegida,
          );
      _refrescar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _editar(RecordatorioPublicacion recordatorio) async {
    final elegida = await _elegirFechaHora(recordatorio.fechaHoraRecordatorio);
    if (elegida == null || !mounted) return;
    if (!_fechaValida(elegida)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordatorioFechaInvalida)),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref
          .read(recordatoriosRepositoryProvider)
          .actualizar(
            idClientePublicacionRecordatorio:
                recordatorio.idClientePublicacionRecordatorio,
            fechaHoraRecordatorio: elegida,
          );
      _refrescar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminar(RecordatorioPublicacion recordatorio) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.recordatorioEliminarTitulo,
      message: context.l10n.recordatorioEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(recordatoriosRepositoryProvider)
          .eliminar(recordatorio.idClientePublicacionRecordatorio);
      _refrescar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordatoriosAsync = ref.watch(
      recordatoriosPendientesPorPublicacionProvider(
        widget.idClientePublicacion,
      ),
    );
    // "viewInsets.bottom" cubre el teclado; "padding.bottom" cubre la barra de gestos/navegación
    // del propio móvil -sin esto, el botón de "añadir" quedaba tapado detrás de ella-. No hace
    // falta sumar los dos: nunca están presentes los dos a la vez con el mismo peso (el teclado
    // ya empuja el propio "viewInsets.bottom" por encima de esa barra).
    final margenInferior = math.max(
      MediaQuery.of(context).viewInsets.bottom,
      MediaQuery.of(context).padding.bottom,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + margenInferior),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.recordatorioModalTitulo,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          recordatoriosAsync.when(
            data: (recordatorios) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (recordatorios.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(context.l10n.recordatorioVacio),
                    )
                  else
                    for (final recordatorio in recordatorios)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.alarm_outlined),
                          title: Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(recordatorio.fechaHoraRecordatorio),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: context.l10n.editar,
                                onPressed: _guardando
                                    ? null
                                    : () => _editar(recordatorio),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: context.l10n.eliminar,
                                onPressed: _guardando
                                    ? null
                                    : () => _eliminar(recordatorio),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                  if (recordatorios.length < 2)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_alarm_outlined),
                      label: Text(context.l10n.recordatorioAnadir),
                      onPressed: _guardando ? null : _anadir,
                    )
                  else
                    Text(
                      context.l10n.recordatorioMaximoAlcanzado,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
          ),
        ],
      ),
    );
  }
}
