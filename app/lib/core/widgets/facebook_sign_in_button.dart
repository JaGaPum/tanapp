import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

/// Botón "Continuar/Regístrate con Facebook" siguiendo el azul de marca (#1877F2) y la "f"
/// blanca: mismo patrón que [GoogleSignInButton], solo que aquí el fondo ya lleva el color de
/// marca (Facebook no usa un botón neutro como Google), así que la "f" va sin círculo aparte.
class FacebookSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const FacebookSignInButton({super.key, required this.onPressed, this.label});

  static const _azulFacebook = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: _azulFacebook,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const SizedBox(height: 20, width: 20, child: _FacebookLogo()),
        label: Text(
          label ?? context.l10n.facebookContinuar,
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

class _FacebookLogo extends StatelessWidget {
  const _FacebookLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FacebookLogoPainter());
  }
}

class _FacebookLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.95,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
