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
  /// Monotonic mutation generation. Each optimistic mutation bumps it; a slower
  /// in-flight response that returns after a newer mutation has already applied
  /// is discarded so stale orderings can't clobber newer ones. This mirrors the
  /// generation-token pattern used elsewhere in the codebase.
  int _generation = 0;

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
    final generation = ++_generation;

    try {
      final created = await service.addComment(
        transactionId: transactionId,
        commentText: text,
        parentCommentId: parentId,
        mentionedUserIds: mentionedUserIds,
      );

      // A newer mutation (delete/add) landed while this request was in flight:
      // reconcile from the server instead of clobbering the newer state.
      if (generation != _generation) {
        await _reload(service);
        return;
      }

      final current = state.value;
      if (current == null) {
        // List not loaded yet; reload to pick up the new comment.
        await _reload(service);
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
    final generation = ++_generation;

    final current = state.value;
    if (current != null) {
      // Optimistically remove the comment for an immediate UI response.
      state = AsyncData(current.where((c) => c.id != commentId).toList());
    }

    try {
      await service.deleteComment(commentId);
      // If a newer mutation intervened, reconcile with server truth.
      if (generation != _generation) {
        await _reload(service);
      }
    } catch (e) {
      // A stale delete that raced a newer mutation should defer to the server
      // state; only reconcile if this delete is still the latest mutation.
      if (generation == _generation) {
        await _reload(service);
      }
    }
  }

  /// Reload the full comment list from the server and sort it.
  Future<void> _reload(CommentService service) async {
    final comments = await service.getComments(transactionId);
    comments.sort(_compareByCreatedAt);
    state = AsyncData(comments);
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
