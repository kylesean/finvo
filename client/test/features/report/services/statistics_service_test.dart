import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/services/statistics_service.dart';

import 'statistics_service_test.mocks.dart';

@GenerateMocks([NetworkClient])
void main() {
  late MockNetworkClient mockNetworkClient;
  late StatisticsService service;
  late Map<String, dynamic>? lastQueryParams;

  setUp(() {
    mockNetworkClient = MockNetworkClient();
    service = StatisticsService(mockNetworkClient);
    lastQueryParams = null;
  });

  final periodStart = DateTime.utc(2026, 1, 1);
  final periodEnd = DateTime.utc(2026, 1, 31);

  final overview = StatisticsOverview(
    totalBalance: '10000.00',
    totalIncome: '8000.00',
    totalExpense: '3000.00',
    incomeChangePercent: 5.5,
    expenseChangePercent: -2.0,
    netChangePercent: 3.2,
    balanceNote: 'Healthy',
    periodStart: periodStart,
    periodEnd: periodEnd,
  );

  const trend = TrendDataResponse(
    dataPoints: [
      TrendDataPoint(date: '2026-01-01', amount: '100.00', label: 'Jan 1'),
    ],
    timeRange: 'week',
    transactionType: 'expense',
  );

  const category = CategoryBreakdownResponse(
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

  final topTransactions = TopTransactionsResponse(
    items: [
      TopTransactionItem(
        id: 't1',
        description: 'Dinner',
        amount: '300.00',
        categoryKey: 'food',
        categoryName: 'Food',
        transactionAt: periodStart,
        icon: 'restaurant',
      ),
    ],
    sortBy: 'amount',
    total: 1,
  );

  final cashFlow = CashFlowAnalysis(
    totalIncome: '8000.00',
    totalExpense: '3000.00',
    netCashFlow: '5000.00',
    savingsRate: 62.5,
    expenseToIncomeRatio: 0.375,
    essentialExpenseRatio: 0.2,
    discretionaryExpenseRatio: 0.1,
    incomeChangePercent: 1.0,
    expenseChangePercent: -0.5,
    savingsRateChange: 2.0,
    periodStart: periodStart,
    periodEnd: periodEnd,
  );

  final healthScore = HealthScore(
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
    periodStart: periodStart,
    periodEnd: periodEnd,
  );

  /// Stub [NetworkClient.request] for a given path/type and record the query
  /// parameters that were forwarded, so each test can assert on them without
  /// needing mockito's named-argument capture API.
  void stubRequest<T>(String path, {required T result}) {
    when(
      mockNetworkClient.request<T>(
        path,
        method: HttpMethod.get,
        queryParameters: anyNamed('queryParameters'),
        fromJsonT: anyNamed('fromJsonT'),
      ),
    ).thenAnswer((invocation) async {
      lastQueryParams =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>?;
      return result;
    });
  }

  group('getOverview', () {
    test('sends default time_range and parses overview', () async {
      stubRequest<StatisticsOverview>('/statistics/overview', result: overview);

      final result = await service.getOverview();

      expect(lastQueryParams!['time_range'], 'month');
      expect(lastQueryParams!.containsKey('start_date'), isFalse);
      expect(result.totalBalance, '10000.00');
      expect(result.incomeChangePercent, 5.5);
    });

    test('includes custom date range and account types', () async {
      stubRequest<StatisticsOverview>('/statistics/overview', result: overview);

      final start = DateTime.utc(2026, 1, 1);
      final end = DateTime.utc(2026, 1, 31);
      await service.getOverview(
        timeRange: TimeRange.custom,
        startDate: start,
        endDate: end,
        accountTypes: ['cash', 'bank'],
      );

      expect(lastQueryParams!['time_range'], 'custom');
      // F3: dates are sent as plain `yyyy-MM-dd` (the server's "calendar day"
      // contract, same as the feed) — NOT ISO-8601 with a UTC offset, which
      // drifted boundary days for non-UTC users.
      expect(lastQueryParams!['start_date'], '2026-01-01');
      expect(lastQueryParams!['end_date'], '2026-01-31');
      expect(lastQueryParams!['account_types'], 'cash,bank');
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<StatisticsOverview>(
          '/statistics/overview',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getOverview(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getTrendData', () {
    test('sends time_range and transaction_type', () async {
      stubRequest<TrendDataResponse>('/statistics/trends', result: trend);

      final result = await service.getTrendData(
        timeRange: TimeRange.week,
        chartType: ChartType.expense,
      );

      expect(lastQueryParams!['time_range'], 'week');
      expect(lastQueryParams!['transaction_type'], 'expense');
      expect(result.dataPoints, hasLength(1));
    });

    test('handles empty dataPoints boundary', () async {
      stubRequest<TrendDataResponse>(
        '/statistics/trends',
        result: const TrendDataResponse(
          dataPoints: [],
          timeRange: 'month',
          transactionType: 'expense',
        ),
      );

      final result = await service.getTrendData(
        timeRange: TimeRange.month,
        chartType: ChartType.expense,
      );

      expect(result.dataPoints, isEmpty);
    });

    test('propagates business exception on failure', () async {
      when(
        mockNetworkClient.request<TrendDataResponse>(
          '/statistics/trends',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(BusinessException('backend error', 500));

      await expectLater(
        service.getTrendData(chartType: ChartType.income),
        throwsA(isA<BusinessException>()),
      );
    });
  });

  group('getCategoryBreakdown', () {
    test('sends limit and parses items', () async {
      stubRequest<CategoryBreakdownResponse>(
        '/statistics/categories',
        result: category,
      );

      final result = await service.getCategoryBreakdown(limit: 5);

      expect(lastQueryParams!['limit'], '5');
      expect(result.items, hasLength(1));
      expect(result.items.first.categoryKey, 'food');
    });

    test('defaults limit to 10', () async {
      stubRequest<CategoryBreakdownResponse>(
        '/statistics/categories',
        result: category,
      );

      await service.getCategoryBreakdown();

      expect(lastQueryParams!['limit'], '10');
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<CategoryBreakdownResponse>(
          '/statistics/categories',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getCategoryBreakdown(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getTopTransactions', () {
    test('sends sort/page/size and parses response', () async {
      stubRequest<TopTransactionsResponse>(
        '/statistics/top-transactions',
        result: topTransactions,
      );

      final result = await service.getTopTransactions(
        sortBy: SortType.amount,
        page: 2,
        pageSize: 5,
      );

      expect(lastQueryParams!['sort_by'], 'amount');
      expect(lastQueryParams!['page'], '2');
      expect(lastQueryParams!['size'], '5');
      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
    });

    test('defaults to page 1 size 10', () async {
      stubRequest<TopTransactionsResponse>(
        '/statistics/top-transactions',
        result: topTransactions,
      );

      await service.getTopTransactions();

      expect(lastQueryParams!['page'], '1');
      expect(lastQueryParams!['size'], '10');
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<TopTransactionsResponse>(
          '/statistics/top-transactions',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getTopTransactions(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getCashFlow', () {
    test('passes through raw timeRange string', () async {
      stubRequest<CashFlowAnalysis>('/statistics/cash-flow', result: cashFlow);

      final result = await service.getCashFlow(timeRange: TimeRange.week);

      expect(lastQueryParams!['time_range'], 'week');
      expect(result.savingsRate, 62.5);
      expect(result.netCashFlow, '5000.00');
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<CashFlowAnalysis>(
          '/statistics/cash-flow',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getCashFlow(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getHealthScore', () {
    test('parses health score response', () async {
      stubRequest<HealthScore>('/statistics/health-score', result: healthScore);

      final result = await service.getHealthScore(timeRange: TimeRange.month);

      expect(lastQueryParams!['time_range'], 'month');
      expect(result.totalScore, 82);
      expect(result.grade, 'B');
      expect(result.dimensions, hasLength(1));
    });

    test('handles empty suggestions and dimensions boundary', () async {
      stubRequest<HealthScore>(
        '/statistics/health-score',
        result: HealthScore(
          totalScore: 0,
          grade: 'F',
          dimensions: const [],
          suggestions: const <String>[],
          periodStart: periodStart,
          periodEnd: periodEnd,
        ),
      );

      final result = await service.getHealthScore();

      expect(result.dimensions, isEmpty);
      expect(result.suggestions, isEmpty);
    });

    test('propagates network exception on failure', () async {
      when(
        mockNetworkClient.request<HealthScore>(
          '/statistics/health-score',
          method: HttpMethod.get,
          queryParameters: anyNamed('queryParameters'),
          fromJsonT: anyNamed('fromJsonT'),
        ),
      ).thenThrow(NetworkException('Connection failed'));

      await expectLater(
        service.getHealthScore(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
