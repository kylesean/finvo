import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/budget/models/budget_models.dart';
import 'package:finvo/features/budget/providers/budget_provider.dart';

void main() {
  group('BudgetFilter', () {
    test('active filter does not include paused', () {
      expect(BudgetFilter.active.includePaused, isFalse);
    });

    test('all filter includes paused', () {
      expect(BudgetFilter.all.includePaused, isTrue);
    });
  });

  group('BudgetSummaryState', () {
    test('default state has no summary and is not loading', () {
      const state = BudgetSummaryState();

      expect(state.summary, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasBudgets, isFalse);
    });

    test('copyWith updates isLoading', () {
      const state = BudgetSummaryState();
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, isTrue);
      expect(updated.summary, isNull);
      expect(updated.error, isNull);
    });

    test('copyWith updates summary', () {
      final summary = BudgetSummary(
        totalBudget: Decimal.fromInt(5000),
        totalSpent: Decimal.fromInt(2000),
        totalRemaining: Decimal.fromInt(3000),
        overallUsagePercentage: 40.0,
        budgets: [],
      );

      const state = BudgetSummaryState();
      final updated = state.copyWith(summary: summary, isLoading: false);

      expect(updated.summary, isNotNull);
      expect(updated.hasBudgets, isFalse); // empty budgets list
      expect(updated.summary!.totalBudget, Decimal.fromInt(5000));
    });

    test('copyWith sets error and clears previous error on new load', () {
      const state = BudgetSummaryState(error: 'old error');
      final loading = state.copyWith(isLoading: true, error: null);

      expect(loading.error, isNull);
      expect(loading.isLoading, isTrue);
    });

    test('hasBudgets true when summary has totalBudgetDetail', () {
      final summary = BudgetSummary(
        totalBudget: Decimal.fromInt(1000),
        totalSpent: Decimal.zero,
        totalRemaining: Decimal.fromInt(1000),
        overallUsagePercentage: 0.0,
        budgets: [],
        totalBudgetDetail: BudgetWithUsage(
          budget: Budget.fromJson({
            'id': '1',
            'name': 'Total Budget',
            'scope': 'TOTAL',
            'amount': '1000.00',
            'currency_code': 'CNY',
            'period_type': 'MONTHLY',
            'status': 'ACTIVE',
            'rollover_enabled': false,
            'rollover_balance': '0',
            'created_at': '2026-01-01T00:00:00',
            'updated_at': '2026-01-01T00:00:00',
          }),
          spentAmount: Decimal.zero,
          remainingAmount: Decimal.fromInt(1000),
          usagePercentage: 0.0,
          periodStatus: BudgetPeriodStatus.onTrack,
        ),
      );

      final state = BudgetSummaryState(summary: summary);
      expect(state.hasBudgets, isTrue);
    });
  });

  group('BudgetSummary model', () {
    test('fromJson parses complete response', () {
      final json = {
        'overall_spent': '2500.00',
        'overall_remaining': '7500.00',
        'overall_percentage': 25.0,
        'category_budgets': [
          {
            'id': 'b1',
            'name': 'Food Budget',
            'scope': 'CATEGORY',
            'category_key': 'food',
            'amount': '3000.00',
            'currency_code': 'CNY',
            'period_type': 'MONTHLY',
            'status': 'ACTIVE',
            'rollover_enabled': false,
            'rollover_balance': '0',
            'created_at': '2026-01-01T00:00:00',
            'updated_at': '2026-01-01T00:00:00',
            'spent_amount': '1500.00',
            'remaining_amount': '1500.00',
            'usage_percentage': 50.0,
          },
        ],
      };

      final summary = BudgetSummary.fromJson(json);

      expect(summary.totalSpent, Decimal.parse('2500.00'));
      expect(summary.totalRemaining, Decimal.parse('7500.00'));
      expect(summary.totalBudget, Decimal.parse('10000.00'));
      expect(summary.overallUsagePercentage, 25.0);
      expect(summary.budgets.length, 1);
      expect(summary.hasBudgets, isTrue);
    });

    test('fromJson handles empty response', () {
      final json = {
        'overall_spent': '0',
        'overall_remaining': '0',
        'overall_percentage': 0.0,
        'category_budgets': <dynamic>[],
      };

      final summary = BudgetSummary.fromJson(json);

      expect(summary.totalSpent, Decimal.zero);
      expect(summary.totalRemaining, Decimal.zero);
      expect(summary.budgets, isEmpty);
      expect(summary.hasBudgets, isFalse);
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'overall_spent': '100',
        'overall_remaining': '900',
      };

      final summary = BudgetSummary.fromJson(json);

      expect(summary.totalSpent, Decimal.parse('100'));
      expect(summary.overallUsagePercentage, 0.0);
      expect(summary.totalBudgetDetail, isNull);
    });

    test('usage percentage over 100 indicates overspending', () {
      final json = {
        'overall_spent': '12000.00',
        'overall_remaining': '-2000.00',
        'overall_percentage': 120.0,
        'category_budgets': <dynamic>[],
      };

      final summary = BudgetSummary.fromJson(json);

      expect(summary.overallUsagePercentage, greaterThan(100.0));
      expect(summary.totalRemaining < Decimal.zero, isTrue);
    });
  });
}
