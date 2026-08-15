// Shared fakes/harness for comment feature tests: a real CommentService over a
// stubbed NetworkClient is replaced by this fake, so provider logic runs for
// real while I/O is fully controllable.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/features/home/services/comment_service.dart';
import 'package:finvo/features/home/providers/comment_providers.dart';

/// Deterministic fake [CommentService]: records calls, serves canned data and
/// can be configured to throw, or to gate an in-flight add via a completer
/// (for generation-race tests).
class FakeCommentService extends CommentService {
  FakeCommentService() : super(NetworkClient(Dio()));

  final List<CommentModel> comments = [];
  final List<String> addedTexts = [];
  final List<String> deletedIds = [];
  int addCommentCalls = 0;

  Object? getCommentsError;
  Object? addCommentError;
  Object? deleteCommentError;

  /// When set, [addComment] awaits this gate before resolving (and ignores
  /// [addCommentError] once the gate completes).
  Completer<CommentModel>? addGate;

  @override
  Future<List<CommentModel>> getComments(String transactionId) async {
    final error = getCommentsError;
    if (error != null) throw error;
    return List.of(comments);
  }

  @override
  Future<CommentModel> addComment({
    required String transactionId,
    required String commentText,
    String? parentCommentId,
    List<String>? mentionedUserIds,
    String? repliedToUserId,
  }) async {
    addCommentCalls++;
    addedTexts.add(commentText);

    final gate = addGate;
    if (gate != null) {
      // Gated path does NOT mutate the server list: the test owns server
      // truth (the generation guard must reconcile against it).
      return gate.future;
    }

    final error = addCommentError;
    if (error != null) throw error;

    final created = CommentModel(
      id: 'c-built-$addCommentCalls',
      transactionId: transactionId,
      userId: 'me',
      userName: 'Me',
      userAvatarUrl: '',
      commentText: commentText,
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
    );
    comments.add(created);
    return created;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final error = deleteCommentError;
    if (error != null) throw error;
    deletedIds.add(commentId);
    comments.removeWhere((c) => c.id == commentId);
  }
}

/// Builds a [CommentModel] with minimal required fields.
CommentModel makeComment({
  required String id,
  required String text,
  String? userId,
  String? userName,
  DateTime? createdAt,
  String? parentCommentId,
  String? repliedToUserName,
}) {
  return CommentModel(
    id: id,
    transactionId: 'tx-1',
    userId: userId ?? 'u-1',
    userName: userName ?? 'User 1',
    userAvatarUrl: '',
    commentText: text,
    parentCommentId: parentCommentId,
    repliedToUserId: userId,
    repliedToUserName: repliedToUserName,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
  );
}

/// FTheme + MaterialApp harness mirroring the existing widget-test harness
/// used for forui-based widgets. Wrap with `ProviderScope(overrides: [...])`
/// at the call site — `Override` is not exported by the public riverpod API.
Widget commentHarness({required Widget child}) {
  return MaterialApp(
    builder: (context, child) {
      final theme = FThemeData(colors: FColors.neutralLight, touch: false);
      final extendedTheme = FThemeData(
        colors: theme.colors,
        touch: false,
        typography: theme.typography,
        extensions: [AppSemanticColors.light],
      );
      return FTheme(data: extendedTheme, child: child!);
    },
    home: Scaffold(body: child),
  );
}

/// Keeps the auto-disposable comment-list family alive for the whole test,
/// mirroring the real screen where the comments section watches it. Without a
/// listener, Riverpod auto-disposes the provider between the tap's `ref.read`
/// and the awaited `addComment`/`deleteComment`, surfacing UnmountedRefException
/// on the state write.
class CommentsWatchProbe extends ConsumerWidget {
  final String transactionId;

  const CommentsWatchProbe({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(transactionCommentsProvider(transactionId));
    return const SizedBox.shrink();
  }
}
