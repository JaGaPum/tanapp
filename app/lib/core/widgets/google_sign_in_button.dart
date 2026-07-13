import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const GoogleSignInButton({super.key, required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: Text(label ?? context.l10n.googleContinuar),
        onPressed: onPressed,
      ),
    );
  }
}
