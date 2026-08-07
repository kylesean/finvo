import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/app_calendar.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// End-date picker bottom sheet for the recurrence rule editor.
///
/// M-28: extracted from `RecurrenceRuleSheet` so the sheet stays focused on
/// building the rule while this helper owns the calendar row.
class RecurrenceEndDatePicker {
  RecurrenceEndDatePicker._();

  /// Show the picker and return the selected date (or null if dismissed).
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime selectedDate,
  }) {
    final theme = context.theme;
    final colors = theme.colors;
    final now = DateTime.now();

    return showModalBottomSheet<DateTime>(
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
                          Navigator.pop(context, date);
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
    );
  }
}
