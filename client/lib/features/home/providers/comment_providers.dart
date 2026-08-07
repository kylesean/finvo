import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/features/home/services/comment_service.dart';

part 'comment_providers.g.dart';

/// Ascending compare for comments by `createdAt`.
int _compareByCreatedAt(CommentModel a, CommentModel b) {
  return a.createdAt.compareTo(b.createdAt);
}

@riverpod
class TransactionComments extends _$TransactionComments {
  @override
  FutureOr<List<CommentModel>> build(String transactionId) async {
    final service = ref.watch(commentServiceProvider);
    final comments = await service.getComments(transactionId);
    comments.sort(_compareByCreatedAt);
    return comments;
  }

  Future<void> addComment(
    String text,
    String? parentId,
    List<String>? mentionedUserIds,
  ) async {
    final service = ref.read(commentServiceProvider);

    try {
      final created = await service.addComment(
        transactionId: transactionId,
        commentText: text,
        parentCommentId: parentId,
        mentionedUserIds: mentionedUserIds,
      );

      final current = state.value;
      if (current == null) {
        // List not loaded yet; reload to pick up the new comment.
        final comments = await service.getComments(transactionId);
        comments.sort(_compareByCreatedAt);
        state = AsyncData(comments);
      } else {
        // Optimistically append the server-created comment without a full reload.
        final updated = [...current, created]..sort(_compareByCreatedAt);
        state = AsyncData(updated);
      }
    } catch (e, st) {
      // Keep the already-loaded list visible: replacing it with AsyncError
      // would blank out existing comments just because one send failed.
      // The error is rethrown so the caller can surface a toast.
      if (state.value == null) {
        state = AsyncError(e, st);
      }
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    final service = ref.read(commentServiceProvider);

    final current = state.value;
    if (current != null) {
      // Optimistically remove the comment for an immediate UI response.
      state = AsyncData(current.where((c) => c.id != commentId).toList());
    }

    try {
      await service.deleteComment(commentId);
    } catch (e) {
      // Reconcile with the server truth if the delete failed.
      state = await AsyncValue.guard(() async {
        final comments = await service.getComments(transactionId);
        comments.sort(_compareByCreatedAt);
        return comments;
      });
    }
  }
}

@riverpod
class ReplyingToCommentId extends _$ReplyingToCommentId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

@riverpod
class ReplyingToUserName extends _$ReplyingToUserName {
  @override
  String? build() => null;

  void set(String? name) => state = name;
}
