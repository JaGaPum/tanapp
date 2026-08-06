import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Avatar de un cliente: su foto si tiene, si no las iniciales de su nombre (primera letra
/// de las dos primeras palabras, o las dos primeras letras si el nombre es de una sola).
///
/// No se usa el `backgroundImage` de [CircleAvatar] porque recorta siempre a [BoxFit.cover]
/// (sin forma de cambiarlo): con logos que no son cuadrados (un monograma con el nombre debajo,
/// por ejemplo) eso corta texto del logo. Aquí se ve el logo completo, con [BoxFit.contain].
class ClienteAvatar extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final double radius;

  const ClienteAvatar({
    super.key,
    required this.nombre,
    this.fotoUrl,
    this.radius = 28,
  });

  static String _iniciales(String nombre) {
    final palabras = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (palabras.isEmpty) return '?';
    if (palabras.length == 1) {
      final p = palabras.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (palabras[0][0] + palabras[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diametro = radius * 2;
    return ClipOval(
      child: Container(
        width: diametro,
        height: diametro,
        color: AppColors.black,
        alignment: Alignment.center,
        child: fotoUrl != null
            ? Image.network(
                fotoUrl!,
                width: diametro,
                height: diametro,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _Iniciales(nombre: nombre, radius: radius),
              )
            : _Iniciales(nombre: nombre, radius: radius),
      ),
    );
  }
}

class _Iniciales extends StatelessWidget {
  final String nombre;
  final double radius;
  const _Iniciales({required this.nombre, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Text(
      ClienteAvatar._iniciales(nombre),
      style: TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
        fontSize: radius * 0.6,
      ),
    );
  }
}
