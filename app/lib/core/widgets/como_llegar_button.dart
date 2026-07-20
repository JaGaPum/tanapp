import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';
import '../utils/maps_launcher.dart';

class ComoLlegarButton extends StatelessWidget {
  final String direccion;
  final String? concello;
  final String? provincia;
  final String? label;

  const ComoLlegarButton({super.key, required this.direccion, this.concello, this.provincia, this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.directions_outlined),
      label: Text(label ?? context.l10n.comoLlegar),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () => abrirIndicacionesGoogleMaps(direccion: direccion, concello: concello, provincia: provincia),
    );
  }
}
