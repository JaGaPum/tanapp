import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

/// Checklist en vivo bajo un campo de contraseña nueva: se actualiza con cada pulsación
/// (escucha directamente el [controller], sin necesidad de un StatefulWidget propio) para que
/// se vea de un vistazo si ya cumple el formato antes de intentar enviar el formulario.
class PasswordRequirements extends StatelessWidget {
  final TextEditingController controller;
  final bool estricta;

  const PasswordRequirements({
    super.key,
    required this.controller,
    this.estricta = false,
  });

  @override
  Widget build(BuildContext context) {
    final minimo = estricta
        ? Validators.passwordEstrictaMinimo
        : Validators.passwordBasicoMinimo;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final texto = value.text;
        final cumpleLongitud = texto.length >= minimo;
        final cumpleLetraYNumero =
            RegExp(r'[A-Za-z]').hasMatch(texto) &&
            RegExp(r'[0-9]').hasMatch(texto);
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Requisito(
                cumplido: cumpleLongitud,
                texto: context.l10n.passwordRequisitoLongitud(minimo),
              ),
              if (estricta) ...[
                const SizedBox(height: 2),
                _Requisito(
                  cumplido: cumpleLetraYNumero,
                  texto: context.l10n.passwordRequisitoLetraNumero,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Requisito extends StatelessWidget {
  final bool cumplido;
  final String texto;
  const _Requisito({required this.cumplido, required this.texto});

  @override
  Widget build(BuildContext context) {
    final color = cumplido
        ? AppColors.green
        : Theme.of(context).colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          cumplido ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
