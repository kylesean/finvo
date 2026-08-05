import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'dart:async';

/// Shows a standardized confirmation dialog with title, message,
/// cancel and confirm buttons.
///
/// Closes the dialog before invoking [onConfirm]. Returns a [Future<bool>]
/// resolving to `true` when the user confirmed, `false` otherwise.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  Future<void> Function()? onConfirm,
  String? confirmLabel,
  String? cancelLabel,
  FButtonVariant confirmVariant = FButtonVariant.destructive,
}) async {
  final confirmed = await showFDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext, style, animation) => FDialog(
      animation: animation,
      builder: (context, dialogStyle) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: dialogStyle.titleTextStyle),
            const SizedBox(height: 12),
            Text(message, style: dialogStyle.bodyTextStyle),
            const SizedBox(height: 24),
            FButton(
              variant: .outline,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel ?? 'Cancel'),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: confirmVariant,
              onPress: () async {
                Navigator.of(dialogContext).pop(true);
                await onConfirm?.call();
              },
              child: Text(confirmLabel ?? 'Confirm'),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}
