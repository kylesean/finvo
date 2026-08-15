import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/home/widgets/feed/comment_item_widget.dart';
import 'package:finvo/features/home/services/comment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/i18n/strings.g.dart';

import '../../comment_test_fakes.dart';

void main() {
  late FakeCommentService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = FakeCommentService();
  });

  Widget wrap({
    required String currentUserId,
    required String transactionId,
    required CommentItemWidget Function() build,
  }) {
    return ProviderScope(
      overrides: [
        commentServiceProvider.overrideWithValue(service),
        currentUserIdProvider.overrideWithValue(currentUserId),
        // UserAvatar resolves server-config through SharedPreferences.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: commentHarness(
        child: Column(
          children: [
            build(),
            CommentsWatchProbe(transactionId: transactionId),
          ],
        ),
      ),
    );
  }

  group('CommentItemWidget', () {
    testWidgets('renders author and comment text', (tester) async {
      final mine = makeComment(
        id: 'c1',
        text: 'Hello world',
        userId: 'me',
        userName: 'Me',
      );

      await tester.pumpWidget(
        wrap(
          currentUserId: 'me',
          transactionId: 'tx-1',
          build: () => CommentItemWidget(comment: mine, transactionId: 'tx-1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
    });

    testWidgets('own comment can be deleted via sheet + confirm dialog', (
      tester,
    ) async {
      final mine = makeComment(
        id: 'c1',
        text: 'to delete',
        userId: 'me',
        userName: 'Me',
      );
      service.comments.add(mine);

      await tester.pumpWidget(
        wrap(
          currentUserId: 'me',
          transactionId: 'tx-1',
          build: () => CommentItemWidget(comment: mine, transactionId: 'tx-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the comment row -> actions bottom sheet.
      await tester.tap(find.text('to delete'));
      await tester.pumpAndSettle();
      expect(find.text(t.comment.deleteComment), findsOneWidget);

      // Tap delete -> confirmation dialog.
      await tester.tap(find.text(t.comment.deleteComment));
      await tester.pumpAndSettle();
      expect(find.text(t.common.delete), findsOneWidget);

      // Confirm -> deleteComment call + success toast.
      await tester.tap(find.text(t.common.delete));
      await tester.pumpAndSettle();

      expect(service.deletedIds, ['c1']);
      expect(find.text(t.comment.commentDeleted), findsOneWidget);
      // Let the success toast's auto-dismiss timer elapse before teardown.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('foreign comment does not offer delete (replies instead)', (
      tester,
    ) async {
      final foreign = makeComment(
        id: 'c2',
        text: 'foreign comment',
        userId: 'u-other',
        userName: 'Other',
      );
      service.comments.add(foreign);

      await tester.pumpWidget(
        wrap(
          currentUserId: 'me',
          transactionId: 'tx-1',
          build: () =>
              CommentItemWidget(comment: foreign, transactionId: 'tx-1'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('foreign comment'));
      await tester.pumpAndSettle();

      // No delete action for someone else's comment.
      expect(find.text(t.comment.deleteComment), findsNothing);
    });
  });
}
