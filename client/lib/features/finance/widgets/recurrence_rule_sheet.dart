import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:logging/logging.dart';
import 'package:rrule/rrule.dart' as rrule_lib;
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/finance/utils/recurrence_rule_utils.dart';
import 'package:finvo/features/finance/widgets/recurrence_rule_types.dart';
import 'package:finvo/features/finance/widgets/recurrence_end_date_picker.dart';

final _logger = Logger('RecurrenceRuleSheet');

/// Recurrence rule settings bottom sheet
class RecurrenceRuleSheet extends StatefulWidget {
  final DateTime initialStartDate;
  final String? initialRule;

  const RecurrenceRuleSheet({
    super.key,
    required this.initialStartDate,
    this.initialRule,
  });

  /// Show the bottom sheet
  static Future<RecurrenceRuleResult?> show(
    BuildContext context, {
    required DateTime initialStartDate,
    String? initialRule,
  }) {
    return showModalBottomSheet<RecurrenceRuleResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecurrenceRuleSheet(
        initialStartDate: initialStartDate,
        initialRule: initialRule,
      ),
    );
  }

  @override
  State<RecurrenceRuleSheet> createState() => _RecurrenceRuleSheetState();
}

class _RecurrenceRuleSheetState extends State<RecurrenceRuleSheet> {
  /// Upper bound for the repeat interval. Without it the stepper could grow
  /// unbounded (e.g. "every 9999 weeks"), producing meaningless rules that
  /// the backend may reject.
  static const int _maxInterval = 365;

  // Currently selected frequency type
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;

  // Repeat interval
  int _interval = 1;

  // Start date
  late DateTime _startDate;

  // End date (optional)
  DateTime? _endDate;
  bool _hasEndDate = false;

  // Selected weekdays for weekly mode
  final Set<Weekday> _selectedWeekdays = {};

  // Selected day of month for monthly mode
  int _monthDay = 1;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _monthDay = _startDate.day;

    // Parse initial rule (if any). The rule string is persisted server-side,
    // so it must never crash this sheet: fall back to defaults on bad input.
    if (widget.initialRule != null) {
      try {
        _parseInitialRule(widget.initialRule!);
      } catch (e, stackTrace) {
        _logger.warning(
          'Failed to parse initial recurrence rule "${widget.initialRule}", falling back to defaults',
          e,
          stackTrace,
        );
        final today = DateTime.now().weekday;
        final weekday = Weekday.values.firstWhere((w) => w.isoWeekday == today);
        _selectedWeekdays.add(weekday);
      }
    } else {
      // Default to selecting current weekday
      final today = DateTime.now().weekday;
      final weekday = Weekday.values.firstWhere((w) => w.isoWeekday == today);
      _selectedWeekdays.add(weekday);
    }
  }

  void _parseInitialRule(String rule) {
    // Parse using rrule library
    final ruleString = rule.startsWith('RRULE:') ? rule : 'RRULE:$rule';
    final rrule = rrule_lib.RecurrenceRule.fromString(ruleString);

    // Parse frequency
    switch (rrule.frequency) {
      case rrule_lib.Frequency.daily:
        _frequency = RecurrenceFrequency.daily;
      case rrule_lib.Frequency.weekly:
        _frequency = RecurrenceFrequency.weekly;
      case rrule_lib.Frequency.monthly:
        _frequency = RecurrenceFrequency.monthly;
      case rrule_lib.Frequency.yearly:
        _frequency = RecurrenceFrequency.yearly;
      default:
        _frequency = RecurrenceFrequency.monthly;
    }

    // Parse interval (clamped: a malformed/legacy rule must not feed an
    // unbounded value into the stepper and the generated rule).
    _interval = (rrule.interval ?? 1).clamp(1, _maxInterval);

    // Parse weekdays (BYDAY)
    if (rrule.byWeekDays.isNotEmpty) {
      _selectedWeekdays.clear();
      for (final entry in rrule.byWeekDays) {
        final weekday = _getWeekdayFromDartWeekday(entry.day);
        if (weekday != null) {
          _selectedWeekdays.add(weekday);
        }
      }
    }

    // Parse month day (BYMONTHDAY)
    if (rrule.byMonthDays.isNotEmpty) {
      _monthDay = rrule.byMonthDays.first;
    }

    // Parse end date (UNTIL)
    if (rrule.until != null) {
      _hasEndDate = true;
      _endDate = rrule.until;
    }
  }

  /// Convert Dart weekday to Weekday enum
  Weekday? _getWeekdayFromDartWeekday(int dartWeekday) {
    return Weekday.values.cast<Weekday?>().firstWhere(
      (w) => w?.isoWeekday == dartWeekday,
      orElse: () => null,
    );
  }

  String _buildRruleString() {
    final parts = <String>['FREQ=${_frequency.rruleValue}'];

    if (_interval > 1) {
      parts.add('INTERVAL=$_interval');
    }

    switch (_frequency) {
      case RecurrenceFrequency.daily:
        break;
      case RecurrenceFrequency.weekly:
        if (_selectedWeekdays.isNotEmpty) {
          final days = _selectedWeekdays.map((w) => w.rruleValue).join(',');
          parts.add('BYDAY=$days');
        }
        break;
      case RecurrenceFrequency.monthly:
        parts.add('BYMONTHDAY=$_monthDay');
        break;
      case RecurrenceFrequency.yearly:
        // Persist the concrete month/day so the rule round-trips the same
        // specific date the preview shows (M-8: previously only FREQ=YEARLY
        // was stored while the preview displayed a concrete date).
        parts.add('BYMONTH=${_startDate.month}');
        parts.add('BYMONTHDAY=${_startDate.day}');
        break;
    }

    if (_hasEndDate && _endDate != null) {
      // Encode as a date-only value (RFC 5545 UNTIL=YYYYMMDD) using the
      // *local* date. Converting to UTC here (as before) shifts the date by
      // one day for non-UTC timezones (e.g. +08:00 2026-12-31 -> 2026-12-30T160000Z),
      // which then round-trips back as 2026-12-30. Date-only avoids the skew.
      final date = _endDate!;
      parts.add(
        'UNTIL=${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}',
      );
    }

    return parts.join(';');
  }

  String _buildDescription() {
    // M-8: delegate to the single shared formatter so the interactive preview
    // and the read-only page description can never diverge again.
    return describeRecurrenceRule(_buildRruleString());
  }

  /// English templates embed the ordinal suffix via [$suffix], other
  /// languages already include it in the template itself.
  String _monthDaySuffix(int day) => monthDaySuffix(day);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title bar
            _buildHeader(theme, colors),
            const SizedBox(height: 16),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Frequency type selector
                    _buildFrequencySelector(theme, colors),
                    const SizedBox(height: 24),
                    // Repeat interval
                    _buildIntervalSection(theme, colors),
                    const SizedBox(height: 24),
                    // Frequency-specific options
                    _buildFrequencySpecificOptions(theme, colors),
                    const SizedBox(height: 24),
                    // End date
                    _buildEndDateSection(theme, colors),
                    const SizedBox(height: 24),
                    // Rule preview
                    _buildRulePreview(theme, colors),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            // Bottom buttons
            _buildBottomBar(theme, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FThemeData theme, FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              t.common.cancel,
              style: theme.typography.body.md.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              t.budget.period,
              textAlign: TextAlign.center,
              style: AppTextStyles.listTitle(theme),
            ),
          ),
          GestureDetector(
            onTap: _handleConfirm,
            child: Text(t.common.ok, style: AppTextStyles.actionText(theme)),
          ),
        ],
      ),
    );
  }

  /// Frequency type selector - using FTabs component
  Widget _buildFrequencySelector(FThemeData theme, FColors colors) {
    return FTabs(
      control: .managed(
        initial: RecurrenceFrequency.values.indexOf(_frequency),
      ),
      onPress: (index) {
        setState(() => _frequency = RecurrenceFrequency.values[index]);
      },
      children: RecurrenceFrequency.values.map((freq) {
        return FTabEntry(
          label: Text(freq.label),
          child: const SizedBox.shrink(), // No content area needed
        );
      }).toList(),
    );
  }

  /// Repeat interval - single-row design
  Widget _buildIntervalSection(FThemeData theme, FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Left label
          Text(
            t.forecast.recurringTransaction.interval,
            style: theme.typography.body.sm.copyWith(color: colors.foreground),
          ),
          const Spacer(),
          // Right side: - number unit +
          // Decrease button
          GestureDetector(
            onTap: () {
              if (_interval > 1) {
                setState(() => _interval--);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Icon(
                  FLucideIcons.minus,
                  size: 16,
                  color: _interval > 1
                      ? colors.foreground
                      : colors.mutedForeground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Number + frequency unit
          Text(
            '$_interval ${_frequency.unitLabel(_interval)}',
            style: AppTextStyles.listTitle(theme),
          ),
          const SizedBox(width: 16),
          // Increase button
          GestureDetector(
            onTap: () {
              if (_interval < _maxInterval) {
                setState(() => _interval++);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Icon(
                  FLucideIcons.plus,
                  size: 16,
                  color: colors.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Frequency-specific options
  Widget _buildFrequencySpecificOptions(FThemeData theme, FColors colors) {
    switch (_frequency) {
      case RecurrenceFrequency.weekly:
        return _buildWeekdaySelector(theme, colors);
      case RecurrenceFrequency.monthly:
        return _buildMonthDayInfo(theme, colors);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Weekday selector
  Widget _buildWeekdaySelector(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.forecast.recurringTransaction.selectDays,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Weekday.values.map((weekday) {
            final isSelected = _selectedWeekdays.contains(weekday);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    // Guard the last selected weekday: a weekly rule without
                    // any BYDAY entry falls back to parser-dependent defaults,
                    // and the previous silent fallback to the (possibly past)
                    // start date's weekday surprised users.
                    if (_selectedWeekdays.length > 1) {
                      _selectedWeekdays.remove(weekday);
                    }
                  } else {
                    _selectedWeekdays.add(weekday);
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.muted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    weekday.label,
                    style: AppTextStyles.listTrailing(theme).copyWith(
                      color: isSelected
                          ? colors.primaryForeground
                          : colors.foreground,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Month day info (derived from start date or fixed last day)
  Widget _buildMonthDayInfo(FThemeData theme, FColors colors) {
    final isLastDaySelected = _monthDay == -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FLucideIcons.calendarDays,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isLastDaySelected
                          ? t.forecast.recurringTransaction.lastDayExecution
                          : t.forecast.recurringTransaction.dayExecution(
                              day: '${_startDate.day}',
                              suffix: _monthDaySuffix(_startDate.day),
                            ),
                      style: AppTextStyles.listTrailing(theme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.forecast.recurringTransaction.alwaysLastDay,
                    style: AppTextStyles.detailLabel(theme),
                  ),
                  FSwitch(
                    value: isLastDaySelected,
                    onChange: (value) {
                      setState(() {
                        _monthDay = value ? -1 : _startDate.day;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// End date section
  Widget _buildEndDateSection(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.dateRange.endDate, style: AppTextStyles.sectionHeader(theme)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.forecast.recurringTransaction.setEndDate,
                      style: AppTextStyles.listTrailing(theme),
                    ),
                  ),
                  FSwitch(
                    value: _hasEndDate,
                    onChange: (value) {
                      setState(() {
                        _hasEndDate = value;
                        if (value && _endDate == null) {
                          _endDate = _startDate.add(const Duration(days: 365));
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_hasEndDate) ...[
                const SizedBox(height: 12),
                // Tap to select end date
                GestureDetector(
                  onTap: () => _showEndDatePicker(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FLucideIcons.calendar,
                          size: 20,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _endDate != null
                                ? '${_endDate!.year}/${_endDate!.month}/${_endDate!.day}'
                                : t.forecast.recurringTransaction.selectEndDate,
                            style: theme.typography.body.sm.copyWith(
                              color: _endDate != null
                                  ? colors.foreground
                                  : colors.mutedForeground,
                            ),
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: 16,
                          color: colors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Rule preview section
  Widget _buildRulePreview(FThemeData theme, FColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FLucideIcons.repeat, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                t.forecast.recurringTransaction.preview,
                style: AppTextStyles.actionText(theme),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_buildDescription(), style: AppTextStyles.listTitle(theme)),
        ],
      ),
    );
  }

  /// Show end date picker (delegates to [RecurrenceEndDatePicker]).
  Future<void> _showEndDatePicker() async {
    final selectedDate = _endDate ?? _startDate.add(const Duration(days: 365));
    final picked = await RecurrenceEndDatePicker.show(
      context,
      selectedDate: selectedDate,
    );
    if (picked != null && mounted) {
      setState(() => _endDate = picked);
    }
  }

  /// Bottom button bar
  Widget _buildBottomBar(FThemeData theme, FColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: FButton(onPress: _handleConfirm, child: Text(t.common.ok)),
    );
  }

  void _handleConfirm() {
    if (_frequency == RecurrenceFrequency.weekly && _selectedWeekdays.isEmpty) {
      // Unreachable through the picker (last-selection guard) but possible
      // when a malformed parsed rule cleared the selection: fall back to the
      // start date's weekday instead of emitting an ambiguous BYDAY-less rule.
      final fallback = _getWeekdayFromDartWeekday(_startDate.weekday);
      if (fallback != null) {
        _selectedWeekdays.add(fallback);
      }
    }

    // Calculate adjusted start date based on rule
    final adjustedStartDate = _calculateAdjustedStartDate();

    Navigator.of(context).pop(
      RecurrenceRuleResult(
        rule: _buildRruleString(),
        description: _buildDescription(),
        startDate: adjustedStartDate,
        endDate: _hasEndDate ? _endDate : null,
      ),
    );
  }

  /// Calculate a reasonable start date based on current rule
  ///
  /// If user selects "8th of each month" but current date is the 15th,
  /// the start date should be the 8th of next month (first execution date)
  DateTime _calculateAdjustedStartDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_frequency) {
      case RecurrenceFrequency.monthly:
        // Calculate next occurrence of _monthDay.
        // `_monthDay == -1` means "last day of month" and must NOT be passed
        // to the DateTime constructor: Dart normalizes negative days into the
        // PREVIOUS month (DateTime(2026, 8, -1) == 2026-07-30), which would
        // shift the first execution date into the wrong month.
        DateTime targetDate = _dateForMonthDay(
          _startDate.year,
          _startDate.month,
          _monthDay,
        );

        // If target date has passed, move to next month
        if (targetDate.isBefore(today)) {
          targetDate = _dateForMonthDay(
            _startDate.year,
            _startDate.month + 1,
            _monthDay,
          );
        }
        return targetDate;

      case RecurrenceFrequency.weekly:
        // Calculate next selected weekday
        if (_selectedWeekdays.isNotEmpty) {
          final sortedDays = _selectedWeekdays.toList()
            ..sort((a, b) => a.isoWeekday.compareTo(b.isoWeekday));

          // Find next matching weekday
          for (int i = 0; i < 7; i++) {
            final checkDate = today.add(Duration(days: i));
            if (sortedDays.any((w) => w.isoWeekday == checkDate.weekday)) {
              return checkDate;
            }
          }
        }
        return _startDate;

      case RecurrenceFrequency.daily:
        // Daily execution, start from today or user-selected date
        return _startDate.isBefore(today) ? today : _startDate;

      case RecurrenceFrequency.yearly:
        // Yearly execution. Feb 29 start dates need explicit handling: in a
        // non-leap year Dart silently normalizes DateTime(year, 2, 29) to
        // March 1, so pin those occurrences to Feb 28 instead.
        DateTime targetDate = _yearlyDate(_startDate.year);
        if (targetDate.isBefore(today)) {
          targetDate = _yearlyDate(_startDate.year + 1);
        }
        return targetDate;
    }
  }

  /// Builds the yearly occurrence for [year]. A Feb 29 start date is pinned
  /// to Feb 28 in non-leap years (instead of Dart's implicit March 1
  /// normalization) so the first execution date stays predictable.
  DateTime _yearlyDate(int year) {
    final isLeapDay = _startDate.month == 2 && _startDate.day == 29;
    final isLeapYear = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    final day = isLeapDay && !isLeapYear ? 28 : _startDate.day;
    return DateTime(year, _startDate.month, day);
  }

  /// Delegates to the top-level [recurrenceDateForMonthDay] (see its docs).
  DateTime _dateForMonthDay(int year, int month, int monthDay) =>
      recurrenceDateForMonthDay(year, month, monthDay);
}
