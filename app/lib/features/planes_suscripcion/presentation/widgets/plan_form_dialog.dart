import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../application/planes_suscripcion_providers.dart';
import '../../data/plan_suscripcion.dart';
import '../../data/planes_suscripcion_repository.dart';

/// Edición de un plan fijo (075): solo precio y máximo de sedes, nunca el nombre -los tres
/// planes (Local/Multisede/Gran Grupo) no se crean ni se borran desde la app-.
class PlanFormDialog extends ConsumerStatefulWidget {
  final PlanSuscripcion plan;
  const PlanFormDialog({super.key, required this.plan});

  @override
  ConsumerState<PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends ConsumerState<PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _precioController = TextEditingController(
    text: widget.plan.precioMensual.toStringAsFixed(2),
  );
  late final _maxSedesController = TextEditingController(
    text: widget.plan.maxSedes.toString(),
  );
  late final _maxEscaneosIaController = TextEditingController(
    text: widget.plan.maxEscaneosIaPorDia?.toString() ?? '',
  );
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _precioController.dispose();
    _maxSedesController.dispose();
    _maxEscaneosIaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final precio = double.parse(_precioController.text.replaceAll(',', '.'));
      final maxSedes = int.parse(_maxSedesController.text);
      final maxEscaneosTexto = _maxEscaneosIaController.text.trim();
      final maxEscaneosIa = maxEscaneosTexto.isEmpty
          ? null
          : int.parse(maxEscaneosTexto);
      await ref
          .read(planesSuscripcionRepositoryProvider)
          .actualizarPlan(
            idConfiguracionPlanSuscripcion:
                widget.plan.idConfiguracionPlanSuscripcion,
            precioMensual: precio,
            maxSedes: maxSedes,
            maxEscaneosIaPorDia: maxEscaneosIa,
          );
      ref.invalidate(planesSuscripcionListProvider);
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
      title: Text(widget.plan.nombre),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _precioController,
              label: context.l10n.planesPrecioMensual,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final valor = double.tryParse(
                  (v ?? '').trim().replaceAll(',', '.'),
                );
                return (valor == null || valor <= 0)
                    ? context.l10n.planesPrecioInvalido
                    : null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _maxSedesController,
              label: context.l10n.planesMaxSedes,
              keyboardType: TextInputType.number,
              validator: (v) {
                final valor = int.tryParse((v ?? '').trim());
                return (valor == null || valor <= 0)
                    ? context.l10n.planesMaxSedesInvalido
                    : null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _maxEscaneosIaController,
              label: context.l10n.planesMaxEscaneosIa,
              hint: context.l10n.planesMaxEscaneosIaSinLimite,
              keyboardType: TextInputType.number,
              validator: (v) {
                final texto = (v ?? '').trim();
                if (texto.isEmpty) return null;
                final valor = int.tryParse(texto);
                return (valor == null || valor <= 0)
                    ? context.l10n.planesMaxEscaneosIaInvalido
                    : null;
              },
            ),
          ],
        ),
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
