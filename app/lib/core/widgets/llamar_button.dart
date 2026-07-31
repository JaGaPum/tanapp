import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/phone_launcher.dart';

class LlamarButton extends StatelessWidget {
  final String telefono;
  final String? label;

  const LlamarButton({super.key, required this.telefono, this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.call_outlined),
      label: Text(label ?? context.l10n.llamar),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () => llamarTelefono(telefono),
    );
  }
}
