import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:rrule/rrule.dart' as rrule_lib;
import 'package:finvo/shared/widgets/app_calendar.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

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

    // Parse initial rule (if any)
    if (widget.initialRule != null) {
      _parseInitialRule(widget.initialRule!);
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

    // Parse interval
    _interval = rrule.interval ?? 1;

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
      case RecurrenceFrequency.weekly:
        if (_selectedWeekdays.isNotEmpty) {
          final days = _selectedWeekdays.map((w) => w.rruleValue).join(',');
          parts.add('BYDAY=$days');
        }
      case RecurrenceFrequency.monthly:
        parts.add('BYMONTHDAY=$_monthDay');
      default:
        break;
    }

    if (_hasEndDate && _endDate != null) {
      final until = _endDate!
          .toUtc()
          .toIso8601String()
          .replaceAll('-', '')
          .replaceAll(':', '')
          .split('.')[0];
      parts.add('UNTIL=${until}Z');
    }

    return parts.join(';');
  }

  String _buildDescription() {
    final rt = t.forecast.recurringTransaction;
    final buffer = StringBuffer();

    switch (_frequency) {
      case RecurrenceFrequency.daily:
        buffer.write(
          _interval == 1 ? rt.daily : rt.everyDays(count: _interval),
        );
      case RecurrenceFrequency.weekly:
        buffer.write(
          _interval == 1 ? rt.weekly : rt.everyWeeks(count: _interval),
        );
        if (_selectedWeekdays.isNotEmpty) {
          final sortedDays = _selectedWeekdays.toList()
            ..sort((a, b) => a.isoWeekday.compareTo(b.isoWeekday));
          buffer.write(rt.weeklyDaysPrefix);
          buffer.write(
            sortedDays
                .map((w) => '${rt.weekdayOn}${w.label}')
                .join(rt.weekdayJoiner),
          );
        }
      case RecurrenceFrequency.monthly:
        if (_monthDay == -1) {
          buffer.write(
            _interval == 1
                ? rt.monthlyLastDay
                : rt.everyMonthsLastDay(count: _interval),
          );
        } else {
          if (_interval == 1) {
            buffer.write(
              rt.monthlyOnDay(
                day: '$_monthDay',
                suffix: _monthDaySuffix(_monthDay),
              ),
            );
          } else {
            buffer.write(
              rt.everyMonthsOnDay(
                count: _interval,
                day: '$_monthDay',
                suffix: _monthDaySuffix(_monthDay),
              ),
            );
          }
        }
      case RecurrenceFrequency.yearly:
        buffer.write(
          _interval == 1
              ? rt.yearlyOn(month: _startDate.month, day: _startDate.day)
              : rt.everyYearsOn(
                  count: _interval,
                  month: _startDate.month,
                  day: _startDate.day,
                ),
        );
    }

    return buffer.toString();
  }

  String _getDaySuffix(int day) {
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

  /// English templates embed the ordinal suffix via [$suffix], other
  /// languages already include it in the template itself.
  String _monthDaySuffix(int day) =>
      LocaleSettings.currentLocale == AppLocale.en ? _getDaySuffix(day) : '';

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
                  Icons.remove,
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
            onTap: () => setState(() => _interval++),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Icon(Icons.add, size: 16, color: colors.foreground),
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
                    _selectedWeekdays.remove(weekday);
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
                  onTap: () => _showEndDatePicker(theme, colors),
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

  /// Show end date picker (using FCalendar)
  void _showEndDatePicker(FThemeData theme, FColors colors) {
    final now = DateTime.now();
    final selectedDate = _endDate ?? _startDate.add(const Duration(days: 365));

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        t.dateRange.endDate,
                        style: AppTextStyles.listTitle(theme),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          FLucideIcons.x,
                          size: 20,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: AppCalendar.grid(
                      selectionControl: .liftedSingle(
                        value: selectedDate,
                        onChange: (date) {
                          if (date != null) {
                            setState(() => _endDate = date);
                            Navigator.pop(context);
                          }
                        },
                        toggleable: false,
                      ),
                      control: FGridCalendarControl(
                        start: now,
                        end: now.add(const Duration(days: 365 * 10)),
                        initial: selectedDate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
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
        // Calculate next occurrence of _monthDay
        DateTime targetDate = DateTime(
          _startDate.year,
          _startDate.month,
          _monthDay,
        );

        // If target date has passed, move to next month
        if (targetDate.isBefore(today)) {
          targetDate = DateTime(
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
        // Yearly execution
        DateTime targetDate = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
        );
        if (targetDate.isBefore(today)) {
          targetDate = DateTime(
            _startDate.year + 1,
            _startDate.month,
            _startDate.day,
          );
        }
        return targetDate;
    }
  }
}
