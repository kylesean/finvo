import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/finance/utils/recurrence_rule_utils.dart';
import 'package:finvo/i18n/strings.g.dart';

void main() {
  setUp(() async {
    // Initialize slang so t.* accessors work in unit tests.
    await LocaleSettings.setLocale(AppLocale.zh);
  });

  group('monthDaySuffix', () {
    test('ordinal suffix for English', () {
      expect(monthDayOrdinalSuffix(1), 'st');
      expect(monthDayOrdinalSuffix(2), 'nd');
      expect(monthDayOrdinalSuffix(3), 'rd');
      expect(monthDayOrdinalSuffix(4), 'th');
      expect(monthDayOrdinalSuffix(11), 'th');
      expect(monthDayOrdinalSuffix(12), 'th');
      expect(monthDayOrdinalSuffix(13), 'th');
      expect(monthDayOrdinalSuffix(21), 'st');
      expect(monthDayOrdinalSuffix(22), 'nd');
      expect(monthDayOrdinalSuffix(23), 'rd');
    });

    test('suffix is empty for non-English locales', () {
      expect(monthDaySuffix(1), '');
    });
  });

  group('parseUntilFromRule (C-1 round-trip)', () {
    test('date-only UNTIL round-trips to the same local date', () {
      const rule = 'FREQ=MONTHLY;BYMONTHDAY=1;UNTIL=20261231';
      final until = parseUntilFromRule(rule);
      expect(until, DateTime(2026, 12, 31));
    });

    test('legacy UTC UNTIL restores the local date', () {
      const rule = 'FREQ=MONTHLY;UNTIL=20261230T160000Z';
      final until = parseUntilFromRule(rule);
      // 2026-12-30T16:00Z converted to local time in test environment timezone
      final expectedLocal = DateTime.utc(2026, 12, 30, 16, 0, 0).toLocal();
      expect(until!.year, expectedLocal.year);
      expect(until.month, expectedLocal.month);
      expect(until.day, expectedLocal.day);
    });

    test('returns null when no UNTIL present', () {
      expect(parseUntilFromRule('FREQ=MONTHLY;BYMONTHDAY=1'), isNull);
    });
  });

  group('shortFrequencyLabel', () {
    test('maps each FREQ to its short label', () {
      expect(
        shortFrequencyLabel('FREQ=DAILY'),
        t.forecast.recurringTransaction.daily,
      );
      expect(
        shortFrequencyLabel('FREQ=WEEKLY'),
        t.forecast.recurringTransaction.weekly,
      );
      expect(
        shortFrequencyLabel('FREQ=MONTHLY'),
        t.forecast.recurringTransaction.monthly,
      );
      expect(
        shortFrequencyLabel('FREQ=YEARLY'),
        t.forecast.recurringTransaction.yearly,
      );
    });

    test('falls back to cycle for unknown rules', () {
      expect(
        shortFrequencyLabel('FREQ=HOURLY'),
        t.forecast.recurringTransaction.cycle,
      );
    });
  });

  group('describeRecurrenceRule', () {
    test('daily', () {
      expect(
        describeRecurrenceRule('FREQ=DAILY'),
        t.forecast.recurringTransaction.daily,
      );
      expect(
        describeRecurrenceRule('FREQ=DAILY;INTERVAL=2'),
        t.forecast.recurringTransaction.everyDays(count: 2),
      );
    });

    test('weekly', () {
      expect(
        describeRecurrenceRule('FREQ=WEEKLY'),
        t.forecast.recurringTransaction.weekly,
      );
      expect(
        describeRecurrenceRule('FREQ=WEEKLY;INTERVAL=3'),
        t.forecast.recurringTransaction.everyWeeks(count: 3),
      );
    });

    test('weekly with BYDAY enumerates weekdays in calendar order', () {
      final rt = t.forecast.recurringTransaction;
      // Serialized out of order (FR before MO) must display in calendar order.
      expect(
        describeRecurrenceRule('FREQ=WEEKLY;BYDAY=FR,MO,WE'),
        '${rt.weekly}${rt.weeklyDaysPrefix}'
        '${rt.weekdayOn}${rt.weekdayMon}${rt.weekdayJoiner}'
        '${rt.weekdayOn}${rt.weekdayWed}${rt.weekdayJoiner}'
        '${rt.weekdayOn}${rt.weekdayFri}',
      );
    });

    test('monthly on a specific day', () {
      expect(
        describeRecurrenceRule('FREQ=MONTHLY;BYMONTHDAY=15'),
        t.forecast.recurringTransaction.monthlyOnDay(
          day: '15',
          suffix: monthDaySuffix(15),
        ),
      );
    });

    test('monthly last day sentinel', () {
      expect(
        describeRecurrenceRule('FREQ=MONTHLY;BYMONTHDAY=-1'),
        t.forecast.recurringTransaction.monthlyLastDay,
      );
    });

    test('every N months', () {
      expect(
        describeRecurrenceRule('FREQ=MONTHLY;INTERVAL=2'),
        t.forecast.recurringTransaction.everyMonths(count: 2),
      );
    });

    test('yearly', () {
      expect(
        describeRecurrenceRule('FREQ=YEARLY'),
        t.forecast.recurringTransaction.yearly,
      );
    });

    test('yearly with BYMONTH/BYMONTHDAY describes the concrete date', () {
      expect(
        describeRecurrenceRule('FREQ=YEARLY;BYMONTH=8;BYMONTHDAY=15'),
        t.forecast.recurringTransaction.yearlyOn(month: 8, day: 15),
      );
      expect(
        describeRecurrenceRule(
          'FREQ=YEARLY;INTERVAL=2;BYMONTH=8;BYMONTHDAY=15',
        ),
        t.forecast.recurringTransaction.everyYearsOn(
          count: 2,
          month: 8,
          day: 15,
        ),
      );
    });

    test('unknown falls back to custom', () {
      expect(
        describeRecurrenceRule('FREQ=HOURLY'),
        t.forecast.recurringTransaction.custom,
      );
    });
  });

  group('updateRuleAndDescribe round-trip (C-1)', () {
    test('monthly rule updates BYMONTHDAY and description', () {
      final result = updateRuleAndDescribe(
        'FREQ=MONTHLY;BYMONTHDAY=1',
        DateTime(2026, 8, 20),
      );
      expect(result.rule, 'FREQ=MONTHLY;BYMONTHDAY=20');
      expect(
        result.description,
        t.forecast.recurringTransaction.monthlyOnDay(
          day: '20',
          suffix: monthDaySuffix(20),
        ),
      );
    });

    test('monthly last-day sentinel is preserved', () {
      final result = updateRuleAndDescribe(
        'FREQ=MONTHLY;BYMONTHDAY=-1',
        DateTime(2026, 8, 20),
      );
      expect(result.rule, 'FREQ=MONTHLY;BYMONTHDAY=-1');
      expect(
        result.description,
        t.forecast.recurringTransaction.monthlyLastDay,
      );
    });

    test('weekly rule follows the picked weekday', () {
      final result = updateRuleAndDescribe(
        'FREQ=WEEKLY;BYDAY=MO',
        DateTime(2026, 8, 20), // Thursday
      );
      expect(result.rule, 'FREQ=WEEKLY;BYDAY=TH');
    });

    test('non-monthly/weekly rule keeps rule and describes it', () {
      final result = updateRuleAndDescribe(
        'FREQ=YEARLY',
        DateTime(2026, 8, 20),
      );
      expect(result.rule, 'FREQ=YEARLY');
      expect(result.description, t.forecast.recurringTransaction.yearly);
    });
  });
}
