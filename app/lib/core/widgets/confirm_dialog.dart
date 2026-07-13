import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final resolvedConfirmLabel = confirmLabel ?? context.l10n.confirmDialogConfirm;
  final resolvedCancelLabel = cancelLabel ?? context.l10n.confirmDialogCancel;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(resolvedCancelLabel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(resolvedConfirmLabel)),
      ],
    ),
  );
  return result ?? false;
}
