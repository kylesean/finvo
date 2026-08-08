import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';

import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/features/home/providers/comment_providers.dart';
import 'package:finvo/features/home/widgets/feed/comment_item_widget.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class CommentSectionWidget extends ConsumerStatefulWidget {
  final String transactionId;
  final String? targetCommentId;

  const CommentSectionWidget({
    super.key,
    required this.transactionId,
    this.targetCommentId,
  });

  @override
  ConsumerState<CommentSectionWidget> createState() =>
      _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends ConsumerState<CommentSectionWidget> {
  final Set<String> _expandedParentCommentIds = {};
  final Map<String, GlobalKey> _commentKeys = {};
  bool _hasScrolledToTarget = false;

  GlobalKey _getOrCreateKey(String commentId) {
    return _commentKeys.putIfAbsent(commentId, () => GlobalKey());
  }

  void _scrollToTargetIfNeeded(List<CommentModel> allComments) {
    if (widget.targetCommentId == null || _hasScrolledToTarget) return;

    final target = allComments
        .where((c) => c.id == widget.targetCommentId)
        .firstOrNull;
    if (target != null) {
      if (target.parentCommentId != null) {
        _expandedParentCommentIds.add(target.parentCommentId!);
      }
      _hasScrolledToTarget = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _commentKeys[widget.targetCommentId];
        if (key?.currentContext != null) {
          unawaited(
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.3,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;
    final commentsAsyncValue = ref.watch(
      transactionCommentsProvider(widget.transactionId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 20.0,
            bottom: 8.0,
          ),
          child: Text(
            t.comment.note,
            style: AppTextStyles.pageTitleLarge(theme),
          ),
        ),
        commentsAsyncValue.when(
          data: (allComments) {
            if (allComments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Center(
                  child: Text(
                    t.comment.noNote,
                    style: theme.typography.body.md.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ),
              );
            }

            _scrollToTargetIfNeeded(allComments);

            // 1. Split comments into parent comments and replies
            final parentComments = <CommentModel>[];
            final Map<String, List<CommentModel>> repliesMap = {};

            for (final comment in allComments) {
              if (comment.parentCommentId == null) {
                parentComments.add(comment);
              } else {
                repliesMap
                    .putIfAbsent(comment.parentCommentId!, () => [])
                    .add(comment);
              }
            }

            parentComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            repliesMap.forEach((key, value) {
              value.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            });

            // 2. Build list of widgets
            final List<Widget> commentWidgets = [];
            for (final parent in parentComments) {
              commentWidgets.add(
                Padding(
                  key: _getOrCreateKey(parent.id),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2.0,
                  ),
                  child: CommentItemWidget(
                    comment: parent,
                    transactionId: widget.transactionId,
                    isHighlighted: widget.targetCommentId == parent.id,
                  ),
                ),
              );

              final replies = repliesMap[parent.id] ?? [];
              final isExpanded = _expandedParentCommentIds.contains(parent.id);
              final visibleReplies = (replies.length > 3 && !isExpanded)
                  ? replies.sublist(0, 3)
                  : replies;

              for (final reply in visibleReplies) {
                commentWidgets.add(
                  Padding(
                    key: _getOrCreateKey(reply.id),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    child: CommentItemWidget(
                      comment: reply,
                      transactionId: widget.transactionId,
                      isHighlighted: widget.targetCommentId == reply.id,
                      parentAuthorId: parent.userId,
                      parentAuthorName: parent.userName,
                    ),
                  ),
                );
              }

              // Expand / collapse button for replies > 3
              if (replies.length > 3) {
                final remainingCount = replies.length - 3;
                commentWidgets.add(
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 44.0,
                      top: 6.0,
                      bottom: 6.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedParentCommentIds.remove(parent.id);
                            } else {
                              _expandedParentCommentIds.add(parent.id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isExpanded
                                    ? FLucideIcons.chevronUp
                                    : FLucideIcons.chevronDown,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isExpanded
                                    ? t.comment.collapseReplies
                                    : t.comment.expandMoreReplies(
                                        count: remainingCount,
                                      ),
                                style: theme.typography.body.xs.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (replies.isNotEmpty ||
                  parentComments.indexOf(parent) < parentComments.length - 1) {
                commentWidgets.add(
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: FDivider(),
                  ),
                );
              }
            }

            if (commentWidgets.isNotEmpty &&
                commentWidgets.last is Padding &&
                (commentWidgets.last as Padding).child is FDivider) {
              commentWidgets.removeLast();
            }

            return Column(children: commentWidgets);
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Text(
                '${t.comment.loadFailed}: ${err.toString()}',
                style: theme.typography.body.md.copyWith(
                  color: colorScheme.destructive,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
