import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/services/statistics_service.dart';

void main() {
  late Dio dio;
  late NetworkClient networkClient;
  late StatisticsService service;
  late RequestOptions lastRequest;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
    networkClient = NetworkClient(dio);
    service = StatisticsService(networkClient);
  });

  void mockResponse(Map<String, dynamic> response) {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: response,
              statusCode: 200,
            ),
          );
        },
      ),
    );
  }

  const overviewData = {
    'data': {
      'totalBalance': '10000.00',
      'totalIncome': '8000.00',
      'totalExpense': '3000.00',
      'incomeChangePercent': 5.5,
      'expenseChangePercent': -2.0,
      'netChangePercent': 3.2,
      'balanceNote': 'Healthy',
      'periodStart': '2026-01-01T00:00:00Z',
      'periodEnd': '2026-01-31T23:59:59Z',
    },
  };

  group('getOverview', () {
    test('sends default time_range and parses overview', () async {
      mockResponse(overviewData);

      final result = await service.getOverview();

      expect(lastRequest.path, '/statistics/overview');
      expect(lastRequest.queryParameters['time_range'], 'month');
      expect(lastRequest.queryParameters.containsKey('start_date'), isFalse);
      expect(result.totalBalance, '10000.00');
      expect(result.incomeChangePercent, 5.5);
    });

    test('includes custom date range and account types', () async {
      mockResponse(overviewData);

      final start = DateTime.utc(2026, 1, 1);
      final end = DateTime.utc(2026, 1, 31);
      await service.getOverview(
        timeRange: TimeRange.custom,
        startDate: start,
        endDate: end,
        accountTypes: ['cash', 'bank'],
      );

      final params = lastRequest.queryParameters;
      expect(params['time_range'], 'custom');
      expect(params['start_date'], start.toIso8601String());
      expect(params['end_date'], end.toIso8601String());
      expect(params['account_types'], 'cash,bank');
    });
  });

  group('getTrendData', () {
    test('sends time_range and transaction_type', () async {
      mockResponse({
        'data': {
          'dataPoints': [
            {'date': '2026-01-01', 'amount': '100.00', 'label': 'Jan 1'},
          ],
          'timeRange': 'week',
          'transactionType': 'expense',
        },
      });

      final result = await service.getTrendData(
        timeRange: TimeRange.week,
        chartType: ChartType.expense,
      );

      expect(lastRequest.path, '/statistics/trends');
      expect(lastRequest.queryParameters['time_range'], 'week');
      expect(lastRequest.queryParameters['transaction_type'], 'expense');
      expect(result.dataPoints, hasLength(1));
    });
  });

  group('getCategoryBreakdown', () {
    test('sends limit and parses items', () async {
      mockResponse({
        'data': {
          'items': [
            {
              'categoryKey': 'food',
              'categoryName': 'Food',
              'amount': '120.50',
              'percentage': 40.0,
              'color': '#ff0000',
              'icon': 'restaurant',
            },
          ],
          'total': '120.50',
        },
      });

      final result = await service.getCategoryBreakdown(limit: 5);

      expect(lastRequest.path, '/statistics/categories');
      expect(lastRequest.queryParameters['limit'], '5');
      expect(result.items, hasLength(1));
      expect(result.items.first.categoryKey, 'food');
    });
  });

  group('getTopTransactions', () {
    test('sends sort/page/size and parses response', () async {
      mockResponse({
        'data': {
          'items': [
            {
              'id': 't1',
              'description': 'Dinner',
              'amount': '300.00',
              'categoryKey': 'food',
              'categoryName': 'Food',
              'transactionAt': '2026-01-01T12:00:00Z',
              'icon': 'restaurant',
            },
          ],
          'sortBy': 'amount',
          'total': 1,
          'page': 2,
          'pageSize': 5,
          'hasMore': false,
        },
      });

      final result = await service.getTopTransactions(
        sortBy: SortType.amount,
        page: 2,
        pageSize: 5,
      );

      expect(lastRequest.path, '/statistics/top-transactions');
      expect(lastRequest.queryParameters['sort_by'], 'amount');
      expect(lastRequest.queryParameters['page'], '2');
      expect(lastRequest.queryParameters['size'], '5');
      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
    });
  });

  group('getCashFlow', () {
    test('passes through raw timeRange string', () async {
      mockResponse({
        'data': {
          'totalIncome': '8000.00',
          'totalExpense': '3000.00',
          'netCashFlow': '5000.00',
          'savingsRate': 62.5,
          'expenseToIncomeRatio': 0.375,
          'essentialExpenseRatio': 0.2,
          'discretionaryExpenseRatio': 0.1,
          'incomeChangePercent': 1.0,
          'expenseChangePercent': -0.5,
          'savingsRateChange': 2.0,
          'periodStart': '2026-01-01T00:00:00Z',
          'periodEnd': '2026-01-31T23:59:59Z',
        },
      });

      final result = await service.getCashFlow(timeRange: TimeRange.week);

      expect(lastRequest.queryParameters['time_range'], 'week');
      expect(result.savingsRate, 62.5);
      expect(result.netCashFlow, '5000.00');
    });
  });

  group('getHealthScore', () {
    test('parses health score response', () async {
      mockResponse({
        'data': {
          'totalScore': 82,
          'grade': 'B',
          'dimensions': [
            {
              'name': 'Saving',
              'score': 80,
              'weight': 0.5,
              'description': 'ok',
              'status': 'good',
            },
          ],
          'suggestions': ['Save more'],
          'periodStart': '2026-01-01T00:00:00Z',
          'periodEnd': '2026-01-31T23:59:59Z',
        },
      });

      final result = await service.getHealthScore(timeRange: TimeRange.month);

      expect(lastRequest.path, '/statistics/health-score');
      expect(result.totalScore, 82);
      expect(result.grade, 'B');
      expect(result.dimensions, hasLength(1));
    });
  });
}
