import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/finance/utils/recurring_form_validation.dart';

void main() {
  DateTime day(int d) => DateTime(2026, 9, d);

  group('validateRecurringForm', () {
    test('accepts a complete expense form', () {
      expect(
        validateRecurringForm(
          amountText: '100.50',
          isTransfer: false,
          sourceAccountId: 'acc-1',
          targetAccountId: null,
          startDate: day(1),
          endDate: day(30),
        ),
        isNull,
      );
    });

    test('rejects empty, garbage, zero, and negative amounts', () {
      for (final text in ['', 'abc', '0', '-5']) {
        expect(
          validateRecurringForm(
            amountText: text,
            isTransfer: false,
            sourceAccountId: 'acc-1',
            targetAccountId: null,
            startDate: day(1),
            endDate: null,
          ),
          RecurringFormError.invalidAmount,
        );
      }
    });

    test('expense without an account is missingAccount', () {
      expect(
        validateRecurringForm(
          amountText: '10',
          isTransfer: false,
          sourceAccountId: null,
          targetAccountId: null,
          startDate: day(1),
          endDate: null,
        ),
        RecurringFormError.missingAccount,
      );
    });

    test('transfer needs both accounts and rejects same account', () {
      final base = {'amountText': '10', 'startDate': day(1)};
      expect(
        validateRecurringForm(
          amountText: base['amountText'] as String,
          isTransfer: true,
          sourceAccountId: 'acc-1',
          targetAccountId: null,
          startDate: base['startDate'] as DateTime,
          endDate: null,
        ),
        RecurringFormError.missingAccount,
      );
      expect(
        validateRecurringForm(
          amountText: '10',
          isTransfer: true,
          sourceAccountId: 'acc-1',
          targetAccountId: 'acc-1',
          startDate: day(1),
          endDate: null,
        ),
        RecurringFormError.sameAccount,
      );
      expect(
        validateRecurringForm(
          amountText: '10',
          isTransfer: true,
          sourceAccountId: 'acc-1',
          targetAccountId: 'acc-2',
          startDate: day(1),
          endDate: null,
        ),
        isNull,
      );
    });

    test('end date before start date is endBeforeStart', () {
      expect(
        validateRecurringForm(
          amountText: '10',
          isTransfer: false,
          sourceAccountId: 'acc-1',
          targetAccountId: null,
          startDate: day(10),
          endDate: day(1),
        ),
        RecurringFormError.endBeforeStart,
      );
    });

    test('amount is checked before accounts and dates', () {
      expect(
        validateRecurringForm(
          amountText: 'bad',
          isTransfer: true,
          sourceAccountId: null,
          targetAccountId: null,
          startDate: day(10),
          endDate: day(1),
        ),
        RecurringFormError.invalidAmount,
      );
    });
  });
}
