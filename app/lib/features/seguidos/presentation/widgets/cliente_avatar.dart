import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Avatar de un cliente: su foto si tiene, si no las iniciales de su nombre (primera letra
/// de las dos primeras palabras, o las dos primeras letras si el nombre es de una sola).
class ClienteAvatar extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final double radius;

  const ClienteAvatar({super.key, required this.nombre, this.fotoUrl, this.radius = 28});

  static String _iniciales(String nombre) {
    final palabras = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (palabras.isEmpty) return '?';
    if (palabras.length == 1) {
      final p = palabras.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (palabras[0][0] + palabras[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.black,
      backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
      child: fotoUrl == null
          ? Text(
              _iniciales(nombre),
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: radius * 0.6),
            )
          : null,
    );
  }
}
