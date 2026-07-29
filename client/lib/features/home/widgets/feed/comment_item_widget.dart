import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';

import '../../models/comment_model.dart';
import '../../providers/comment_providers.dart';
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

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.transactionId,
    this.isHighlighted = false,
  });

  void _triggerReply(WidgetRef ref, String commentId, String userName) {
    final currentReplyingTo = ref.read(replyingToCommentIdProvider);
    if (currentReplyingTo == commentId) {
      ref.read(replyingToCommentIdProvider.notifier).set(null);
      ref.read(replyingToUserNameProvider.notifier).set(null);
    } else {
      ref.read(replyingToCommentIdProvider.notifier).set(commentId);
      ref.read(replyingToUserNameProvider.notifier).set(userName);
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showFDialog<void>(
      context: context,
      builder: (dialogContext, style, animation) => FDialog(
        animation: animation,
        builder: (context, dialogStyle) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.comment.confirmDeleteTitle,
                style: dialogStyle.titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                t.comment.confirmDeleteContent,
                style: dialogStyle.bodyTextStyle,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: Text(t.common.cancel),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: .destructive,
                onPress: () async {
                  Navigator.of(dialogContext).pop();
                  try {
                    await ref
                        .read(
                          transactionCommentsProvider(transactionId).notifier,
                        )
                        .deleteComment(comment.id);
                    if (!context.mounted) return;
                    TopToast.success(context, t.comment.commentDeleted);
                  } catch (e) {
                    if (!context.mounted) return;
                    TopToast.error(
                      context,
                      '${t.comment.deleteFailed}: ${e.toString()}',
                    );
                  }
                },
                child: Text(t.common.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentActions(BuildContext context, WidgetRef ref) {
    final String currentLoggedInUserId = ref.watch(currentUserIdProvider);
    final bool canDelete = comment.userId == currentLoggedInUserId;

    final List<ActionItem> primaryActions = [
      ActionItem(
        title: '复制内容',
        icon: FLucideIcons.copy,
        onTap: () {
          unawaited(
            Clipboard.setData(ClipboardData(text: comment.commentText)),
          );
          TopToast.success(context, '已复制评论内容');
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
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());

    final bool isSubComment = comment.parentCommentId != null;
    final String currentLoggedInUserId = ref.watch(currentUserIdProvider);
    final bool isSelf = comment.userId == currentLoggedInUserId;
    final bool isRepliedToSelf =
        comment.repliedToUserId == currentLoggedInUserId;

    // Build username display, including interactive reply target
    Widget buildUserNameDisplay() {
      final List<Widget> nameParts = [
        Text(comment.userName, style: AppTextStyles.listTrailing(theme)),
      ];

      // Check if it's a child comment and has reply-to user info
      if (isSubComment &&
          comment.repliedToUserName != null &&
          comment.repliedToUserName!.isNotEmpty) {
        nameParts.addAll([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              FLucideIcons.chevronRight,
              size: 12,
              color: colorScheme.mutedForeground,
            ),
          ),
          Flexible(
            child: isRepliedToSelf
                ? Text(
                    comment.repliedToUserName!,
                    style: AppTextStyles.listTrailing(theme).copyWith(
                      color: colorScheme.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : GestureDetector(
                    onTap: () {
                      _triggerReply(
                        ref,
                        comment.id,
                        comment.repliedToUserName!,
                      );
                    },
                    child: Text(
                      comment.repliedToUserName!,
                      style: AppTextStyles.listTrailing(theme).copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
                        timeago.format(comment.createdAt, locale: 'zh_CN'),
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
                  Text(
                    comment.commentText,
                    style: theme.typography.body.sm.copyWith(
                      color: colorScheme.foreground,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
