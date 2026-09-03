import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/budget/utils/budget_form_validation.dart';

void main() {
  group('parseBudgetAmount', () {
    test('parses plain and decimal input', () {
      expect(parseBudgetAmount('100'), Decimal.fromInt(100));
      expect(parseBudgetAmount(' 99.50 '), Decimal.parse('99.50'));
    });

    test('rejects empty, garbage, zero, and negative input', () {
      for (final text in ['', 'abc', '0', '0.00', '-5']) {
        expect(parseBudgetAmount(text), isNull, reason: text);
      }
    });
  });
}
