import 'package:finvo/i18n/strings.g.dart';

/// Ordinal suffix for English templates ('st'/'nd'/'rd'/'th').
///
/// Previously duplicated as `_getDaySuffix(String)` in
/// [recurring_transaction_page] and `_getDaySuffix(int)` in
/// [recurrence_rule_sheet]. Converged here (M-8) so RRULE formatting stays in
/// one place.
String monthDayOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

/// English templates embed the ordinal suffix via [$suffix], other languages
/// already include it in the template itself.
String monthDaySuffix(int day) => LocaleSettings.currentLocale == AppLocale.en
    ? monthDayOrdinalSuffix(day)
    : '';

/// Parse the UNTIL value from an RRULE string.
///
/// Two forms must be handled:
///   - date-only:  UNTIL=20261231      (current writer, no timezone skew)
///   - date-time:  UNTIL=20261230T160000Z (legacy UTC-encoded writer)
/// For the legacy UTC form, restore the local date so the user sees the same
/// day they originally picked (previously the T...Z offset was dropped,
/// shifting +08:00 users one day earlier).
///
/// M-8: extracted from `RecurringTransactionPage._loadEditData`.
DateTime? parseUntilFromRule(String rule) {
  final match = RegExp(
    r'UNTIL=(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})Z)?',
  ).firstMatch(rule);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (match.group(4) != null) {
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);
    return DateTime.utc(year, month, day, hour, minute, second).toLocal();
  }
  return DateTime(year, month, day);
}

/// Short frequency label for list rows.
///
/// M-8: extracted from `RecurringTransactionListPage._getShortFrequencyLabel`.
String shortFrequencyLabel(String rule) {
  final rt = t.forecast.recurringTransaction;
  if (rule.contains('FREQ=DAILY')) return rt.daily;
  if (rule.contains('FREQ=WEEKLY')) return rt.weekly;
  if (rule.contains('FREQ=MONTHLY')) return rt.monthly;
  if (rule.contains('FREQ=YEARLY')) return rt.yearly;
  return rt.cycle;
}

/// Human-readable description of an RRULE string.
///
/// M-8: extracted from `RecurringTransactionPage._parseRecurrenceDescription`.
String describeRecurrenceRule(String rule) {
  final rt = t.forecast.recurringTransaction;
  final interval = _intervalOf(rule);

  if (rule.contains('FREQ=DAILY')) {
    return interval == 1 ? rt.daily : rt.everyDays(count: interval);
  } else if (rule.contains('FREQ=WEEKLY')) {
    final base = interval == 1 ? rt.weekly : rt.everyWeeks(count: interval);
    // Enumerate the selected weekdays (BYDAY) so the read-only description
    // matches the interactive sheet preview. M-8: converged from the sheet's
    // enum-based `_buildDescription`.
    final byDay = _byDayOf(rule);
    if (byDay.isEmpty) {
      return base;
    }
    final days = byDay
        .map((code) => '${rt.weekdayOn}${_weekdayLabel(code)}')
        .join(rt.weekdayJoiner);
    return '$base${rt.weeklyDaysPrefix}$days';
  } else if (rule.contains('FREQ=MONTHLY')) {
    // BYMONTHDAY can be negative: -1 is the "last day of month" sentinel.
    final day = _byMonthDayOf(rule);
    if (day == -1) {
      return interval == 1
          ? rt.monthlyLastDay
          : rt.everyMonthsLastDay(count: interval);
    }
    if (day != null) {
      return interval == 1
          ? rt.monthlyOnDay(day: '$day', suffix: monthDaySuffix(day))
          : rt.everyMonthsOnDay(
              count: interval,
              day: '$day',
              suffix: monthDaySuffix(day),
            );
    }
    return interval == 1 ? rt.monthly : rt.everyMonths(count: interval);
  } else if (rule.contains('FREQ=YEARLY')) {
    // When the rule carries BYMONTH/BYMONTHDAY, describe the specific date;
    // otherwise fall back to a plain "every year" label.
    final month = _byMonthOf(rule);
    final day = _byMonthDayOf(rule);
    if (month != null && day != null) {
      return interval == 1
          ? rt.yearlyOn(month: month, day: day)
          : rt.everyYearsOn(count: interval, month: month, day: day);
    }
    return rt.yearly;
  }
  return rt.custom;
}

/// Update both the RRULE string and its human-readable description when the
/// start date changes.
///
/// Returns the new rule and description. For a monthly rule BYMONTHDAY is
/// rewritten (preserving the -1 "last day of month" sentinel); for a weekly
/// rule BYDAY follows the picked weekday.
///
/// M-8: extracted from `RecurringTransactionPage._updateRecurrenceRuleWithNewDate`.
({String rule, String description}) updateRuleAndDescribe(
  String rule,
  DateTime newDate,
) {
  if (rule.contains('FREQ=MONTHLY')) {
    // Preserve the "last day of month" sentinel (-1) untouched.
    if (rule.contains('BYMONTHDAY=-1')) {
      return (rule: rule, description: describeRecurrenceRule(rule));
    }
    var updated = rule;
    if (updated.contains('BYMONTHDAY')) {
      updated = updated.replaceAllMapped(
        RegExp(r'BYMONTHDAY=-?\d+'),
        (match) => 'BYMONTHDAY=${newDate.day}',
      );
    } else {
      updated += ';BYMONTHDAY=${newDate.day}';
    }
    return (rule: updated, description: describeRecurrenceRule(updated));
  } else if (rule.contains('FREQ=WEEKLY')) {
    const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    final weekdayIndex = newDate.weekday - 1;
    var updated = rule;
    if (updated.contains('BYDAY')) {
      updated = updated.replaceAllMapped(
        RegExp(r'BYDAY=[A-Z,]+'),
        (match) => 'BYDAY=${weekdays[weekdayIndex]}',
      );
    } else {
      updated += ';BYDAY=${weekdays[weekdayIndex]}';
    }
    return (rule: updated, description: describeRecurrenceRule(updated));
  }
  return (rule: rule, description: describeRecurrenceRule(rule));
}

int _intervalOf(String rule) {
  final match = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
  return match != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
}

const _weekdayOrder = {
  'MO': 0,
  'TU': 1,
  'WE': 2,
  'TH': 3,
  'FR': 4,
  'SA': 5,
  'SU': 6,
};

/// Parse and sort the BYDAY weekday codes (RFC 5545: MO/TU/.../SU) from a rule
/// so the description lists weekdays in calendar order regardless of how they
/// were serialized.
List<String> _byDayOf(String rule) {
  final match = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(rule);
  if (match == null) return const [];
  return match.group(1)!.split(',').where((e) => e.isNotEmpty).toList()
    ..sort((a, b) => (_weekdayOrder[a] ?? 7).compareTo(_weekdayOrder[b] ?? 7));
}

int? _byMonthOf(String rule) {
  final match = RegExp(r'BYMONTH=(1[0-2]|[1-9])').firstMatch(rule);
  return match != null ? int.tryParse(match.group(1)!) : null;
}

int? _byMonthDayOf(String rule) {
  final match = RegExp(r'BYMONTHDAY=(-?\d+)').firstMatch(rule);
  return match != null ? int.tryParse(match.group(1)!) : null;
}

String _weekdayLabel(String code) {
  final rt = t.forecast.recurringTransaction;
  switch (code) {
    case 'MO':
      return rt.weekdayMon;
    case 'TU':
      return rt.weekdayTue;
    case 'WE':
      return rt.weekdayWed;
    case 'TH':
      return rt.weekdayThu;
    case 'FR':
      return rt.weekdayFri;
    case 'SA':
      return rt.weekdaySat;
    case 'SU':
      return rt.weekdaySun;
    default:
      return code;
  }
}
