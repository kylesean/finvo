import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/chat_input_provider.dart';
import 'media_upload_bottom_sheet.dart';

/// Media upload button component
/// Tapping shows a bottom sheet with multiple function options
class MediaUploadButton extends ConsumerWidget {
  final bool enabled;
  final ChatInputNotifierProvider chatInputProvider;

  const MediaUploadButton({
    super.key,
    this.enabled = true,
    required this.chatInputProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    // Consistent styling with the right-side button
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        // Use same muted background color as right-side button
        color: colors.muted,
        shape: BoxShape.circle,
        // No border
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () => _handleUploadButtonPressed(context, ref)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Icon(
              FLucideIcons.plus,
              size: 20,
              color: enabled ? colors.foreground : colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  /// Handle upload button press event
  void _handleUploadButtonPressed(BuildContext context, WidgetRef ref) {
    unawaited(
      MediaUploadBottomSheet.show(
        context,
        onFilesSelected: (files) {
          if (files.isNotEmpty) {
            final notifier = ref.read(chatInputProvider.notifier);
            notifier.addSelectedFiles(files);
          }
        },
      ),
    );
  }
}
