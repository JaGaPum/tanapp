import 'package:flutter/material.dart';

/// Tarjeta grande de selección (icono + texto grande), pensada para un público con poca
/// destreza táctil: área de toque amplia, sin gestos ni menús ocultos.
class BigChoiceCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const BigChoiceCard({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
