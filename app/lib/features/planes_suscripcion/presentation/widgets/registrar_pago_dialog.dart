import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_banner.dart';

/// Registrar un pago (083): solo pide la fecha en la que se pagó (por defecto hoy, pero se puede
/// elegir otra para anotar un pago recibido unos días antes). "Hasta cuándo cubre" lo calcula
/// siempre la base de datos (fechaPago + 30 días), no se pide aquí.
class RegistrarPagoDialog extends StatefulWidget {
  final Future<void> Function({required DateTime fechaPago}) onGuardar;

  const RegistrarPagoDialog({super.key, required this.onGuardar});

  @override
  State<RegistrarPagoDialog> createState() => _RegistrarPagoDialogState();
}

class _RegistrarPagoDialogState extends State<RegistrarPagoDialog> {
  DateTime _fechaPago = DateTime.now();
  bool _loading = false;
  String? _error;

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if (elegida != null) setState(() => _fechaPago = elegida);
  }

  Future<void> _guardar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onGuardar(fechaPago: _fechaPago);
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
      title: Text(context.l10n.pagoRegistrar),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ErrorBanner(message: _error!),
          InkWell(
            onTap: _elegirFecha,
            child: InputDecorator(
              decoration: InputDecoration(labelText: context.l10n.pagoFecha),
              child: Text(DateFormat('dd/MM/yyyy').format(_fechaPago)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.pagoCubre30Dias,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
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
