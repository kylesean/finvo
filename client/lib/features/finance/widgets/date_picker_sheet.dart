import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/app_calendar.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Date picker bottom sheet (uses FCalendar)
class DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String title;

  const DatePickerSheet({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.title = '',
  });

  /// Show sheet
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = '',
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerSheet(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
      ),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
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
            // Title bar
            _buildHeader(theme, colors),
            const SizedBox(height: 8),
            // Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppCalendar.grid(
                  selectionControl: .liftedSingle(
                    value: _selectedDate,
                    onChange: (date) {
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    toggleable: false,
                  ),
                  control: FGridCalendarControl(
                    start: widget.firstDate ?? DateTime(2020),
                    end: widget.lastDate ?? DateTime(2030),
                    initial: _selectedDate,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Bottom button
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
              widget.title.isNotEmpty ? widget.title : t.time.selectDate,
              textAlign: TextAlign.center,
              style: AppTextStyles.listTitle(theme),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_selectedDate),
            child: Text(t.common.ok, style: AppTextStyles.actionText(theme)),
          ),
        ],
      ),
    );
  }

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
      child: FButton(
        onPress: () => Navigator.of(context).pop(_selectedDate),
        child: Text(
          t.forecast.recurringTransaction.selectDate(
            date:
                '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
          ),
        ),
      ),
    );
  }
}
