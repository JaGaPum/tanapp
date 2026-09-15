import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../data/periodo_gratuito.dart';

/// Fila de un periodo gratuito dentro de una lista (080), con editar y borrar. Se usa tanto para
/// los generales como para los propios de un cliente.
class PeriodoGratuitoTile extends StatelessWidget {
  final PeriodoGratuito periodo;
  final VoidCallback onEditar;
  final Future<void> Function() onEliminar;

  const PeriodoGratuitoTile({
    super.key,
    required this.periodo,
    required this.onEditar,
    required this.onEliminar,
  });

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.periodoGratuitoEliminarTitulo,
      message: context.l10n.periodoGratuitoEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (confirmado) await onEliminar();
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');
    final rango = periodo.fin != null
        ? '${formato.format(periodo.inicio)} — ${formato.format(periodo.fin!)}'
        : '${formato.format(periodo.inicio)} — ${context.l10n.periodoGratuitoIndefinido}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.card_giftcard_outlined,
        color: periodo.activo
            ? AppColors.green
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(rango),
      subtitle: periodo.activo
          ? Text(
              context.l10n.periodoGratuitoActivo,
              style: TextStyle(color: AppColors.green),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: context.l10n.editar,
            onPressed: onEditar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: context.l10n.eliminar,
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
    );
  }
}
