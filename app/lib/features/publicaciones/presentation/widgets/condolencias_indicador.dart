import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/vela_icon.dart';

/// Vela + número de condolencias en una franja pequeña (una sola línea), pulsable para abrir la
/// vista previa de condolencias en un modal sin salir de la lista. Solo se muestra si ya hay
/// alguna.
class CondolenciasIndicador extends StatelessWidget {
  final int numCondolencias;
  final VoidCallback? onTap;
  const CondolenciasIndicador({
    super.key,
    required this.numCondolencias,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (numCondolencias <= 0) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VelaIcon(size: 16, colorCuerpo: Colors.white),
              const SizedBox(width: 5),
              Text(
                context.l10n.condolenciasCantidad(numCondolencias),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
