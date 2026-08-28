import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/shared/services/response_parser.dart';

part 'comment_service.g.dart';

class CommentService {
  final NetworkClient _networkClient;
  CommentService(this._networkClient);

  Future<List<CommentModel>> getComments(String transactionId) async {
    return await _networkClient.request<List<CommentModel>>(
      '/transactions/$transactionId/comments', // API endpoint
      method: HttpMethod.get,
      // parseList tolerates `{data: [...]}`, `{data: {items: [...]}}`,
      // root-level lists, and `data: null` as empty.
      fromJsonT: (json) =>
          ResponseParser.parseList(json, CommentModel.fromJson),
    );
  }

  Future<CommentModel> addComment({
    required String transactionId,
    required String commentText,
    String? parentCommentId,
    List<String>? mentionedUserIds,
    String? repliedToUserId,
  }) async {
    final Map<String, dynamic> requestData = {'comment_text': commentText};
    if (parentCommentId != null) {
      requestData['parent_comment_id'] = parentCommentId;
    }
    if (mentionedUserIds != null && mentionedUserIds.isNotEmpty) {
      requestData['mentioned_user_ids'] = mentionedUserIds;
    }
    if (repliedToUserId != null) {
      requestData['replied_to_user_id'] = repliedToUserId;
    }

    return await _networkClient.request<CommentModel>(
      '/transactions/$transactionId/comments',
      method: HttpMethod.post,
      data: requestData,
      // parseItem implements the same "envelope-or-legacy-root" contract.
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, CommentModel.fromJson),
    );
  }

  Future<void> deleteComment(String commentId) async {
    await _networkClient.request<void>(
      // Or <Map<String,dynamic>> if there's a response body
      '/transactions/comments/$commentId',
      method: HttpMethod.delete,
      // fromJsonT: (json) => {}, // Not needed for void if interceptor handles empty data
    );
  }
}

@riverpod
CommentService commentService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return CommentService(networkClient);
}
