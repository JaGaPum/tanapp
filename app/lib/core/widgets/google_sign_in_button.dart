import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

/// Botón "Continuar/Regístrate con Google" siguiendo las guías de marca de Google (fondo
/// blanco, borde gris, logo "G" a cuatro colores): para que se identifique de un vistazo como
/// login de Google y no como un botón genérico más.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const GoogleSignInButton({super.key, required this.onPressed, this.label});

  static const _grisBorde = Color(0xFF747775);
  static const _grisTexto = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _grisTexto,
          side: const BorderSide(color: _grisBorde),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const SizedBox(height: 20, width: 20, child: _GoogleLogo()),
        label: Text(
          label ?? context.l10n.googleContinuar,
          style: const TextStyle(
            color: _grisTexto,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radio = size.width / 2;
    final centro = Offset(radio, radio);
    final rect = Rect.fromCircle(center: centro, radius: radio);

    void arco(double inicioGrados, double barridoGrados, Color color) {
      canvas.drawArc(
        rect,
        inicioGrados * 3.1415926535 / 180,
        barridoGrados * 3.1415926535 / 180,
        true,
        Paint()..color = color,
      );
    }

    // Los cuatro colores de marca de Google, repartidos en el mismo orden que el logo real
    // (azul a la derecha, verde abajo, amarillo abajo-izquierda, rojo arriba-izquierda).
    arco(-10, 100, const Color(0xFF4285F4));
    arco(90, 60, const Color(0xFF34A853));
    arco(150, 90, const Color(0xFFFBBC05));
    arco(240, 110, const Color(0xFFEA4335));

    // Hueco blanco en el centro para que quede como un anillo...
    canvas.drawCircle(centro, radio * 0.55, Paint()..color = Colors.white);
    // ...y la barra horizontal azul característica de la "G", con su hueco a la derecha.
    canvas.drawRect(
      Rect.fromLTWH(
        centro.dx - radio * 0.05,
        centro.dy - radio * 0.14,
        radio * 0.95,
        radio * 0.28,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
