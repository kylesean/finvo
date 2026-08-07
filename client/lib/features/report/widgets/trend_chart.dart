import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/widgets/app_filter_chip.dart';

/// Redesigned TrendChart with income/expense toggle using FTabs
class TrendChart extends ConsumerWidget {
  final TrendDataResponse trendData;
  final ChartType chartType;
  final void Function(ChartType) onChartTypeChanged;

  const TrendChart({
    super.key,
    required this.trendData,
    required this.chartType,
    required this.onChartTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final amountTheme = ref.watch(currentAmountThemeProvider);

    final expenseColor = amountTheme.expenseColor;
    final incomeColor = amountTheme.incomeColor;
    final currentColor = chartType == ChartType.expense
        ? expenseColor
        : incomeColor;

    return AppCard(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.statistics.trend.title,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: AppFontConfig.titleSemibold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppFilterChip(
                    label: t.statistics.trend.expense,
                    isSelected: chartType == ChartType.expense,
                    onTap: () => onChartTypeChanged(ChartType.expense),
                  ),
                  const SizedBox(width: 8),
                  AppFilterChip(
                    label: t.statistics.trend.income,
                    isSelected: chartType == ChartType.income,
                    onTap: () => onChartTypeChanged(ChartType.income),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.border.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      // Calculate interval based on time range and data points
                      interval: _calculateLabelInterval(
                        trendData.dataPoints.length,
                        trendData.timeRange,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        // Skip if out of bounds or fractional
                        if (index < 0 ||
                            index >= trendData.dataPoints.length ||
                            value != index.toDouble()) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _formatLabel(
                              trendData.dataPoints[index].label,
                              trendData.timeRange,
                            ),
                            style: theme.typography.body.xs.copyWith(
                              color: colors.mutedForeground,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _buildLineData(trendData.dataPoints, currentColor, colors),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => colors.primary,
                    getTooltipItems: (touchedSpots) {
                      final currencyCode = ref
                          .read(financialSettingsProvider)
                          .primaryCurrency;
                      final currencySymbol =
                          Currency.fromCode(currencyCode)?.symbol ??
                          currencyCode;
                      return touchedSpots.map((spot) {
                        final label = chartType == ChartType.expense
                            ? t.statistics.trend.expense
                            : t.statistics.trend.income;
                        return LineTooltipItem(
                          '$label: $currencySymbol${AmountFormatter.getNumberFormat(currencyCode, decimalDigits: 0).format(spot.y)}',
                          theme.typography.body.xs.copyWith(
                            color: colors.primaryForeground,
                            fontWeight: AppFontConfig.headingBold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData(
    List<TrendDataPoint> points,
    Color color,
    FColors colors,
  ) {
    return LineChartBarData(
      spots: points.asMap().entries.map((e) {
        return FlSpot(
          e.key.toDouble(),
          AmountFormatter.parseDecimal(e.value.amount).toDouble(),
        );
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: colors.background,
          strokeWidth: 2,
          strokeColor: color,
        ),
        checkToShowDot: (spot, barData) => spot.x == barData.spots.last.x,
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  /// Calculate the interval for X-axis labels based on time range
  double _calculateLabelInterval(int dataPointsCount, String timeRange) {
    switch (timeRange.toLowerCase()) {
      case 'week':
        // Show all 7 days for week view
        return 1;
      case 'month':
        // For month view (~30 days), show about 5 labels to avoid overlap
        // Using interval of 7 gives us ~5 labels: 1, 8, 15, 22, 29
        if (dataPointsCount <= 7) return 1;
        if (dataPointsCount <= 14) return 2;
        return 7; // ~5 labels for 28-31 days, avoids first/last overlap
      case 'year':
        // For year view (12 months), show every 2nd month (6 labels)
        return 2;
      default:
        if (dataPointsCount <= 7) return 1;
        if (dataPointsCount <= 14) return 2;
        return 7;
    }
  }

  String _formatLabel(String label, String timeRange) {
    // Backend returns standard date strings (YYYY-MM-DD or YYYY-MM) as label
    try {
      DateTime date;
      if (label.length == 7) {
        // YYYY-MM
        date = DateFormat('yyyy-MM').parse(label);
      } else {
        date = DateTime.parse(label);
      }

      switch (timeRange.toLowerCase()) {
        case 'week':
          // Use localized weekday names from i18n
          final weekday = date.weekday;
          final weekdays = [
            t.calendar.weekdays.mon,
            t.calendar.weekdays.tue,
            t.calendar.weekdays.wed,
            t.calendar.weekdays.thu,
            t.calendar.weekdays.fri,
            t.calendar.weekdays.sat,
            t.calendar.weekdays.sun,
          ];
          return weekdays[weekday - 1];
        case 'month':
          // Return just the day number
          return '${date.day}';
        case 'year':
          // Return just the month number
          return '${date.month}';
        default:
          // For custom range, return day/month format
          return '${date.day}/${date.month}';
      }
    } catch (_) {
      return label;
    }
  }
}
