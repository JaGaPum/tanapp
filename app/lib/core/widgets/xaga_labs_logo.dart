import 'package:flutter/material.dart';

/// Wordmark de Xaga Labs reconstruido con widgets.
class XagaLabsLogo extends StatelessWidget {
  final bool dark;
  const XagaLabsLogo({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'xaga',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: dark ? Colors.white : Colors.black,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.code, color: dark ? Colors.blue.shade300 : Colors.blue.shade700, size: 20),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'LABS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.grey.shade400 : Colors.grey.shade600,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
