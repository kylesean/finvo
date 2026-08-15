import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'dart:async';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/utils/error_message.dart';

import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/features/home/providers/comment_providers.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';

import 'package:finvo/shared/models/action_item_model.dart';
import 'package:finvo/shared/widgets/dialogs/action_bottom_sheet.dart';

/// Current logged-in user's ID (from auth state)
final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.id ?? '';
});

class CommentItemWidget extends ConsumerWidget {
  final CommentModel comment;
  final String transactionId;
  final bool isHighlighted;
  final String? parentAuthorId;
  final String? parentAuthorName;
  final String? recorderUserId;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.transactionId,
    this.isHighlighted = false,
    this.parentAuthorId,
    this.parentAuthorName,
    this.recorderUserId,
  });

  void _triggerReply(WidgetRef ref, String commentId, String userName) {
    final currentReplyingTo = ref.read(replyingToCommentIdProvider);
    if (currentReplyingTo == commentId) {
      ref.read(replyingToCommentIdProvider.notifier).set(null);
      ref.read(replyingToUserNameProvider.notifier).set(null);
      ref.read(replyingToUserIdProvider.notifier).set(null);
    } else {
      ref.read(replyingToCommentIdProvider.notifier).set(commentId);
      ref.read(replyingToUserNameProvider.notifier).set(userName);
      ref.read(replyingToUserIdProvider.notifier).set(comment.userId);
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showConfirmDialog(
      context: context,
      title: t.comment.confirmDeleteTitle,
      message: t.comment.confirmDeleteContent,
      cancelLabel: t.common.cancel,
      confirmVariant: FButtonVariant.destructive,
      confirmLabel: t.common.delete,
      onConfirm: () async {
        try {
          await ref
              .read(transactionCommentsProvider(transactionId).notifier)
              .deleteComment(comment.id);
          if (!context.mounted) return;
          TopToast.success(context, t.comment.commentDeleted);
        } catch (e) {
          if (!context.mounted) return;
          TopToast.error(
            context,
            safeErrorMessage(e, fallback: t.comment.deleteFailed),
          );
        }
      },
    );
  }

  void _showCommentActions(BuildContext context, WidgetRef ref) {
    // ref.read (not ref.watch): reading inside a callback is not a build
    // context, and Riverpod 3 forbids watch outside build.
    final String currentLoggedInUserId = ref.read(currentUserIdProvider);
    final bool canDelete = comment.userId == currentLoggedInUserId;

    final List<ActionItem> primaryActions = [
      ActionItem(
        title: t.comment.copyContent,
        icon: FLucideIcons.copy,
        onTap: () {
          unawaited(
            Clipboard.setData(ClipboardData(text: comment.commentText)),
          );
          TopToast.success(context, t.comment.contentCopied);
        },
      ),
    ];

    final List<ActionItem> destructiveActions = [];
    if (canDelete) {
      destructiveActions.add(
        ActionItem(
          title: t.comment.deleteComment,
          icon: FLucideIcons.trash2,
          onTap: () {
            unawaited(_showDeleteConfirmDialog(context, ref));
          },
        ),
      );
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) {
          return ActionBottomSheet(
            actions: primaryActions,
            destructiveActions: destructiveActions.isNotEmpty
                ? destructiveActions
                : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    final bool isSubComment = comment.parentCommentId != null;
    final String currentLoggedInUserId = ref.watch(currentUserIdProvider);
    final bool isSelf = comment.userId == currentLoggedInUserId;

    // Build username display, including interactive reply target
    // Names and the ">" separator stay muted so the comment content stands
    // out; the reply target remains tappable.
    final TextStyle mutedNameStyle = AppTextStyles.listTrailing(
      theme,
    ).copyWith(color: colorScheme.mutedForeground, fontWeight: FontWeight.w500);

    Widget buildUserNameDisplay() {
      final List<Widget> nameParts = [
        Text(comment.userName, style: mutedNameStyle),
      ];

      // Add "记录人" / "Author" badge tag for transaction owner/recorder
      final bool isRecorder =
          recorderUserId != null && comment.userId == recorderUserId;
      if (isRecorder) {
        nameParts.addAll([
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Text(
              t.comment.recordedBy,
              style: theme.typography.body.xs.copyWith(
                color: colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]);
      }

      // Social media comment display rules (Xiaohongshu / Bilibili standard):
      // 1. Never show self-reply (A ▶ A).
      // 2. Tapping 1st-level root comment has no repliedToUserName -> renders cleanly without ▶.
      // 3. Tapping a 2nd-level sub-comment item persists repliedToUserName -> ALWAYS renders "▶ TargetName".
      final bool isSelfReply = comment.repliedToUserId != null
          ? comment.repliedToUserId == comment.userId
          : comment.repliedToUserName == comment.userName;

      final bool shouldShowReplyTarget =
          isSubComment &&
          comment.repliedToUserName != null &&
          comment.repliedToUserName!.isNotEmpty &&
          !isSelfReply;

      if (shouldShowReplyTarget) {
        nameParts.addAll([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              FLucideIcons.chevronRight,
              size: 12,
              color: colorScheme.mutedForeground.withValues(alpha: 0.8),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                _triggerReply(ref, comment.id, comment.repliedToUserName!);
              },
              child: Text(
                comment.repliedToUserName!,
                style: mutedNameStyle.copyWith(
                  color: colorScheme.mutedForeground.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ]);
      }
      return Row(mainAxisSize: MainAxisSize.min, children: nameParts);
    }

    return GestureDetector(
      onTap: () {
        if (isSelf) {
          _showCommentActions(context, ref);
        } else {
          _triggerReply(ref, comment.id, comment.userName);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          color: isHighlighted
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.only(
          left: isSubComment ? 28.0 : 4.0,
          right: 4.0,
          top: isSubComment ? 4.0 : 8.0,
          bottom: 4.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(userId: comment.userId, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: buildUserNameDisplay()),
                      const SizedBox(width: 6),
                      Text(
                        relativeTime(comment.createdAt),
                        style: theme.typography.body.xs.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                      if (!isSelf) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _triggerReply(ref, comment.id, comment.userName);
                          },
                          child: Text(
                            t.comment.reply,
                            style: theme.typography.body.xs.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (isSelf) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showCommentActions(context, ref),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            child: Icon(
                              FLucideIcons.ellipsis,
                              color: colorScheme.mutedForeground,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  _buildFormattedCommentText(
                    context,
                    comment.commentText,
                    theme,
                    colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedCommentText(
    BuildContext context,
    String text,
    FThemeData theme,
    FColors colorScheme,
  ) {
    final baseStyle = theme.typography.body.sm.copyWith(
      color: colorScheme.foreground,
      height: 1.3,
    );
    final mentionStyle = baseStyle.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    final regex = RegExp(r'(@[^\s@]+)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        final precedingText = text.substring(lastMatchEnd, match.start);
        spans.add(TextSpan(text: precedingText));
        if (precedingText.isNotEmpty && !precedingText.endsWith(' ')) {
          spans.add(const TextSpan(text: ' '));
        }
      }
      final mentionTag = match.group(0)!;
      final username = mentionTag.startsWith('@')
          ? mentionTag.substring(1)
          : mentionTag;

      spans.add(
        TextSpan(
          text: mentionTag,
          style: mentionStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              unawaited(HapticFeedback.lightImpact());
              TopToast.info(context, t.comment.userToast(username: username));
            },
        ),
      );
      lastMatchEnd = match.end;

      if (lastMatchEnd < text.length &&
          !text.substring(lastMatchEnd).startsWith(' ')) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}
