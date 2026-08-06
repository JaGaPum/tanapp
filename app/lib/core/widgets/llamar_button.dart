import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/phone_launcher.dart';

class LlamarButton extends StatelessWidget {
  final String telefono;
  final String? label;
  final bool secondary;

  const LlamarButton({
    super.key,
    required this.telefono,
    this.label,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed() => llamarTelefono(telefono);
    final texto = Text(label ?? context.l10n.llamar);
    const icono = Icon(Icons.call_outlined);

    if (secondary) {
      return OutlinedButton.icon(
        icon: icono,
        label: texto,
        onPressed: onPressed,
      );
    }
    return FilledButton.icon(
      icon: icono,
      label: texto,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }
}
