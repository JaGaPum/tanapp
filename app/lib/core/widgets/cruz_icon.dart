import 'package:flutter/material.dart';

/// Cruz sencilla dibujada a mano, siempre negra: se usa junto al nombre del fallecido en las
/// esquelas. No se usa el carácter Unicode "✝" porque algunos móviles lo pintan de color
/// (el emoji de Noto Color Emoji sale morado) en vez de negro.
class CruzIcon extends StatelessWidget {
  final double size;
  const CruzIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _CruzPainter());
  }
}

class _CruzPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final barW = size.width * 0.18;

    canvas.drawRect(Rect.fromLTWH((size.width - barW) / 2, 0, barW, size.height), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.12, size.height * 0.22, size.width * 0.76, barW), paint);
  }

  @override
  bool shouldRepaint(covariant _CruzPainter oldDelegate) => false;
}
