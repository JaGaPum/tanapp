import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/periodo_gratuito.dart';

/// Alta/edición de un periodo gratuito (080): "Inicio" es obligatorio, "Fin" es opcional (en
/// blanco = indefinido para este periodo). Se usa tanto para los periodos generales como para
/// los propios de un cliente; [onGuardar] hace el insert/update real, distinto en cada caso.
class PeriodoGratuitoFormDialog extends StatefulWidget {
  final PeriodoGratuito? periodo;
  final Future<void> Function({required DateTime inicio, DateTime? fin})
  onGuardar;

  const PeriodoGratuitoFormDialog({
    super.key,
    this.periodo,
    required this.onGuardar,
  });

  @override
  State<PeriodoGratuitoFormDialog> createState() =>
      _PeriodoGratuitoFormDialogState();
}

class _PeriodoGratuitoFormDialogState extends State<PeriodoGratuitoFormDialog> {
  late DateTime? _inicio = widget.periodo?.inicio;
  late DateTime? _fin = widget.periodo?.fin;
  bool _loading = false;
  String? _error;

  Future<void> _elegirInicio() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _inicio ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (elegida == null || !mounted) return;
    setState(() {
      _inicio = elegida;
      // Si ya había un "fin" anterior a la nueva fecha de inicio, ya no tiene sentido.
      if (_fin != null && _fin!.isBefore(elegida)) _fin = null;
    });
  }

  Future<void> _elegirFin() async {
    if (_inicio == null) return;
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fin ?? _inicio!,
      firstDate: _inicio!,
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (elegida != null) setState(() => _fin = elegida);
  }

  Future<void> _guardar() async {
    if (_inicio == null) {
      setState(() => _error = context.l10n.periodoGratuitoInicioObligatorio);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onGuardar(inicio: _inicio!, fin: _fin);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(
        () => _error = e is AppException
            ? e.message
            : context.l10n.errorInesperado,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.periodo == null
            ? context.l10n.periodoGratuitoNuevo
            : context.l10n.periodoGratuitoEditar,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ErrorBanner(message: _error!),
          InkWell(
            onTap: _elegirInicio,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.l10n.periodoGratuitoInicio,
              ),
              child: Text(
                _inicio != null
                    ? DateFormat('dd/MM/yyyy').format(_inicio!)
                    : '',
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _inicio == null ? null : _elegirFin,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.l10n.periodoGratuitoFin,
                suffixIcon: _fin != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _fin = null),
                      )
                    : null,
              ),
              child: Text(
                _fin != null
                    ? DateFormat('dd/MM/yyyy').format(_fin!)
                    : context.l10n.periodoGratuitoIndefinido,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.confirmDialogCancel),
        ),
        AppButton(
          label: context.l10n.guardar,
          loading: _loading,
          onPressed: _guardar,
        ),
      ],
    );
  }
}
