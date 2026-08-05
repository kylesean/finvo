// features/home/widgets/calendar/daily_cell_widget.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/utils/heat_colors.dart';
import 'package:finvo/features/home/models/daily_expense_summary_model.dart';

class DailyCellWidget extends StatelessWidget {
  final DateTime day;
  final DailyExpenseSummaryModel? summary;
  final bool isSelected;
  final bool isToday;
  final bool isOutOfMonth;
  final VoidCallback? onTap;

  const DailyCellWidget({
    super.key,
    required this.day,
    this.summary,
    this.isSelected = false,
    this.isToday = false,
    this.isOutOfMonth = false,
    this.onTap,
  });

  // Helper method: Get background and text colors based on heat level and theme
  ({Color backgroundColor, Color textColor}) _getHeatColors(
    BuildContext context,
    ExpenseHeatLevel heatLevel,
  ) {
    final theme = context.theme;
    final colors = theme.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base color from which we derive different heat levels
    // Use primary as base for highest heat level as it's typically the most prominent theme color
    final baseHotColor = colors.primary;
    final baseHotForegroundColor = colors.primaryForeground;

    // Lowest heat text color
    final baseColdForegroundColor = colors.foreground;

    // Background resolved from the shared heat table (see HeatColorTables).
    final backgroundColor = heatLevelColor(
      heatLevel,
      table: HeatColorTables.cell,
      base: baseHotColor,
      background: colors.background,
      isDark: isDark,
    );

    // Foreground text color per heat level (kept here; only the background is
    // shared with the trend strip).
    final textColor = switch (heatLevel) {
      ExpenseHeatLevel.none => baseColdForegroundColor.withValues(alpha: 0.6),
      ExpenseHeatLevel.low =>
        isDark
            ? baseHotForegroundColor.withValues(alpha: 0.8)
            : baseHotColor.withValues(alpha: 0.8),
      ExpenseHeatLevel.medium =>
        isDark
            ? baseHotForegroundColor.withValues(alpha: 0.9)
            : baseHotColor.withValues(alpha: 0.9),
      ExpenseHeatLevel.high => baseHotForegroundColor,
      ExpenseHeatLevel.veryHigh => baseHotForegroundColor,
    };

    return (backgroundColor: backgroundColor, textColor: textColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    Color cellTextColor;
    Color? cellBackgroundColor;
    FontWeight cellFontWeight = FontWeight.normal;
    Border? cellEffectiveBorder;

    final cellRadius =
        theme.style.borderRadius.md.topLeft.x / 1.5; // Cell border radius

    if (isOutOfMonth) {
      cellTextColor = colors.mutedForeground.withValues(alpha: 0.4);
      cellBackgroundColor =
          Colors.transparent; // Transparent background for days outside month
      cellEffectiveBorder = Border.all(color: Colors.transparent, width: 0);
    } else {
      // Priority handling for selected and today status
      if (isSelected) {
        cellBackgroundColor = colors.primary;
        cellTextColor = colors.primaryForeground;
        cellFontWeight = FontWeight.bold;
        cellEffectiveBorder = Border.all(
          color: colors.primary, // Use primary color for selected state border
          width: 2, // Thicker border
        );
      } else if (isToday) {
        cellBackgroundColor =
            colors.secondary; // Use secondary background for today
        cellTextColor = colors.secondaryForeground;
        cellFontWeight = FontWeight.bold;
        cellEffectiveBorder = Border.all(
          color: colors.border, // Border for today
          width: 1,
        );
      } else {
        // If neither selected nor today, background and text color based on consumption heat
        if (summary != null && summary!.totalExpense >= 0) {
          // totalExpense >= 0 includes zero consumption case
          final heatColors = _getHeatColors(context, summary!.heatLevel);
          cellBackgroundColor = heatColors.backgroundColor;
          cellTextColor = heatColors.textColor;
          cellFontWeight = summary!.heatLevel == ExpenseHeatLevel.none
              ? FontWeight.normal
              : FontWeight
                    .w500; // Normal for no consumption, semi-bold for consumption
          cellEffectiveBorder = Border.all(
            // Give a default thin border or transparent border
            color: summary!.heatLevel == ExpenseHeatLevel.none
                ? Colors.transparent
                : colors.border.withValues(
                    alpha: 0.2,
                  ), // Light border when there's heat
            width: summary!.heatLevel == ExpenseHeatLevel.none ? 0 : 0.5,
          );
        } else {
          // Theoretically summary shouldn't be null here (due to orElse), but just in case
          cellBackgroundColor = Colors.transparent;
          cellTextColor = colors.foreground;
          cellEffectiveBorder = Border.all(color: Colors.transparent, width: 0);
        }
      }
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: FButton.raw(
        variant: .ghost,
        onPress: (!isOutOfMonth && onTap != null) ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: cellBackgroundColor,
            border: cellEffectiveBorder,
            borderRadius: BorderRadius.circular(cellRadius),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.typography.body.sm.copyWith(
                color: cellTextColor, // Apply calculated text color
                fontWeight: cellFontWeight,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
