// features/home/widgets/feed/attachment_section_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays attachments linked to a transaction via its AI conversation thread.
///
/// - Images: thumbnail grid, tap for full-screen preview
/// - Documents: file icon + filename + size
/// - Empty state: entire section is hidden
class AttachmentSectionWidget extends ConsumerWidget {
  final List<TransactionAttachment> attachments;
  final String? sourceThreadId;

  const AttachmentSectionWidget({
    super.key,
    required this.attachments,
    this.sourceThreadId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final colors = theme.colors;
    final baseUrl = ref.read(apiConstantsProvider).baseUrl;

    final images = attachments.where((a) => a.isImage).toList();
    final documents = attachments.where((a) => !a.isImage).toList();

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

        // Image grid
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final attachment = images[index];
              return GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  _showFullScreenImage(context, baseUrl, attachment);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$baseUrl${attachment.url}',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: colors.muted,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

        // Document list
        if (documents.isNotEmpty) ...[
          if (images.isNotEmpty) const SizedBox(height: 8),
          ...documents.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getFileIcon(doc.mimeType),
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doc.filename,
                      style: AppTextStyles.listSubtitle(theme),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (doc.size != null)
                    Text(
                      _formatFileSize(doc.size!),
                      style: AppTextStyles.detailLabel(theme),
                    ),
                ],
              ),
            ),
          ),
        ],

        // Link to source conversation
        if (sourceThreadId != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                context.go('/ai/$sourceThreadId');
              },
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.externalLink,
                    size: 12,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.transaction.viewInConversation,
                    style: AppTextStyles.actionText(theme),
                  ),
                ],
              ),
            ),
          ),
      ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
