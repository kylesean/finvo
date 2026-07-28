// features/transaction_detail/widgets/comment_input_bar.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart'; // Import forui
import 'package:finvo/i18n/strings.g.dart';

// Assuming these Providers are imported from outside
// Core logic migrated to transactionCommentsProvider
import '../../providers/comment_providers.dart';
import '../../models/transaction_model.dart';
import 'mention_picker_widget.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final String transactionId;
  final List<SpaceInfo> spaces;
  const CommentInputBar({
    super.key,
    required this.transactionId,
    this.spaces = const [],
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
    ref.listenManual<String?>(replyingToCommentIdProvider, (previous, next) {
      if (next != null && (previous == null || previous != next)) {
        if (!_commentFocusNode.hasFocus) {
          _commentFocusNode.requestFocus();
        }
        final currentReplyingToName = ref.read(replyingToUserNameProvider);
        // Get the comment being replied to, to determine its parentCommentId later
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
          // When pre-filling, could consider showing reply chain, e.g., "@UserA > @UserB"
          // But for simplicity, we still only show the directly replied username
          final newText = '@$currentReplyingToName ';
          _commentController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    });
  }

  /// Detect @ character to trigger mention mode
  void _onTextChanged() {
    if (widget.spaces.isEmpty) return;

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

    setState(() {
      _isSubmitting = true;
    });

    final directlyRepliedToCommentId = ref.read(replyingToCommentIdProvider);
    String?
    effectiveParentCommentId; // This is the parentCommentId to pass to backend

    if (directlyRepliedToCommentId != null) {
      // Need to get all comments to find the one being replied to, and determine its parentCommentId
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
          // If replying directly to a parent comment, parentCommentId is this parent comment's id
          effectiveParentCommentId = repliedToComment.id;
        } else {
          // If replying to a child comment, parentCommentId should be its parentCommentId (top-level id)
          effectiveParentCommentId = repliedToComment.parentCommentId;
        }
      } else {
        // Theoretically shouldn't happen as replyingToCommentIdProvider should match an existing comment
        // But as fallback, don't set parentCommentId, making it a new parent comment
        effectiveParentCommentId = null;
      }
    } else {
      // No reply target, this is a new parent comment
      effectiveParentCommentId = null;
    }

    try {
      await ref
          .read(transactionCommentsProvider(widget.transactionId).notifier)
          .addComment(commentText, effectiveParentCommentId);

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

  // ... dispose and build methods ...
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
              padding: const EdgeInsets.only(
                bottom: 6.0,
                left: 4.0,
                right: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    t.comment.replyToPrefix(
                      name: replyingToName,
                    ), // Displays the author name of the comment being replied to
                    style: AppTextStyles.listSubtitle(theme),
                  ),
                  const Spacer(),
                  FButton.icon(
                    onPress: () {
                      ref.read(replyingToCommentIdProvider.notifier).set(null);
                      ref.read(replyingToUserNameProvider.notifier).set(null);
                      _commentFocusNode.unfocus();
                      _commentController.clear();
                    },
                    child: Icon(
                      FLucideIcons.x,
                      color: colors.mutedForeground,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          // @ Mention picker (shown above input when active)
          if (_isMentionMode && widget.spaces.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: MentionPickerWidget(
                spaceId: widget.spaces.first.id,
                filter: _mentionFilter,
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
                  hint: widget.spaces.isNotEmpty
                      ? t.comment.addNoteWithMention
                      : t.comment.addNote,
                  onTap: () {
                    // Logic here ensures existing reply state is cleared when user clicks input directly
                    // If focused via "Reply" button, replyingToCommentIdProvider already has value
                    if (ref.read(replyingToCommentIdProvider) == null &&
                        _commentFocusNode.hasFocus) {
                      // If no reply target and focus is in input, user might want to start new comment, no action
                    } else if (ref.read(replyingToCommentIdProvider) != null &&
                        !_commentFocusNode.hasFocus) {
                      // If reply target exists but no focus, focus it on click
                      // (Usually handled internally by ShadInput)
                    } else if (ref.read(replyingToCommentIdProvider) == null &&
                        !_commentFocusNode.hasFocus) {
                      // User clicks empty input direktly, clear any lingering reply state
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
