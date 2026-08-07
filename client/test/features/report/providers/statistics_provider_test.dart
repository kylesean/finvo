import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/providers/statistics_provider.dart';
import 'package:finvo/features/report/services/statistics_service.dart';

void main() {
  group('StatisticsState', () {
    test(
      'defaults to month range, expense chart, amount sort, not loading',
      () {
        const state = StatisticsState();

        expect(state.timeRange, TimeRange.month);
        expect(state.chartType, ChartType.expense);
        expect(state.sortType, SortType.amount);
        expect(state.isLoading, isFalse);
        expect(state.isLoadingMoreTopTransactions, isFalse);
        expect(state.error, isNull);
        expect(state.overview, isNull);
        expect(state.trendData, isNull);
        expect(state.categoryBreakdown, isNull);
        expect(state.topTransactions, isNull);
        expect(state.cashFlow, isNull);
        expect(state.healthScore, isNull);
      },
    );

    test('copyWith preserves unspecified fields', () {
      const state = StatisticsState();
      final updated = state.copyWith(isLoading: true, error: 'boom');

      expect(updated.isLoading, isTrue);
      expect(updated.error, 'boom');
      expect(updated.timeRange, TimeRange.month);
      expect(updated.chartType, ChartType.expense);
      expect(updated.sortType, SortType.amount);
    });
  });

  group('Statistics provider', () {
    late ProviderContainer container;
    late _FakeStatisticsService service;

    setUp(() {
      service = _FakeStatisticsService();
      container = ProviderContainer(
        overrides: [statisticsServiceProvider.overrideWithValue(service)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build returns default empty state', () {
      final state = container.read(statisticsProvider);
      expect(state, isA<StatisticsState>());
      expect(state.timeRange, TimeRange.month);
      expect(state.isLoading, isFalse);
    });

    test('loadStatistics populates all core data and clears loading', () async {
      service.overview = _overview();
      service.trendData = _trend();
      service.categoryBreakdown = _category();
      service.topTransactions = _topTransactions();
      service.cashFlow = _cashFlow();
      service.healthScore = _healthScore();

      final notifier = container.read(statisticsProvider.notifier);
      await notifier.loadStatistics();

      final state = container.read(statisticsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.overview, isNotNull);
      expect(state.trendData, isNotNull);
      expect(state.categoryBreakdown, isNotNull);
      expect(state.topTransactions, isNotNull);
      expect(state.cashFlow, isNotNull);
      expect(state.healthScore, isNotNull);
    });

    test('core data failure sets error and stops loading', () async {
      service.failCore = true;

      final notifier = container.read(statisticsProvider.notifier);
      await notifier.loadStatistics();

      final state = container.read(statisticsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNotNull);
      expect(state.overview, isNull);
    });

    test(
      'supplementary (cash-flow/health) failure degrades to null without error',
      () async {
        service.overview = _overview();
        service.trendData = _trend();
        service.categoryBreakdown = _category();
        service.topTransactions = _topTransactions();
        service.failSupplementary = true;

        final notifier = container.read(statisticsProvider.notifier);
        await notifier.loadStatistics();

        final state = container.read(statisticsProvider);
        expect(state.cashFlow, isNull);
        expect(state.healthScore, isNull);
        expect(state.error, isNull);
        expect(state.overview, isNotNull);
      },
    );

    test('setTimeRange updates range, custom dates, and reloads', () async {
      service.overview = _overview();
      service.trendData = _trend();
      service.categoryBreakdown = _category();
      service.topTransactions = _topTransactions();

      final start = DateTime.utc(2026, 1, 1);
      final end = DateTime.utc(2026, 1, 31);
      final notifier = container.read(statisticsProvider.notifier);
      await notifier.setTimeRange(
        TimeRange.custom,
        startDate: start,
        endDate: end,
      );

      final state = container.read(statisticsProvider);
      expect(state.timeRange, TimeRange.custom);
      expect(state.customStartDate, start);
      expect(state.customEndDate, end);
      expect(state.dateRangeDisplayText, isNotNull);
      expect(state.overview, isNotNull);
    });

    test('setChartType updates chart type and trend data', () async {
      service.trendData = _trend();
      final notifier = container.read(statisticsProvider.notifier);
      await notifier.setChartType(ChartType.income);

      final state = container.read(statisticsProvider);
      expect(state.chartType, ChartType.income);
      expect(state.trendData, isNotNull);
      // setChartType performs a targeted reload, not a full load.
      expect(state.overview, isNull);
    });

    test('setSortType updates sort type and top transactions', () async {
      service.topTransactions = _topTransactions();
      final notifier = container.read(statisticsProvider.notifier);
      await notifier.setSortType(SortType.date);

      final state = container.read(statisticsProvider);
      expect(state.sortType, SortType.date);
      expect(state.topTransactions, isNotNull);
      expect(state.overview, isNull);
    });

    test('setAccountTypes updates filter and reloads', () async {
      service.overview = _overview();
      service.trendData = _trend();
      service.categoryBreakdown = _category();
      service.topTransactions = _topTransactions();

      final notifier = container.read(statisticsProvider.notifier);
      await notifier.setAccountTypes(['cash', 'bank']);

      final state = container.read(statisticsProvider);
      expect(state.selectedAccountTypes, ['cash', 'bank']);
      expect(state.overview, isNotNull);
      expect(service.lastAccountTypes, ['cash', 'bank']);
    });

    test('loadMoreTopTransactions appends next page', () async {
      service.overview = _overview();
      service.trendData = _trend();
      service.categoryBreakdown = _category();
      service.topTransactions = _topTransactions(hasMore: true, page: 1);

      final notifier = container.read(statisticsProvider.notifier);
      await notifier.loadStatistics();
      await notifier.loadMoreTopTransactions();

      final state = container.read(statisticsProvider);
      expect(state.topTransactions!.items, hasLength(2));
      expect(state.isLoadingMoreTopTransactions, isFalse);
    });

    test('loadMoreTopTransactions is a no-op without hasMore', () async {
      service.overview = _overview();
      service.trendData = _trend();
      service.categoryBreakdown = _category();
      service.topTransactions = _topTransactions(hasMore: false);

      final notifier = container.read(statisticsProvider.notifier);
      await notifier.loadStatistics();
      await notifier.loadMoreTopTransactions();

      final state = container.read(statisticsProvider);
      expect(state.topTransactions!.items, hasLength(1));
    });
  });
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _periodStart = DateTime.utc(2026, 1, 1);
final _periodEnd = DateTime.utc(2026, 1, 31);

StatisticsOverview _overview() {
  return StatisticsOverview(
    totalBalance: '10000.00',
    totalIncome: '8000.00',
    totalExpense: '3000.00',
    incomeChangePercent: 5.5,
    expenseChangePercent: -2.0,
    netChangePercent: 3.2,
    balanceNote: 'Healthy',
    periodStart: _periodStart,
    periodEnd: _periodEnd,
  );
}

TrendDataResponse _trend() {
  return const TrendDataResponse(
    dataPoints: [
      TrendDataPoint(date: '2026-01-01', amount: '100.00', label: 'Jan 1'),
    ],
    timeRange: 'month',
    transactionType: 'expense',
  );
}

CategoryBreakdownResponse _category() {
  return const CategoryBreakdownResponse(
    items: [
      CategoryBreakdownItem(
        categoryKey: 'food',
        categoryName: 'Food',
        amount: '120.50',
        percentage: 40.0,
        color: '#ff0000',
        icon: 'restaurant',
      ),
    ],
    total: '120.50',
  );
}

TopTransactionsResponse _topTransactions({bool hasMore = false, int page = 1}) {
  return TopTransactionsResponse(
    items: [
      TopTransactionItem(
        id: 't1',
        description: 'Dinner',
        amount: '300.00',
        categoryKey: 'food',
        categoryName: 'Food',
        transactionAt: _periodStart,
        icon: 'restaurant',
      ),
    ],
    sortBy: 'amount',
    total: 1,
    page: page,
    hasMore: hasMore,
  );
}

CashFlowAnalysis _cashFlow() {
  return CashFlowAnalysis(
    totalIncome: '8000.00',
    totalExpense: '3000.00',
    netCashFlow: '5000.00',
    savingsRate: 62.5,
    expenseToIncomeRatio: 0.375,
    incomeChangePercent: 1.0,
    expenseChangePercent: -0.5,
    savingsRateChange: 2.0,
    periodStart: _periodStart,
    periodEnd: _periodEnd,
  );
}

HealthScore _healthScore() {
  return HealthScore(
    totalScore: 82,
    grade: 'B',
    dimensions: const [
      HealthScoreDimension(
        name: 'Saving',
        score: 80,
        weight: 0.5,
        description: 'ok',
        status: 'good',
      ),
    ],
    suggestions: const ['Save more'],
    periodStart: _periodStart,
    periodEnd: _periodEnd,
  );
}

// ---------------------------------------------------------------------------
// Fake service
// ---------------------------------------------------------------------------

/// Hand-written fake [StatisticsService] so provider tests don't hit the
/// network or require codegen'd mocks. Underscore fields gate failure modes.
class _FakeStatisticsService implements StatisticsService {
  StatisticsOverview? overview;
  TrendDataResponse? trendData;
  CategoryBreakdownResponse? categoryBreakdown;
  TopTransactionsResponse? topTransactions;
  CashFlowAnalysis? cashFlow;
  HealthScore? healthScore;

  bool failCore = false;
  bool failSupplementary = false;
  List<String>? lastAccountTypes;

  _FakeStatisticsService();

  @override
  Future<StatisticsOverview> getOverview({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    lastAccountTypes = accountTypes;
    if (failCore) throw Exception('core failed');
    return overview ?? _overview();
  }

  @override
  Future<TrendDataResponse> getTrendData({
    TimeRange timeRange = TimeRange.month,
    ChartType chartType = ChartType.expense,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    lastAccountTypes = accountTypes;
    if (failCore) throw Exception('core failed');
    return trendData ?? _trend();
  }

  @override
  Future<CategoryBreakdownResponse> getCategoryBreakdown({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
    int limit = 10,
  }) async {
    lastAccountTypes = accountTypes;
    if (failCore) throw Exception('core failed');
    return categoryBreakdown ?? _category();
  }

  @override
  Future<TopTransactionsResponse> getTopTransactions({
    TimeRange timeRange = TimeRange.month,
    SortType sortBy = SortType.amount,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
    int page = 1,
    int pageSize = 10,
  }) async {
    lastAccountTypes = accountTypes;
    if (failCore) throw Exception('core failed');
    final base = topTransactions ?? _topTransactions();
    // Simulate paging: a next-page response carries only the newly fetched
    // entries (the provider merges them onto the already-loaded list).
    if (page > 1) {
      return TopTransactionsResponse(
        items: [
          TopTransactionItem(
            id: 't2',
            description: 'Rent',
            amount: '2000.00',
            categoryKey: 'housing',
            categoryName: 'Housing',
            transactionAt: _periodStart,
            icon: 'home',
          ),
        ],
        sortBy: base.sortBy,
        total: base.total,
        page: page,
        pageSize: base.pageSize,
        hasMore: base.hasMore,
      );
    }
    return base;
  }

  @override
  Future<CashFlowAnalysis> getCashFlow({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    lastAccountTypes = accountTypes;
    if (failSupplementary) throw Exception('supplementary failed');
    return cashFlow ?? _cashFlow();
  }

  @override
  Future<HealthScore> getHealthScore({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    lastAccountTypes = accountTypes;
    if (failSupplementary) throw Exception('supplementary failed');
    return healthScore ?? _healthScore();
  }
}
