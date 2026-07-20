import 'package:flutter/material.dart';

import 'provincia_siluetas.dart';

class ProvinciaShapeIcon extends StatelessWidget {
  final String provincia;
  final double size;
  final Color? color;

  const ProvinciaShapeIcon({super.key, required this.provincia, this.size = 48, this.color});

  static const _claves = {
    'a coruña': 'a_coruna',
    'a coruna': 'a_coruna',
    'lugo': 'lugo',
    'ourense': 'ourense',
    'pontevedra': 'pontevedra',
  };

  @override
  Widget build(BuildContext context) {
    final puntos = provinciaSiluetas[_claves[provincia.trim().toLowerCase()]];
    if (puntos == null) {
      return Icon(Icons.map_outlined, size: size, color: color);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProvinciaPainter(puntos: puntos, color: color ?? Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ProvinciaPainter extends CustomPainter {
  final List<List<double>> puntos;
  final Color color;
  const _ProvinciaPainter({required this.puntos, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i < puntos.length; i++) {
      final dx = puntos[i][0] / 100 * size.width;
      final dy = puntos[i][1] / 100 * size.height;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ProvinciaPainter oldDelegate) =>
      !identical(oldDelegate.puntos, puntos) || oldDelegate.color != color;
}
