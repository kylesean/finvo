// features/home/widgets/feed/attachment_section_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays attachments linked to a transaction via its AI conversation thread.
///
/// Horizontal scrollable list of attachment cards:
/// - Images: rounded thumbnail (72x72), tap for full-screen preview
/// - Documents: file icon + truncated filename
/// - Empty state: entire section is hidden
class AttachmentSectionWidget extends ConsumerWidget {
  final List<TransactionAttachment> attachments;

  const AttachmentSectionWidget({super.key, required this.attachments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final colors = theme.colors;
    final baseUrl = ref.read(apiConstantsProvider).baseUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                FLucideIcons.paperclip,
                size: 14,
                color: colors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                t.transaction.attachments(count: attachments.length.toString()),
                style: AppTextStyles.sectionHeader(theme),
              ),
            ],
          ),
        ),

        // Horizontal scrollable attachment cards
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              if (attachment.isImage) {
                return _buildImageCard(context, baseUrl, attachment, colors);
              }
              return _buildDocumentCard(context, theme, colors, attachment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    String baseUrl,
    TransactionAttachment attachment,
    FColors colors,
  ) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        _showFullScreenImage(context, baseUrl, attachment);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Image.network(
            '$baseUrl${attachment.url}',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: colors.muted,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: colors.muted,
                child: Icon(
                  FLucideIcons.imageOff,
                  color: colors.mutedForeground,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    TransactionAttachment attachment,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(attachment.mimeType),
            size: 20,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 6),
          Text(
            attachment.filename,
            style: AppTextStyles.detailLabel(theme),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String baseUrl,
    TransactionAttachment attachment,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: InteractiveViewer(
                child: Image.network(
                  '$baseUrl${attachment.url}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return FLucideIcons.file;
    if (mimeType.contains('pdf')) return FLucideIcons.fileText;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return FLucideIcons.sheet;
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return FLucideIcons.fileText;
    }
    return FLucideIcons.file;
  }
}
