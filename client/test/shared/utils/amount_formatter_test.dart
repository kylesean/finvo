import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/features/home/models/transaction_model.dart';

void main() {
  // Ensure consistent locale for NumberFormat
  Intl.defaultLocale = 'zh_CN';

  group('AmountFormatter.formatTransaction', () {
    test('expense shows negative sign with CNY symbol', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.expense,
        amount: 123.45,
      );
      expect(result, contains('-'));
      expect(result, contains('¥'));
      expect(result, contains('123.45'));
    });

    test('income shows positive sign', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.income,
        amount: 100.00,
      );
      expect(result, startsWith('+'));
      expect(result, contains('¥'));
    });

    test('transfer has no sign', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.transfer,
        amount: 500.00,
      );
      expect(result, isNot(startsWith('+')));
      expect(result, isNot(startsWith('-')));
      expect(result, contains('¥'));
    });

    test('other type has no sign', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.other,
        amount: 42.00,
      );
      expect(result, isNot(startsWith('+')));
      expect(result, isNot(startsWith('-')));
    });

    test('showSign false omits sign for expense', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.expense,
        amount: 99.99,
        showSign: false,
      );
      expect(result, isNot(contains('-')));
      expect(result, isNot(contains('+')));
      expect(result, contains('¥'));
    });

    test('negative input uses absolute value', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.expense,
        amount: -200.00,
      );
      // Should still format as -¥200.00 (abs of -200 = 200)
      expect(result, contains('200.00'));
      expect(result, startsWith('-'));
    });

    test('zero amount formats correctly', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.expense,
        amount: 0.0,
      );
      expect(result, contains('0.00'));
    });

    test('large amount includes thousand separators', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.income,
        amount: 1234567.89,
      );
      // zh_CN locale uses comma as thousand separator
      expect(result, contains(','));
    });

    test('USD currency uses dollar symbol', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.expense,
        amount: 50.00,
        currency: 'USD',
      );
      expect(result, contains('\$'));
    });

    test('EUR currency uses euro symbol', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.income,
        amount: 75.00,
        currency: 'EUR',
      );
      expect(result, contains('€'));
    });

    test('compact format for large amounts', () {
      final result = AmountFormatter.formatTransaction(
        type: TransactionType.income,
        amount: 50000.00,
        compact: true,
      );
      // With zh_CN default locale, should contain 万
      expect(result, contains('万'));
    });
  });

  group('AmountFormatter.formatCommon', () {
    test('formats without sign', () {
      final result = AmountFormatter.formatCommon(123.45);
      expect(result, isNot(contains('+')));
      expect(result, isNot(contains('-')));
      expect(result, contains('¥'));
      expect(result, contains('123.45'));
    });

    test('negative input uses absolute value', () {
      final result = AmountFormatter.formatCommon(-99.99);
      expect(result, isNot(contains('-')));
      expect(result, contains('99.99'));
    });

    test('custom currency code', () {
      final result = AmountFormatter.formatCommon(100.0, currencyCode: 'GBP');
      expect(result, contains('£'));
    });
  });

  group('AmountFormatter.formatCompact', () {
    test('Chinese locale: below 10000 shows raw number', () {
      final result = AmountFormatter.formatCompact(9999.99, locale: 'zh_CN');
      expect(result, '9999.99');
    });

    test('Chinese locale: 10000+ shows 万', () {
      final result = AmountFormatter.formatCompact(50000.0, locale: 'zh_CN');
      expect(result, '5.0万');
    });

    test('Chinese locale: 100000000+ shows 亿', () {
      final result = AmountFormatter.formatCompact(
        250000000.0,
        locale: 'zh_CN',
      );
      expect(result, '2.5亿');
    });

    test('International locale: below 1000 shows raw number', () {
      final result = AmountFormatter.formatCompact(999.0, locale: 'en_US');
      expect(result, '999.00');
    });

    test('International locale: 1000+ shows K', () {
      final result = AmountFormatter.formatCompact(5000.0, locale: 'en_US');
      expect(result, '5.0K');
    });

    test('International locale: 1000000+ shows M', () {
      final result = AmountFormatter.formatCompact(2500000.0, locale: 'en_US');
      expect(result, '2.5M');
    });

    test('International locale: 1000000000+ shows B', () {
      final result = AmountFormatter.formatCompact(
        1500000000.0,
        locale: 'en_US',
      );
      expect(result, '1.5B');
    });
  });

  group('AmountFormatter.formatBudgetCompact', () {
    test('formats amounts >= 10000 with wan suffix and sign', () {
      expect(
        AmountFormatter.formatBudgetCompact(Decimal.parse('20000')),
        contains('2.0'),
      );
      expect(
        AmountFormatter.formatBudgetCompact(Decimal.parse('-20000')),
        startsWith('-'),
      );
    });

    test('formats amounts < 10000 with thousand separators', () {
      expect(
        AmountFormatter.formatBudgetCompact(Decimal.parse('1500')),
        equals('1,500'),
      );
      expect(
        AmountFormatter.formatBudgetCompact(Decimal.parse('1500.50')),
        equals('1,500.50'),
      );
    });
  });

  group('AmountFormatter.getAmountColor', () {
    test('expense returns theme expense color', () {
      final color = AmountFormatter.getAmountColor(
        TransactionType.expense,
        AmountTheme.chinaMarket,
      );
      expect(color, AmountTheme.chinaMarket.expenseColor);
    });

    test('income returns theme income color', () {
      final color = AmountFormatter.getAmountColor(
        TransactionType.income,
        AmountTheme.international,
      );
      expect(color, AmountTheme.international.incomeColor);
    });

    test('transfer returns theme transfer color', () {
      final color = AmountFormatter.getAmountColor(
        TransactionType.transfer,
        AmountTheme.chinaMarket,
      );
      expect(color, AmountTheme.chinaMarket.transferColor);
    });

    test('other returns theme neutral color', () {
      final color = AmountFormatter.getAmountColor(
        TransactionType.other,
        AmountTheme.chinaMarket,
      );
      expect(color, AmountTheme.chinaMarket.neutralColor);
    });
  });

  group('AmountFormatter.getAmountColorFromString', () {
    test('parses EXPENSE string case-insensitively', () {
      final color = AmountFormatter.getAmountColorFromString(
        'expense',
        AmountTheme.chinaMarket,
      );
      expect(color, AmountTheme.chinaMarket.expenseColor);
    });

    test('parses INCOME string', () {
      final color = AmountFormatter.getAmountColorFromString(
        'INCOME',
        AmountTheme.international,
      );
      expect(color, AmountTheme.international.incomeColor);
    });

    test('unknown string defaults to neutral', () {
      final color = AmountFormatter.getAmountColorFromString(
        'unknown_type',
        AmountTheme.chinaMarket,
      );
      expect(color, AmountTheme.chinaMarket.neutralColor);
    });
  });

  group('AmountFormatter.getCurrencySymbol', () {
    test('CNY returns ¥', () {
      expect(AmountFormatter.getCurrencySymbol('CNY'), '¥');
    });

    test('USD returns \$', () {
      expect(AmountFormatter.getCurrencySymbol('USD'), '\$');
    });

    test('EUR returns €', () {
      expect(AmountFormatter.getCurrencySymbol('EUR'), '€');
    });

    test('GBP returns £', () {
      expect(AmountFormatter.getCurrencySymbol('GBP'), '£');
    });

    test('JPY returns ¥', () {
      expect(AmountFormatter.getCurrencySymbol('JPY'), '¥');
    });

    test('HKD returns HK\$', () {
      expect(AmountFormatter.getCurrencySymbol('HKD'), 'HK\$');
    });

    test('TWD returns NT\$', () {
      expect(AmountFormatter.getCurrencySymbol('TWD'), 'NT\$');
    });

    test('KRW returns ₩', () {
      expect(AmountFormatter.getCurrencySymbol('KRW'), '₩');
    });

    test('unknown currency returns code as fallback', () {
      expect(AmountFormatter.getCurrencySymbol('XYZ'), 'XYZ');
    });

    test('case insensitive lookup', () {
      expect(AmountFormatter.getCurrencySymbol('cny'), '¥');
    });
  });

  group('AmountFormatter.getAmountSign', () {
    test('expense returns -', () {
      expect(AmountFormatter.getAmountSign(TransactionType.expense), '-');
    });

    test('income returns +', () {
      expect(AmountFormatter.getAmountSign(TransactionType.income), '+');
    });

    test('transfer returns empty', () {
      expect(AmountFormatter.getAmountSign(TransactionType.transfer), '');
    });

    test('other returns empty', () {
      expect(AmountFormatter.getAmountSign(TransactionType.other), '');
    });
  });

  group('AmountFormatter boolean helpers', () {
    test('isNegativeAmount true only for expense', () {
      expect(AmountFormatter.isNegativeAmount(TransactionType.expense), isTrue);
      expect(AmountFormatter.isNegativeAmount(TransactionType.income), isFalse);
      expect(
        AmountFormatter.isNegativeAmount(TransactionType.transfer),
        isFalse,
      );
    });

    test('isPositiveAmount true only for income', () {
      expect(AmountFormatter.isPositiveAmount(TransactionType.income), isTrue);
      expect(
        AmountFormatter.isPositiveAmount(TransactionType.expense),
        isFalse,
      );
      expect(
        AmountFormatter.isPositiveAmount(TransactionType.transfer),
        isFalse,
      );
    });
  });

  group('AmountFormatter.parseDecimal', () {
    test('parses a plain decimal string', () {
      expect(AmountFormatter.parseDecimal('123.45'), Decimal.parse('123.45'));
    });

    test('parses an integer string', () {
      expect(AmountFormatter.parseDecimal('100'), Decimal.fromInt(100));
    });

    test('parses negative amounts', () {
      expect(AmountFormatter.parseDecimal('-50.5'), Decimal.parse('-50.5'));
    });

    test('falls back to zero for null', () {
      expect(AmountFormatter.parseDecimal(null), Decimal.zero);
    });

    test('falls back to zero for empty string', () {
      expect(AmountFormatter.parseDecimal(''), Decimal.zero);
    });

    test('falls back to zero for non-numeric input', () {
      expect(AmountFormatter.parseDecimal('abc'), Decimal.zero);
    });

    // Regression guard for H-1: summing many backend amount strings through
    // Decimal (instead of double.tryParse) must not accumulate the classic
    // 0.1 + 0.2 floating-point error.
    test('summation stays exact (no float drift)', () {
      final amounts = ['0.1', '0.2', '0.1', '0.2', '0.1', '0.2'];
      final decimalSum = amounts.fold<Decimal>(
        Decimal.zero,
        (acc, s) => acc + AmountFormatter.parseDecimal(s),
      );
      // Decimal accumulation is exact.
      expect(decimalSum, Decimal.parse('0.9'));

      // Contrast: the same sum through double.tryParse drifts away from 0.9.
      final doubleSum = amounts.fold<double>(
        0,
        (acc, s) => acc + (double.tryParse(s) ?? 0),
      );
      expect(doubleSum, isNot(equals(0.9)));
    });
  });
}
