import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/services/comment_service.dart';
import 'package:finvo/features/home/widgets/feed/comment_input_bar.dart';

import '../../comment_test_fakes.dart';

void main() {
  late FakeCommentService service;

  setUp(() {
    service = FakeCommentService();
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [commentServiceProvider.overrideWithValue(service)],
      child: commentHarness(child: child),
    );
  }

  // Non-empty spaces avoid the sharedSpaceProvider loadSpaces() side effect and
  // keep the mention machinery out of these tests.
  const CommentInputBar inputBar = CommentInputBar(
    transactionId: 'tx-1',
    spaces: [SpaceInfo(id: 'space-1', name: 'Test Space')],
  );

  testWidgets('sends the typed text through the provider', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            inputBar,
            CommentsWatchProbe(transactionId: 'tx-1'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(FTextField), 'hello comment');
    await tester.tap(find.byIcon(FLucideIcons.send));
    await tester.pumpAndSettle();

    expect(service.addCommentCalls, 1);
    expect(service.addedTexts, ['hello comment']);
    // The field is cleared after a successful send.
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );
  });

  testWidgets('ignores an empty submission', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            inputBar,
            CommentsWatchProbe(transactionId: 'tx-1'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FLucideIcons.send));
    await tester.pumpAndSettle();

    expect(service.addCommentCalls, 0);
  });

  testWidgets('surfaces a safe error toast when the send fails', (
    tester,
  ) async {
    service.addCommentError = BusinessException('发送失败');
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            inputBar,
            CommentsWatchProbe(transactionId: 'tx-1'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(FTextField), 'will fail');
    await tester.tap(find.byIcon(FLucideIcons.send));
    await tester.pumpAndSettle();

    // The safe AppException message is shown (never the raw exception text).
    expect(find.text('发送失败'), findsOneWidget);
    // Let the toast's auto-dismiss timer elapse so no timer is pending at
    // teardown.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    // The failed text is kept so the user can retry.
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'will fail',
    );
  });
}
