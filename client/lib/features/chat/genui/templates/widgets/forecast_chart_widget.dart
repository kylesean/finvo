import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class ForecastDataPoint {
  final DateTime date;
  final double predictedBalance;
  final double lowerBound;
  final double upperBound;
  final List<Map<String, dynamic>> events;

  ForecastDataPoint({
    required this.date,
    required this.predictedBalance,
    required this.lowerBound,
    required this.upperBound,
    required this.events,
  });

  factory ForecastDataPoint.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    final eventsRaw = json['events'];
    final events = eventsRaw is List
        ? eventsRaw
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    return ForecastDataPoint(
      date: parseDate(json['date']),
      predictedBalance: asDouble(json['predicted_balance']),
      lowerBound: asDouble(json['lower_bound']),
      upperBound: asDouble(json['upper_bound']),
      events: events,
    );
  }
}

class ForecastChartWidget extends StatelessWidget {
  final List<ForecastDataPoint> dataPoints;
  final bool showConfidenceInterval;
  final String Function(dynamic amount) formatAmount;

  const ForecastChartWidget({
    super.key,
    required this.dataPoints,
    this.showConfidenceInterval = true,
    required this.formatAmount,
  });

  ({double minY, double maxY}) _safeChartRange(List<double> allValues) {
    if (allValues.isEmpty) return (minY: 0, maxY: 100);
    var minY = allValues.reduce((a, b) => a < b ? a : b);
    var maxY = allValues.reduce((a, b) => a > b ? a : b);
    if (maxY == minY) {
      maxY += 100;
      minY -= 100;
    }
    return (minY: minY, maxY: maxY);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    if (dataPoints.isEmpty) {
      return Center(
        child: Text(
          t.chat.genui.cashFlowForecast.noData,
          style: AppTextStyles.listSubtitle(theme),
        ),
      );
    }

    final spots = <FlSpot>[];
    final lowerSpots = <FlSpot>[];
    final upperSpots = <FlSpot>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      spots.add(FlSpot(i.toDouble(), point.predictedBalance));
      lowerSpots.add(FlSpot(i.toDouble(), point.lowerBound));
      upperSpots.add(FlSpot(i.toDouble(), point.upperBound));
    }

    final range = _safeChartRange([
      ...dataPoints.map((p) => p.predictedBalance),
      ...dataPoints.map((p) => p.lowerBound),
      ...dataPoints.map((p) => p.upperBound),
    ]);
    final minY = range.minY;
    final maxY = range.maxY;
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colors.border.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    formatAmount(value),
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (dataPoints.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dataPoints.length) {
                  final date = dataPoints[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: [
          if (showConfidenceInterval)
            LineChartBarData(
              spots: upperSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withValues(alpha: 0.1),
              ),
            ),
          if (showConfidenceInterval)
            LineChartBarData(
              spots: lowerSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(show: true, color: colors.background),
            ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < dataPoints.length) {
                  final point = dataPoints[index];
                  return LineTooltipItem(
                    '${DateFormat('M/d').format(point.date)}\n¥${formatAmount(point.predictedBalance)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
      transformationConfig: const FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        minScale: 1.0,
        maxScale: 3.0,
        panEnabled: true,
        scaleEnabled: true,
      ),
    );
  }
}
