import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:finvo/shared/widgets/app_calendar.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class DateRangePickerSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime start, DateTime end) onConfirm;

  const DateRangePickerSheet({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onConfirm,
  });

  /// Show date range picker
  static Future<void> show(
    BuildContext context, {
    DateTime? initialStart,
    DateTime? initialEnd,
    required void Function(DateTime start, DateTime end) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  (DateTime, DateTime)? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialStart != null && widget.initialEnd != null
        ? (widget.initialStart!, widget.initialEnd!)
        : null;
  }

  String _formatDateRange((DateTime, DateTime)? range) {
    if (range == null) return t.dateRange.hint;
    final format = DateFormat('yyyy.MM.dd');
    return '${format.format(range.$1)} - ${format.format(range.$2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(theme.style.borderRadius.xl.topLeft.x),
          topRight: Radius.circular(theme.style.borderRadius.xl.topRight.x),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header Row (Title, Active Date Range Subtitle, Close Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.dateRange.pickerTitle,
                          style: theme.typography.body.lg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                        ),
                        if (_selectedRange != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FLucideIcons.calendar,
                                size: 14,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDateRange(_selectedRange),
                                style: AppTextStyles.actionText(theme),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  FButton.icon(
                    variant: .ghost,
                    onPress: () => Navigator.pop(context),
                    child: Icon(FLucideIcons.x, color: colors.foreground),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppCalendar.grid(
                  selectionControl: .liftedRange(
                    value: _selectedRange,
                    onChange: (range) => setState(() => _selectedRange = range),
                  ),
                  control: FGridCalendarControl(
                    start: DateTime.now().subtract(
                      const Duration(days: 365 * 2),
                    ),
                    end: DateTime.now(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FButton(
                        variant: .outline,
                        onPress: () {
                          setState(() {
                            _selectedRange = null;
                          });
                        },
                        child: Text(t.common.reset),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FButton(
                        onPress: _selectedRange != null
                            ? () {
                                final range = _selectedRange;
                                if (range != null) {
                                  Navigator.pop(context);
                                  widget.onConfirm(range.$1, range.$2);
                                }
                              }
                            : null,
                        child: Text(t.common.confirm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
