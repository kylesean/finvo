import 'package:flutter/material.dart';
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

/// Current logged-in user's ID (from auth state)
final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.id ?? '';
});

class CommentItemWidget extends ConsumerWidget {
  final CommentModel comment;
  final String transactionId;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.transactionId,
  });

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.comment.confirmDeleteTitle),
          content: Text(t.comment.confirmDeleteContent),
          actions: <Widget>[
            FButton(
              variant: .outline,
              onPress: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(t.common.cancel),
            ),
            FButton(
              variant: .destructive,
              onPress: () async {
                Navigator.of(dialogContext).pop();
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
                    '${t.comment.deleteFailed}: ${e.toString()}',
                  );
                }
              },
              child: Text(t.common.delete),
            ),
          ],
        );
      },
    );
  }

  void _showCommentActions(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colors;
    final String currentLoggedInUserId = ref.watch(currentUserIdProvider);
    final bool canDelete = comment.userId == currentLoggedInUserId;

    final List<Widget> actions = [];

    if (canDelete) {
      actions.add(
        FButton(
          variant: .ghost,
          onPress: () {
            Navigator.of(context).pop();
            unawaited(_showDeleteConfirmDialog(context, ref));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.trash2,
                size: 16,
                color: colorScheme.destructive,
              ),
              const SizedBox(width: 8),
              Text(
                t.comment.deleteComment,
                style: TextStyle(color: colorScheme.destructive),
              ),
            ],
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      TopToast.info(context, t.comment.noActions);
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context, // Use the context of CommentItemWidget
        builder: (sheetContext) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: actions,
            ),
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
    final bool canDelete = comment.userId == currentLoggedInUserId;

    // Build username display, including reply target
    Widget buildUserNameDisplay() {
      final List<Widget> nameParts = [
        Text(
          comment.userName, // Current commenter
          style: AppTextStyles.listTrailing(theme),
        ),
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
            // Use Flexible to avoid overflow for long usernames
            child: Text(
              comment.repliedToUserName!, // Person being replied to
              style: AppTextStyles.listTrailing(
                theme,
              ).copyWith(color: colorScheme.primary),
              overflow: TextOverflow.ellipsis, // Ellipsis for overflow
            ),
          ),
        ]);
      }
      return Row(mainAxisSize: MainAxisSize.min, children: nameParts);
    }

    return GestureDetector(
      onTap: () {
        // Cannot reply to your own comment
        if (comment.userId == currentLoggedInUserId) return;

        // Tap entire comment to trigger reply
        final currentReplyingTo = ref.read(replyingToCommentIdProvider);
        if (currentReplyingTo == comment.id) {
          ref.read(replyingToCommentIdProvider.notifier).set(null);
          ref.read(replyingToUserNameProvider.notifier).set(null);
        } else {
          ref.read(replyingToCommentIdProvider.notifier).set(comment.id);
          ref.read(replyingToUserNameProvider.notifier).set(comment.userName);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          left: isSubComment ? 28.0 : 0,
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
                      if (canDelete)
                        FButton.icon(
                          onPress: () => _showCommentActions(context, ref),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              FLucideIcons.ellipsis,
                              color: colorScheme.mutedForeground,
                              size: 14,
                            ),
                          ),
                        ),
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
