import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/report/models/statistics_models.dart';

void main() {
  group('TimeRange / ChartType / SortType', () {
    test('JsonValue names match JsonValue strings', () {
      expect(
        TimeRange.values.map((e) => e.name),
        unorderedEquals(['week', 'month', 'year', 'custom']),
      );
      expect(
        ChartType.values.map((e) => e.name),
        unorderedEquals(['expense', 'income']),
      );
      expect(
        SortType.values.map((e) => e.name),
        unorderedEquals(['amount', 'date']),
      );
    });
  });

  group('StatisticsOverview.fromJson', () {
    test('parses full response and numeric change percents', () {
      final json = {
        'totalBalance': '10000.00',
        'totalIncome': '8000.00',
        'totalExpense': '3000.00',
        'incomeChangePercent': 5.5,
        'expenseChangePercent': -2.0,
        'netChangePercent': 3.2,
        'balanceNote': 'Healthy',
        'periodStart': '2026-01-01T00:00:00Z',
        'periodEnd': '2026-01-31T23:59:59Z',
      };

      final overview = StatisticsOverview.fromJson(json);

      expect(overview.totalBalance, '10000.00');
      expect(overview.incomeChangePercent, 5.5);
      expect(overview.balanceNote, 'Healthy');
      expect(overview.periodStart, DateTime.utc(2026, 1, 1));
    });

    test('balanceNote defaults to empty string when omitted', () {
      final json = {
        'totalBalance': '1.00',
        'totalIncome': '1.00',
        'totalExpense': '0.00',
        'incomeChangePercent': 0.0,
        'expenseChangePercent': 0.0,
        'netChangePercent': 0.0,
        'periodStart': '2026-01-01T00:00:00Z',
        'periodEnd': '2026-01-31T23:59:59Z',
      };

      final overview = StatisticsOverview.fromJson(json);

      expect(overview.balanceNote, '');
    });

    test('amount extensions parse strings via Decimal', () {
      final overview = StatisticsOverview(
        totalBalance: '10000.00',
        totalIncome: '8000.50',
        totalExpense: '1999.50',
        incomeChangePercent: 0.0,
        expenseChangePercent: 0.0,
        netChangePercent: 0.0,
        periodStart: DateTime.utc(2026, 1, 1),
        periodEnd: DateTime.utc(2026, 1, 31),
      );

      expect(overview.balanceNum, 10000.00);
      expect(overview.incomeNum, 8000.50);
      expect(overview.expenseNum, 1999.50);
    });
  });

  group('TrendDataResponse.fromJson', () {
    test('parses nested data points', () {
      final json = {
        'dataPoints': [
          {'date': '2026-01-01', 'amount': '100.00', 'label': 'Jan 1'},
          {'date': '2026-01-02', 'amount': '200.00', 'label': 'Jan 2'},
        ],
        'timeRange': 'week',
        'transactionType': 'expense',
      };

      final result = TrendDataResponse.fromJson(json);

      expect(result.dataPoints, hasLength(2));
      expect(result.dataPoints.first.amountNum, 100.00);
      expect(result.dataPoints.last.amountNum, 200.00);
    });

    test('handles empty dataPoints list', () {
      final json = {
        'dataPoints': <Object>[],
        'timeRange': 'month',
        'transactionType': 'income',
      };

      final result = TrendDataResponse.fromJson(json);

      expect(result.dataPoints, isEmpty);
    });
  });

  group('CategoryBreakdownResponse.fromJson', () {
    test('parses items and exposes amountNum', () {
      final json = {
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
      };

      final result = CategoryBreakdownResponse.fromJson(json);

      expect(result.items, hasLength(1));
      expect(result.items.first.categoryKey, 'food');
      expect(result.items.first.amountNum, 120.50);
      expect(result.total, '120.50');
    });
  });

  group('TopTransactionsResponse.fromJson', () {
    test('applies defaults for page/pageSize/hasMore', () {
      final json = {
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
      };

      final result = TopTransactionsResponse.fromJson(json);

      expect(result.page, 1);
      expect(result.pageSize, 10);
      expect(result.hasMore, isFalse);
      expect(result.items.first.transactionAt, DateTime.utc(2026, 1, 1, 12));
    });

    test('parses explicit page flags', () {
      final json = {
        'items': <Object>[],
        'sortBy': 'date',
        'total': 0,
        'page': 2,
        'pageSize': 5,
        'hasMore': true,
      };

      final result = TopTransactionsResponse.fromJson(json);

      expect(result.page, 2);
      expect(result.pageSize, 5);
      expect(result.hasMore, isTrue);
    });
  });

  group('CashFlowAnalysis.fromJson', () {
    test('applies defaults for ratio fields', () {
      final json = {
        'totalIncome': '8000.00',
        'totalExpense': '3000.00',
        'netCashFlow': '5000.00',
        'savingsRate': 62.5,
        'expenseToIncomeRatio': 0.375,
        'incomeChangePercent': 1.0,
        'expenseChangePercent': -0.5,
        'savingsRateChange': 2.0,
        'periodStart': '2026-01-01T00:00:00Z',
        'periodEnd': '2026-01-31T23:59:59Z',
      };

      final result = CashFlowAnalysis.fromJson(json);

      expect(result.essentialExpenseRatio, 0.0);
      expect(result.discretionaryExpenseRatio, 0.0);
      expect(result.netCashFlow, '5000.00');
    });
  });

  group('HealthScore.fromJson', () {
    test('suggestions default to empty list when omitted', () {
      final json = {
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
        'periodStart': '2026-01-01T00:00:00Z',
        'periodEnd': '2026-01-31T23:59:59Z',
      };

      final result = HealthScore.fromJson(json);

      expect(result.suggestions, isEmpty);
      expect(result.dimensions, hasLength(1));
      expect(result.dimensions.first.name, 'Saving');
    });
  });
}
