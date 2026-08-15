import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:finvo/shared/utils/error_message.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'dart:async';

import 'package:finvo/features/home/providers/comment_providers.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/widgets/feed/mention_picker_widget.dart';

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
  // BRH-01: keep the listenManual subscription and close it in dispose so a
  // late provider update can never touch a disposed controller/focus node
  // after the widget is unmounted (use-after-dispose crash path).
  ProviderSubscription<String?>? _replySubscription;
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

    _replySubscription = ref.listenManual<String?>(
      replyingToCommentIdProvider,
      (previous, next) {
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
      },
    );
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

    // Replace from @ position to cursor with " @username " (padding with spaces)
    final rawBefore = text.substring(0, _mentionStartIndex);
    final rawAfter = text.substring(cursorPos);

    final before = (rawBefore.isNotEmpty && !rawBefore.endsWith(' '))
        ? '$rawBefore '
        : rawBefore;
    final after = (rawAfter.isNotEmpty && !rawAfter.startsWith(' '))
        ? ' $rawAfter'
        : (rawAfter.isEmpty ? ' ' : rawAfter);

    final insertedTag = '@${member.username}';
    final newText = '$before$insertedTag$after';
    final newCursor = before.length + insertedTag.length + 1;

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
      TopToast.error(context, t.comment.contentRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final directlyRepliedToCommentId = ref.read(replyingToCommentIdProvider);
    String? effectiveParentCommentId;
    // The reply target is captured at tap time (replyingToUserIdProvider),
    // never derived from the live comment list: a WebSocket-triggered reload
    // between tap and send used to make the comment unresolvable, silently
    // dropping the target so the replied-to user never got notified.
    String? repliedToUserId = ref.read(replyingToUserIdProvider);

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
        // The reply is attached to the thread's root comment (single-level
        // reply structure), but the user it is directed at is the author of
        // the comment the user actually tapped — which may differ from the
        // root's author in multi-level threads. Persist that explicit target
        // so the rendered "replied to X" stays correct after reloads.
        if (repliedToComment.parentCommentId == null) {
          // Tapping the 1st-level root comment header:
          // Reply attaches to this root comment; no explicit "▶ Target" label needed on the sub-comment.
          effectiveParentCommentId = repliedToComment.id;
          repliedToUserId = null;
        } else {
          // Tapping a 2nd-level sub-comment item inside the thread:
          // Reply attaches to the root comment, but explicitly targets the sub-comment author.
          effectiveParentCommentId = repliedToComment.parentCommentId;
          repliedToUserId ??= repliedToComment.userId;
        }
      } else {
        effectiveParentCommentId = null;
      }
    } else {
      effectiveParentCommentId = null;
    }

    try {
      // Parse @mentions from text to extract mentioned user IDs
      final Set<String> mentionedSet = {};
      final effectiveSpaceId = _getEffectiveSpaceId(isRead: true);
      if (effectiveSpaceId != null) {
        final membersAsync = ref.read(spaceMembersProvider(effectiveSpaceId));
        final members = membersAsync.asData?.value ?? [];
        for (final m in members) {
          if (commentText.contains('@${m.username}')) {
            mentionedSet.add(m.userId);
          }
        }
      }
      final allComments =
          ref
              .read(transactionCommentsProvider(widget.transactionId))
              .asData
              ?.value ??
          [];
      for (final c in allComments) {
        if (commentText.contains('@${c.userName}')) {
          mentionedSet.add(c.userId);
        }
      }
      final List<String>? mentionedUserIds = mentionedSet.isNotEmpty
          ? mentionedSet.toList()
          : null;

      await ref
          .read(transactionCommentsProvider(widget.transactionId).notifier)
          .addComment(
            commentText,
            effectiveParentCommentId,
            mentionedUserIds,
            repliedToUserId: repliedToUserId,
          );

      _commentController.clear();
      ref.read(replyingToCommentIdProvider.notifier).set(null);
      ref.read(replyingToUserNameProvider.notifier).set(null);
      ref.read(replyingToUserIdProvider.notifier).set(null);
      _commentFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        TopToast.error(
          context,
          safeErrorMessage(e, fallback: t.comment.commentFailed),
        );
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
    _replySubscription?.close();
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
                      t.comment.replyToPrefix(name: replyingToName),
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
                        ref.read(replyingToUserIdProvider.notifier).set(null);
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
                        !_commentFocusNode.hasFocus) {
                      ref.read(replyingToCommentIdProvider.notifier).set(null);
                      ref.read(replyingToUserNameProvider.notifier).set(null);
                      ref.read(replyingToUserIdProvider.notifier).set(null);
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
