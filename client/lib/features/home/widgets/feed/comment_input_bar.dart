import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'dart:async';

import '../../providers/comment_providers.dart';
import '../../models/transaction_model.dart';
import 'mention_picker_widget.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final String transactionId;
  final List<SpaceInfo> spaces;
  final String? recorderUserId;
  const CommentInputBar({
    super.key,
    required this.transactionId,
    this.spaces = const [],
    this.recorderUserId,
  });

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmitting = false;

  // @ mention state
  bool _isMentionMode = false;
  String _mentionFilter = '';
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.spaces.isEmpty) {
        final spaceState = ref.read(sharedSpaceProvider);
        if (spaceState.spaces.isEmpty && !spaceState.isLoading) {
          unawaited(ref.read(sharedSpaceProvider.notifier).loadSpaces());
        }
      }
    });

    ref.listenManual<String?>(replyingToCommentIdProvider, (previous, next) {
      if (next != null && (previous == null || previous != next)) {
        if (!_commentFocusNode.hasFocus) {
          _commentFocusNode.requestFocus();
        }
        final currentReplyingToName = ref.read(replyingToUserNameProvider);
        final allComments =
            ref
                .read(transactionCommentsProvider(widget.transactionId))
                .asData
                ?.value ??
            [];
        final repliedToComment = allComments.firstWhereOrNull(
          (c) => c.id == next,
        );

        if (currentReplyingToName != null && repliedToComment != null) {
          final newText = '@$currentReplyingToName ';
          _commentController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    });
  }

  String? _getEffectiveSpaceId({bool isRead = false}) {
    if (widget.spaces.isNotEmpty) {
      return widget.spaces.first.id;
    }
    final sharedSpaceState = isRead
        ? ref.read(sharedSpaceProvider)
        : ref.watch(sharedSpaceProvider);
    if (sharedSpaceState.spaces.isNotEmpty) {
      return sharedSpaceState.spaces.first.id;
    }
    return null;
  }

  /// Detect @ character to trigger mention mode
  void _onTextChanged() {
    final effectiveSpaceId = _getEffectiveSpaceId(isRead: true);
    if (effectiveSpaceId == null) return;

    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;

    if (cursorPos < 0) {
      _closeMentionMode();
      return;
    }

    // Look backwards from cursor for an unmatched @
    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAt = textBeforeCursor.lastIndexOf('@');

    if (lastAt >= 0) {
      // Check there's no space between @ and cursor (still typing the name)
      final afterAt = textBeforeCursor.substring(lastAt + 1);
      if (!afterAt.contains(' ') || afterAt.isEmpty) {
        setState(() {
          _isMentionMode = true;
          _mentionStartIndex = lastAt;
          _mentionFilter = afterAt;
        });
        return;
      }
    }

    _closeMentionMode();
  }

  void _closeMentionMode() {
    if (_isMentionMode) {
      setState(() {
        _isMentionMode = false;
        _mentionFilter = '';
        _mentionStartIndex = -1;
      });
    }
  }

  void _onMentionSelected(SpaceMemberItem member) {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;

    // Replace from @ position to cursor with @username
    final before = text.substring(0, _mentionStartIndex);
    final after = text.substring(cursorPos);
    final newText = '$before@${member.username} $after';
    final newCursor =
        before.length + member.username.length + 2; // @name + space

    _commentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
    _closeMentionMode();
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    // Remove all @mention tokens to check if there is actual comment content
    final bodyWithoutMentions = commentText
        .replaceAll(RegExp(r'@[^\s]+'), '')
        .trim();
    if (bodyWithoutMentions.isEmpty) {
      TopToast.error(context, '评论内容不能为空');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final directlyRepliedToCommentId = ref.read(replyingToCommentIdProvider);
    String? effectiveParentCommentId;

    if (directlyRepliedToCommentId != null) {
      final allComments =
          ref
              .read(transactionCommentsProvider(widget.transactionId))
              .asData
              ?.value ??
          [];
      final repliedToComment = allComments.firstWhereOrNull(
        (c) => c.id == directlyRepliedToCommentId,
      );

      if (repliedToComment != null) {
        if (repliedToComment.parentCommentId == null) {
          effectiveParentCommentId = repliedToComment.id;
        } else {
          effectiveParentCommentId = repliedToComment.parentCommentId;
        }
      } else {
        effectiveParentCommentId = null;
      }
    } else {
      effectiveParentCommentId = null;
    }

    try {
      // Parse @mentions from text to extract mentioned user IDs
      List<String>? mentionedUserIds;
      final effectiveSpaceId = _getEffectiveSpaceId(isRead: true);
      if (effectiveSpaceId != null) {
        final membersAsync = ref.read(spaceMembersProvider(effectiveSpaceId));
        final members = membersAsync.asData?.value ?? [];
        final mentioned = members
            .where((m) => commentText.contains('@${m.username}'))
            .map((m) => m.userId)
            .toList();
        if (mentioned.isNotEmpty) {
          mentionedUserIds = mentioned;
        }
      }

      await ref
          .read(transactionCommentsProvider(widget.transactionId).notifier)
          .addComment(commentText, effectiveParentCommentId, mentionedUserIds);

      _commentController.clear();
      ref.read(replyingToCommentIdProvider.notifier).set(null);
      ref.read(replyingToUserNameProvider.notifier).set(null);
      _commentFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.comment.commentFailed}: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_onTextChanged);
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final replyingToName = ref.watch(replyingToUserNameProvider);
    final effectiveSpaceId = _getEffectiveSpaceId();
    final canMention = effectiveSpaceId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingToName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FLucideIcons.reply, size: 13, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '回复 @$replyingToName',
                      style: theme.typography.body.xs.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref
                            .read(replyingToCommentIdProvider.notifier)
                            .set(null);
                        ref.read(replyingToUserNameProvider.notifier).set(null);
                        _commentController.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          FLucideIcons.x,
                          size: 14,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // @ Mention picker (shown above input when active)
          if (_isMentionMode && effectiveSpaceId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: MentionPickerWidget(
                spaceId: effectiveSpaceId,
                filter: _mentionFilter,
                replyingToUserName: replyingToName,
                recorderUserId: widget.recorderUserId,
                onSelected: _onMentionSelected,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FTextField(
                  control: .managed(controller: _commentController),
                  focusNode: _commentFocusNode,
                  hint: canMention
                      ? t.comment.addNoteWithMention
                      : t.comment.addNote,
                  onTap: () {
                    if (ref.read(replyingToCommentIdProvider) == null &&
                        _commentFocusNode.hasFocus) {
                    } else if (ref.read(replyingToCommentIdProvider) != null &&
                        !_commentFocusNode.hasFocus) {
                    } else if (ref.read(replyingToCommentIdProvider) == null &&
                        !_commentFocusNode.hasFocus) {
                      ref.read(replyingToCommentIdProvider.notifier).set(null);
                      ref.read(replyingToUserNameProvider.notifier).set(null);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              _isSubmitting
                  ? SizedBox(
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _submitComment,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FLucideIcons.send,
                          size: 16,
                          color: colors.primaryForeground,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
