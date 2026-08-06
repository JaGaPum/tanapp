import 'package:flutter/material.dart';

/// Etiqueta pequeña (fondo tintado + texto del mismo color), pensada para datos cortos que
/// acompañan a un título (p.ej. la sede de un cliente, o un estado). Mismo aspecto en toda la
/// app para que una etiqueta se reconozca como tal de un vistazo, la use quien la use.
class EtiquetaChip extends StatelessWidget {
  final String texto;
  final IconData? icon;
  final Color? color;

  const EtiquetaChip({super.key, required this.texto, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final colorBase = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorBase.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colorBase),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorBase,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
