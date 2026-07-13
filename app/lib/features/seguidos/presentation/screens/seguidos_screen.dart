import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';

class SeguidosScreen extends StatelessWidget {
  const SeguidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(message: context.l10n.proximamente, icon: Icons.people_outline);
  }
}
