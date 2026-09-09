import 'package:flutter/material.dart';

/// Cruz sencilla dibujada a mano, negra por defecto: se usa junto al nombre del fallecido en las
/// esquelas. No se usa el carácter Unicode "✝" porque algunos móviles lo pintan de color
/// (el emoji de Noto Color Emoji sale morado) en vez de negro. [color] es configurable para
/// cuando hace falta en blanco (p. ej. dentro del sello de la tarjeta, sobre fondo negro).
class CruzIcon extends StatelessWidget {
  final double size;
  final Color color;
  const CruzIcon({super.key, this.size = 20, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CruzPainter(color: color),
    );
  }
}

class _CruzPainter extends CustomPainter {
  final Color color;
  const _CruzPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final barW = size.width * 0.18;

    canvas.drawRect(
      Rect.fromLTWH((size.width - barW) / 2, 0, barW, size.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.22,
        size.width * 0.76,
        barW,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CruzPainter oldDelegate) =>
      color != oldDelegate.color;
}
