import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/maps_launcher.dart';

class ComoLlegarButton extends StatelessWidget {
  final String direccion;
  final String? concello;
  final String? provincia;
  final String? label;
  final bool secondary;

  const ComoLlegarButton({
    super.key,
    required this.direccion,
    this.concello,
    this.provincia,
    this.label,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed() => abrirIndicacionesGoogleMaps(
      direccion: direccion,
      concello: concello,
      provincia: provincia,
    );
    final texto = Text(label ?? context.l10n.comoLlegar);
    const icono = Icon(Icons.directions_outlined);

    if (secondary) {
      return OutlinedButton.icon(
        icon: icono,
        label: texto,
        onPressed: onPressed,
      );
    }
    return FilledButton.icon(
      icon: icono,
      label: texto,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }
}
