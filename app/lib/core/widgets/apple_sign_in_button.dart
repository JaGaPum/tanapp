import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

/// Botón "Continuar/Regístrate con Apple" siguiendo la guía de marca de Apple (fondo negro,
/// icono y texto blancos): mismo patrón que [GoogleSignInButton]/[FacebookSignInButton].
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const AppleSignInButton({super.key, required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.apple, size: 22),
        label: Text(
          label ?? context.l10n.appleContinuar,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
