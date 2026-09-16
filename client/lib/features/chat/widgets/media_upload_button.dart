import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';

import 'package:finvo/features/chat/providers/chat_input_provider.dart';
import 'package:finvo/features/chat/widgets/media_upload_bottom_sheet.dart';

/// Media upload button component
/// Tapping shows a bottom sheet with multiple function options
class MediaUploadButton extends ConsumerWidget {
  final bool enabled;

  const MediaUploadButton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    // Accessible touch target (48x48) wrapping the 40x40 circle button
    return Semantics(
      button: true,
      label: t.media.addFiles,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.muted,
              shape: BoxShape.circle,
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
