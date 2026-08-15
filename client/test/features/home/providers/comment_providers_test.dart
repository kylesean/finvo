import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/home/providers/comment_providers.dart';
import 'package:finvo/features/home/models/comment_model.dart';
import 'package:finvo/features/home/services/comment_service.dart';

import '../comment_test_fakes.dart';

void main() {
  late FakeCommentService service;
  late ProviderContainer container;

  setUp(() {
    service = FakeCommentService();
    container = ProviderContainer(
      overrides: [commentServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
  });

  CommentModel builtComment(String id, String text) =>
      makeComment(id: id, text: text);

  group('transactionCommentsProvider', () {
    test('build loads and sorts comments by createdAt ascending', () async {
      final later = makeComment(
        id: '2',
        text: 'second',
        createdAt: DateTime.utc(2026, 1, 2),
      );
      final earlier = makeComment(
        id: '1',
        text: 'first',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      service.comments.addAll([later, earlier]);

      await container.read(transactionCommentsProvider('tx-1').future);
      final state = container.read(transactionCommentsProvider('tx-1'));

      expect(state.value!.map((c) => c.id), ['1', '2']);
    });

    test(
      'addComment appends the server-created comment without a full reload',
      () async {
        service.comments.add(builtComment('1', 'existing'));
        await container.read(transactionCommentsProvider('tx-1').future);

        await container
            .read(transactionCommentsProvider('tx-1').notifier)
            .addComment('hello', null, null);
        final state = container.read(transactionCommentsProvider('tx-1'));

        expect(state.value!.map((c) => c.id), contains('c-built-1'));
        expect(state.value!.map((c) => c.id), contains('1'));
        expect(service.addedTexts, ['hello']);
      },
    );

    test(
      'addComment failure keeps the loaded list and rethrows for the toast',
      () async {
        service.comments.add(builtComment('1', 'existing'));
        await container.read(transactionCommentsProvider('tx-1').future);
        service.addCommentError = BusinessException('发送失败');

        await expectLater(
          container
              .read(transactionCommentsProvider('tx-1').notifier)
              .addComment('boom', null, null),
          throwsA(isA<BusinessException>()),
        );
        // The already-loaded list stays visible (no AsyncError blank-out).
        final state = container.read(transactionCommentsProvider('tx-1'));
        expect(state.hasError, isFalse);
        expect(state.value!.map((c) => c.id), ['1']);
      },
    );

    test(
      'a stale in-flight add is reconciled instead of clobbering newer state '
      '(generation guard)',
      () async {
        service.comments.add(builtComment('1', 'existing'));
        await container.read(transactionCommentsProvider('tx-1').future);

        // Add #1 is slow (gated); delete intervenes and bumps the generation.
        final gate = Completer<CommentModel>();
        service.addGate = gate;
        final staleAdd = container
            .read(transactionCommentsProvider('tx-1').notifier)
            .addComment('stale', null, null);
        await container
            .read(transactionCommentsProvider('tx-1').notifier)
            .deleteComment('1');
        // Server truth after the delete: only '2' remains (the stale add was
        // never persisted server-side).
        service.comments.clear();
        service.comments.add(builtComment('2', 'after-delete'));

        gate.complete(builtComment('stale-created', 'stale'));
        await staleAdd;

        // The stale create must not be blindly appended on top of the newer
        // state: the provider reconciles from the server instead.
        final state = container.read(transactionCommentsProvider('tx-1'));
        expect(state.value!.map((c) => c.id), ['2']);
        expect(state.value!.map((c) => c.id), isNot(contains('stale-created')));
      },
    );

    test(
      'deleteComment optimistically removes and reconciles on newer mutation',
      () async {
        service.comments.addAll([
          builtComment('1', 'a'),
          builtComment('2', 'b'),
        ]);
        await container.read(transactionCommentsProvider('tx-1').future);

        await container
            .read(transactionCommentsProvider('tx-1').notifier)
            .deleteComment('1');
        final state = container.read(transactionCommentsProvider('tx-1'));

        expect(service.deletedIds, ['1']);
        expect(state.value!.map((c) => c.id), ['2']);
      },
    );

    test('deleteComment failure restores and rethrows', () async {
      service.comments.addAll([builtComment('1', 'a')]);
      await container.read(transactionCommentsProvider('tx-1').future);
      service.deleteCommentError = BusinessException('删除失败');

      await expectLater(
        container
            .read(transactionCommentsProvider('tx-1').notifier)
            .deleteComment('1'),
        throwsA(isA<BusinessException>()),
      );
      // A failed delete reloads server truth (comment reappears).
      final state = container.read(transactionCommentsProvider('tx-1'));
      expect(state.value!.map((c) => c.id), ['1']);
    });
  });
}
