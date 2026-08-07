import 'package:finvo/i18n/strings.g.dart';

/// Resolve a date for [monthDay] within [year]/[month].
///
/// [monthDay] == -1 is the "last day of month" sentinel and resolves to the
/// real last day (day 0 of the next month); values 29-31 are clamped so
/// short months (e.g. February) don't overflow into the next month.
///
/// Exposed at top level so it can be regression tested: Dart normalizes
/// negative days into the PREVIOUS month (DateTime(2026, 8, -1) == 2026-07-30),
/// which silently produced wrong first-execution dates for "last day of
/// month" rules.
///
/// M-28: moved here from `RecurrenceRuleSheet`.
DateTime recurrenceDateForMonthDay(int year, int month, int monthDay) {
  if (monthDay == -1) {
    return DateTime(year, month + 1, 0);
  }
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, monthDay.clamp(1, lastDay));
}

/// Recurrence rule result
class RecurrenceRuleResult {
  final String rule;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;

  const RecurrenceRuleResult({
    required this.rule,
    required this.description,
    required this.startDate,
    this.endDate,
  });
}

/// Recurrence frequency type
enum RecurrenceFrequency {
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY');

  final String rruleValue;

  const RecurrenceFrequency(this.rruleValue);

  String get label {
    final rt = t.forecast.recurringTransaction;
    switch (this) {
      case daily:
        return rt.daily;
      case weekly:
        return rt.weekly;
      case monthly:
        return rt.monthly;
      case yearly:
        return rt.yearly;
    }
  }

  /// Unit label used after an interval count, e.g. "2 Days" / "2 天"
  String unitLabel(int count) {
    final rt = t.forecast.recurringTransaction;
    switch (this) {
      case daily:
        return rt.dayUnit(count: count);
      case weekly:
        return rt.weekUnit(count: count);
      case monthly:
        return rt.monthUnit(count: count);
      case yearly:
        return rt.yearUnit(count: count);
    }
  }
}

/// Day of week
enum Weekday {
  monday('MO', 1),
  tuesday('TU', 2),
  wednesday('WE', 3),
  thursday('TH', 4),
  friday('FR', 5),
  saturday('SA', 6),
  sunday('SU', 7);

  final String rruleValue;
  final int isoWeekday;

  const Weekday(this.rruleValue, this.isoWeekday);

  String get label {
    final rt = t.forecast.recurringTransaction;
    switch (this) {
      case monday:
        return rt.weekdayMon;
      case tuesday:
        return rt.weekdayTue;
      case wednesday:
        return rt.weekdayWed;
      case thursday:
        return rt.weekdayThu;
      case friday:
        return rt.weekdayFri;
      case saturday:
        return rt.weekdaySat;
      case sunday:
        return rt.weekdaySun;
    }
  }
}
