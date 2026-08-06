import 'package:flutter/material.dart';

/// Vela sencilla dibujada a mano (mismo criterio que CruzIcon: geometría simple en vez de un
/// glifo de fuente), para las condolencias — no hay ningún icono de "vela" en el set de Material.
/// La llama lleva color propio (no sigue el color del texto/icono del contexto) para que se note
/// que es una vela encendida, no un simple icono monocromo.
class VelaIcon extends StatelessWidget {
  final double size;
  final Color? colorCuerpo;
  final Color? colorLlama;

  static const _llamaExterior = Color(0xFFE0932B);
  static const _llamaInterior = Color(0xFFFFD873);

  const VelaIcon({
    super.key,
    this.size = 20,
    this.colorCuerpo,
    this.colorLlama,
  });

  @override
  Widget build(BuildContext context) {
    final cuerpo = colorCuerpo ?? IconTheme.of(context).color ?? Colors.black;
    return CustomPaint(
      size: Size(size, size),
      painter: _VelaPainter(
        cuerpo: cuerpo,
        llama: colorLlama ?? _llamaExterior,
      ),
    );
  }
}

class _VelaPainter extends CustomPainter {
  final Color cuerpo;
  final Color llama;
  _VelaPainter({required this.cuerpo, required this.llama});

  Path _formaLlama(Size size, double escala) {
    final centerX = size.width / 2;
    final alto = size.height * 0.26 * escala;
    final ancho = size.width * 0.24 * escala;
    final base = size.height * 0.02 + (size.height * 0.26 - alto);
    final punta = base - alto;
    return Path()
      ..moveTo(centerX, punta)
      ..quadraticBezierTo(centerX + ancho, base - alto * 0.15, centerX, base)
      ..quadraticBezierTo(centerX - ancho, base - alto * 0.15, centerX, punta)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paintCuerpo = Paint()..color = cuerpo;

    final bodyWidth = size.width * 0.42;
    final bodyLeft = (size.width - bodyWidth) / 2;
    final bodyTop = size.height * 0.44;
    final bodyHeight = size.height * 0.56;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(bodyWidth * 0.2),
      ),
      paintCuerpo,
    );

    canvas.drawPath(_formaLlama(size, 1), Paint()..color = llama);
    canvas.drawPath(
      _formaLlama(size, 0.55),
      Paint()..color = VelaIcon._llamaInterior,
    );
  }

  @override
  bool shouldRepaint(covariant _VelaPainter oldDelegate) =>
      oldDelegate.cuerpo != cuerpo || oldDelegate.llama != llama;
}
