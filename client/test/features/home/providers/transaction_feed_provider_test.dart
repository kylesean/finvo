// HomeFeed 分页/刷新语义单元测试。
//
// 覆盖 H9 回归点：refresh 保留旧数据（Pull-to-refresh 不得闪全屏骨架），
// 语义性过滤切换（feed 类型/日期）才清空列表；刷新失败保留旧数据并暴露错误。

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/home/services/home_service.dart';

class _FakeHomeService extends HomeService {
  _FakeHomeService() : super(NetworkClient(Dio()));

  /// When non-null, requests block until the completer completes —
  /// lets tests observe the intermediate loading state.
  Completer<void>? gate;
  bool failNext = false;

  @override
  Future<List<TransactionModel>> getTransactionFeed({
    int page = 1,
    int size = 20,
    String? type,
    String? date,
  }) async {
    if (gate != null) await gate!.future;
    if (failNext) {
      throw DioException(requestOptions: RequestOptions(path: '/'));
    }
    return [
      TransactionModel(
        id: 'tx-$page',
        type: TransactionType.expense,
        category: 'food',
        iconUrl: 'icon://food',
        amount: Decimal.one,
        timestamp: DateTime(2026, 8, 1),
      ),
    ];
  }
}

void main() {
  late _FakeHomeService service;
  late ProviderContainer container;

  ProviderContainer buildContainer() {
    service = _FakeHomeService();
    container = ProviderContainer(
      overrides: [
        homeServiceProvider.overrideWithValue(service),
        authTokenProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial load fetches page 1 and populates the feed', () async {
    buildContainer();
    await container.read(transactionFeedProvider.notifier).refreshFeed();

    final state = container.read(transactionFeedProvider);
    expect(state.transactions, hasLength(1));
    expect(state.transactions.first.id, 'tx-1');
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test(
    'refresh keeps the visible list while loading (H9 regression)',
    () async {
      buildContainer();
      final notifier = container.read(transactionFeedProvider.notifier);
      await notifier.refreshFeed();
      expect(
        container.read(transactionFeedProvider).transactions,
        hasLength(1),
      );

      // Block the refresh mid-flight and observe the intermediate state:
      // previously loaded transactions must stay visible (no skeleton wipe).
      service.gate = Completer<void>();
      final refreshFuture = notifier.refreshFeed();

      final during = container.read(transactionFeedProvider);
      expect(during.isLoading, isTrue);
      expect(during.transactions, hasLength(1));

      service.gate!.complete();
      await refreshFuture;
      expect(container.read(transactionFeedProvider).isLoading, isFalse);
    },
  );

  test(
    'refresh failure keeps the last-good list and surfaces the error',
    () async {
      buildContainer();
      final notifier = container.read(transactionFeedProvider.notifier);
      await notifier.refreshFeed();

      service.failNext = true;
      await notifier.refreshFeed();

      final state = container.read(transactionFeedProvider);
      expect(state.transactions, hasLength(1));
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, isFalse);
    },
  );

  test('semantic filter change clears the list (clearList: true)', () async {
    buildContainer();
    final notifier = container.read(transactionFeedProvider.notifier);
    await notifier.refreshFeed();
    expect(container.read(transactionFeedProvider).transactions, hasLength(1));

    service.gate = Completer<void>();
    final switchFuture = notifier.refreshFeed(clearList: true);

    final during = container.read(transactionFeedProvider);
    expect(during.isLoading, isTrue);
    expect(during.transactions, isEmpty);

    service.gate!.complete();
    await switchFuture;
    expect(container.read(transactionFeedProvider).transactions, hasLength(1));
  });
}
