import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/budget/models/budget_models.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';

void main() {
  // A minimal flat BudgetResponse entry, mirroring the backend shape that
  // BudgetWithUsage.fromBudgetResponse expects (Budget.fromJson reads these
  // keys from the same map).
  Map<String, dynamic> validBudgetResponse({
    String id = 'b1',
    String name = 'Food',
    String scope = 'CATEGORY',
  }) {
    return {
      'id': id,
      'name': name,
      'scope': scope,
      'amount': '500.00',
      'currency_code': 'CNY',
      'period_type': 'MONTHLY',
      'period_anchor_day': 1,
      'status': 'ACTIVE',
      'rollover_enabled': true,
      'rollover_balance': '0.00',
      'spent_amount': '50.00',
      'remaining_amount': '450.00',
      'usage_percentage': 10.0,
      'period_status': 'ON_TRACK',
    };
  }

  group('Budget tolerant parsing (M1)', () {
    test(
      'Budget.fromUnknown degrades to an empty budget for non-map input',
      () {
        expect(Budget.fromUnknown(null).id, '');
        expect(Budget.fromUnknown('not-a-map').amount, Decimal.zero);
        expect(Budget.fromUnknown(42).name, '');
        // A well-formed map is parsed normally.
        expect(Budget.fromUnknown(validBudgetResponse()).id, 'b1');
      },
    );

    test('BudgetWithUsage.fromJson tolerates a missing budget object', () {
      final parsed = BudgetWithUsage.fromJson({
        'spent_amount': '12.50',
        'remaining_amount': '87.50',
        'usage_percentage': 12.5,
        'period_status': 'ON_TRACK',
      });
      // Empty placeholder budget instead of a TypeError crash.
      expect(parsed.budget.amount, Decimal.zero);
      // Numeric fields still parse precisely.
      expect(parsed.spentAmount, Decimal.parse('12.50'));
      expect(parsed.remainingAmount, Decimal.parse('87.50'));
      expect(parsed.usagePercentage, 12.5);
    });

    test('BudgetWithUsage.fromJson tolerates a malformed current_period', () {
      final parsed = BudgetWithUsage.fromJson({
        'budget': {
          'id': 'b1',
          'name': 'Food',
          'scope': 'CATEGORY',
          'amount': '500.00',
          'period_type': 'MONTHLY',
          'status': 'ACTIVE',
        },
        'current_period': 'garbage',
      });
      expect(parsed.currentPeriod, isNull);
      expect(parsed.budget.id, 'b1');
    });

    test('BudgetSummary.fromJson skips malformed category budget entries', () {
      final parsed = BudgetSummary.fromJson({
        'category_budgets': [validBudgetResponse(), 'garbage', null, 42],
        'overall_spent': '50.00',
        'overall_remaining': '450.00',
        'overall_percentage': 10.0,
      });
      // Only the well-formed entry is kept; the junk is skipped, not fatal.
      expect(parsed.budgets.length, 1);
      expect(parsed.budgets.single.budget.id, 'b1');
      expect(parsed.totalBudget, Decimal.parse('500.00'));
      expect(parsed.totalSpent, Decimal.parse('50.00'));
      expect(parsed.overallUsagePercentage, 10.0);
    });

    test('BudgetSummary.fromJson tolerates a missing total_budget', () {
      final parsed = BudgetSummary.fromJson({
        'category_budgets': <Object?>[],
        'overall_spent': '1',
        'overall_remaining': '2',
        'overall_percentage': 0.0,
      });
      expect(parsed.totalBudgetDetail, isNull);
      expect(parsed.budgets, isEmpty);
      expect(parsed.totalBudget, Decimal.parse('3'));
    });
  });

  group('AmountFormatter.parseDecimalFromJson (M5)', () {
    test('normalizes null/empty/whitespace/non-numeric input to zero', () {
      expect(AmountFormatter.parseDecimalFromJson(null), Decimal.zero);
      expect(AmountFormatter.parseDecimalFromJson(''), Decimal.zero);
      expect(AmountFormatter.parseDecimalFromJson('   '), Decimal.zero);
      expect(AmountFormatter.parseDecimalFromJson('abc'), Decimal.zero);
      expect(AmountFormatter.parseDecimalFromJson(123), Decimal.parse('123'));
      expect(
        AmountFormatter.parseDecimalFromJson(' 12.50 '),
        Decimal.parse('12.50'),
      );
    });
  });
}
