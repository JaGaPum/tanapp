import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/pago_suscripcion.dart';

/// Fila de un pago dentro del historial (083). [onEliminar] es opcional: en "Mi suscripción" del
/// propio cliente no se puede borrar (es de solo lectura), solo en la ficha del ADMIN.
class PagoSuscripcionTile extends StatelessWidget {
  final PagoSuscripcion pago;
  final Future<void> Function()? onEliminar;

  const PagoSuscripcionTile({super.key, required this.pago, this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.payments_outlined,
        color: pago.vigente
            ? AppColors.green
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(
        context.l10n.pagoFechaYCobertura(
          formato.format(pago.fechaPago),
          formato.format(pago.fechaFinCobertura),
        ),
      ),
      subtitle: pago.vigente
          ? Text(
              context.l10n.pagoVigente,
              style: TextStyle(color: AppColors.green),
            )
          : null,
      trailing: onEliminar == null
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: context.l10n.eliminar,
              onPressed: onEliminar,
            ),
    );
  }
}
