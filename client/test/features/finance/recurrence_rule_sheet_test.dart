import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/finance/widgets/recurrence_rule_types.dart';

void main() {
  group('recurrenceDateForMonthDay (C-1 regression)', () {
    test('monthDay -1 resolves to the real last day of the month', () {
      // Previously DateTime(year, month, -1) normalized into the PREVIOUS
      // month (DateTime(2026, 8, -1) == 2026-07-30).
      expect(recurrenceDateForMonthDay(2026, 8, -1), DateTime(2026, 8, 31));
      expect(recurrenceDateForMonthDay(2026, 3, -1), DateTime(2026, 3, 31));
      // February in a non-leap and a leap year.
      expect(recurrenceDateForMonthDay(2026, 2, -1), DateTime(2026, 2, 28));
      expect(recurrenceDateForMonthDay(2028, 2, -1), DateTime(2028, 2, 29));
    });

    test('monthDay -1 works across the December -> January rollover', () {
      // Callers pass month + 1 == 13 when rolling over past December:
      // month 13 is next year's January, whose last day is January 31.
      expect(recurrenceDateForMonthDay(2026, 13, -1), DateTime(2027, 1, 31));
      expect(recurrenceDateForMonthDay(2026, 12, -1), DateTime(2026, 12, 31));
    });

    test('regular month days are kept as-is', () {
      expect(recurrenceDateForMonthDay(2026, 8, 15), DateTime(2026, 8, 15));
      expect(recurrenceDateForMonthDay(2026, 8, 1), DateTime(2026, 8, 1));
      expect(recurrenceDateForMonthDay(2026, 8, 31), DateTime(2026, 8, 31));
    });

    test('month days beyond the month length are clamped, not overflowed', () {
      // DateTime(2026, 2, 31) would normalize to 2026-03-03.
      expect(recurrenceDateForMonthDay(2026, 2, 31), DateTime(2026, 2, 28));
      expect(recurrenceDateForMonthDay(2026, 4, 31), DateTime(2026, 4, 30));
    });
  });
}
