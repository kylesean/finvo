import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:forui/forui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Cash flow forecast chart - GenUI Template
///
/// Displays user's future cash flow forecast in AI chat.
/// Includes:
/// - Line chart (predicted balance curve + confidence interval)
/// - Key event markers
/// - Warning information
/// Cached ViewModel for CashFlowForecastChart data payload
@immutable
class _CashFlowForecastViewModel {
  final String title;
  final List<_ForecastDataPoint> dataPoints;
  final List<_ForecastWarning> warnings;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? forecastPeriod;
  final double currentBalance;

  const _CashFlowForecastViewModel({
    required this.title,
    required this.dataPoints,
    required this.warnings,
    required this.summary,
    required this.forecastPeriod,
    required this.currentBalance,
  });

  factory _CashFlowForecastViewModel.fromRawMap(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? '';

    final points = data['data_points'];
    final dataPoints = points is List
        ? points
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (p) =>
                    _ForecastDataPoint.fromJson(Map<String, dynamic>.from(p)),
              )
              .toList()
        : const <_ForecastDataPoint>[];

    final warningsRaw = data['warnings'];
    final warnings = warningsRaw is List
        ? warningsRaw
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (w) => _ForecastWarning.fromJson(Map<String, dynamic>.from(w)),
              )
              .toList()
        : const <_ForecastWarning>[];

    final summaryRaw = data['summary'];
    final summary = summaryRaw is Map
        ? Map<String, dynamic>.from(summaryRaw)
        : null;

    final periodRaw = data['forecast_period'];
    final forecastPeriod = periodRaw is Map
        ? Map<String, dynamic>.from(periodRaw)
        : null;

    final balance = data['current_balance'];
    final double currentBalance;
    if (balance is num) {
      currentBalance = balance.toDouble();
    } else if (balance is String) {
      currentBalance = double.tryParse(balance) ?? 0;
    } else {
      currentBalance = 0;
    }

    return _CashFlowForecastViewModel(
      title: title,
      dataPoints: dataPoints,
      warnings: warnings,
      summary: summary,
      forecastPeriod: forecastPeriod,
      currentBalance: currentBalance,
    );
  }
}

class CashFlowForecastChart extends StatefulWidget {
  final Map<String, dynamic> data;

  const CashFlowForecastChart({super.key, required this.data});

  @override
  State<CashFlowForecastChart> createState() => _CashFlowForecastChartState();
}

class _CashFlowForecastChartState extends State<CashFlowForecastChart> {
  late _CashFlowForecastViewModel _viewModel;
  bool _isExpanded = false;
  final bool _showConfidenceInterval = true;

  @override
  void initState() {
    super.initState();
    _parseViewModel();
  }

  @override
  void didUpdateWidget(covariant CashFlowForecastChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _parseViewModel();
    }
  }

  void _parseViewModel() {
    _viewModel = _CashFlowForecastViewModel.fromRawMap(widget.data);
  }

  List<_ForecastDataPoint> get _dataPoints => _viewModel.dataPoints;
  List<_ForecastWarning> get _warnings => _viewModel.warnings;
  Map<String, dynamic>? get _summary => _viewModel.summary;
  Map<String, dynamic>? get _forecastPeriod => _viewModel.forecastPeriod;
  double get _currentBalance => _viewModel.currentBalance;

  String _formatAmount(dynamic amount) {
    final numberFormat = AmountFormatter.getNumberFormat(
      'CNY',
      decimalDigits: 0,
    );
    if (amount is String) {
      return numberFormat.format(double.tryParse(amount) ?? 0);
    }
    if (amount is num) {
      return numberFormat.format(amount.toDouble());
    }
    return numberFormat.format(double.tryParse(amount?.toString() ?? '') ?? 0);
  }

  /// Safely coerce an event's amount (AI payloads may use strings).
  double _eventAmount(Map<String, dynamic> event) {
    final value = event['amount'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Localize event description
  /// Attempts to convert category_key or type to localized display text
  String _localizeDescription(String? description) {
    if (description == null || description.isEmpty) {
      return t.chat.genui.cashFlowForecast.recurringTransaction;
    }

    final upper = description.toUpperCase();

    // 1. Check if it's a transaction type (INCOME, EXPENSE, TRANSFER)
    switch (upper) {
      case 'INCOME':
        return t.chat.genui.cashFlowForecast.recurringIncome;
      case 'EXPENSE':
        return t.chat.genui.cashFlowForecast.recurringExpense;
      case 'TRANSFER':
        return t.chat.genui.cashFlowForecast.recurringTransfer;
    }

    // 2. Check if it's a valid category key
    final category = TransactionCategory.fromKey(upper);
    // fromKey returns 'others' when not found, verify it actually matches
    if (category.key == upper) {
      return category.displayText;
    }

    // 3. Return original description (may be user-defined)
    return description;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = context.theme;
        final colors = theme.colors;
        final amountTheme = ref.watch(currentAmountThemeProvider);
        final hasWarnings = _warnings.isNotEmpty;

        return GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasWarnings
                    ? amountTheme.expenseColor.withValues(alpha: 0.5)
                    : colors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, amountTheme, hasWarnings),

                // Chart Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(height: 180, child: _buildChart(context)),
                ),

                // Warnings (if any)
                if (hasWarnings) _buildWarnings(context, amountTheme),

                // Expanded Details
                if (_isExpanded) _buildExpandedDetails(context, amountTheme),

                // Expand indicator
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      _isExpanded
                          ? FLucideIcons.chevronUp
                          : FLucideIcons.chevronDown,
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AmountTheme amountTheme,
    bool hasWarnings,
  ) {
    final theme = context.theme;
    final colors = theme.colors;
    final days = _forecastPeriod?['days'] ?? 30;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasWarnings
                      ? amountTheme.expenseColor.withValues(alpha: 0.1)
                      : colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasWarnings ? FLucideIcons.info : FLucideIcons.trendingUp,
                  size: 16,
                  color: hasWarnings
                      ? amountTheme.expenseColor
                      : colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['title']?.toString() ??
                        t.chat.genui.cashFlowForecast.title,
                    style: AppTextStyles.listTrailing(theme),
                  ),
                  Text(
                    t.chat.genui.cashFlowForecast.nextDays(
                      days: days as Object,
                    ),
                    style: AppTextStyles.detailLabel(theme),
                  ),
                ],
              ),
            ],
          ),
          // Current balance badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '¥${_formatAmount(_currentBalance)}',
              style: AppTextStyles.listTrailing(
                theme,
              ).copyWith(color: colors.secondaryForeground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    if (_dataPoints.isEmpty) {
      return Center(
        child: Text(
          t.chat.genui.cashFlowForecast.noData,
          style: AppTextStyles.listSubtitle(theme),
        ),
      );
    }

    // Prepare chart data
    final spots = <FlSpot>[];
    final lowerSpots = <FlSpot>[];
    final upperSpots = <FlSpot>[];

    for (int i = 0; i < _dataPoints.length; i++) {
      final point = _dataPoints[i];
      spots.add(FlSpot(i.toDouble(), point.predictedBalance));
      lowerSpots.add(FlSpot(i.toDouble(), point.lowerBound));
      upperSpots.add(FlSpot(i.toDouble(), point.upperBound));
    }

    // Calculate Y axis range
    final range = _safeChartRange([
      ..._dataPoints.map((p) => p.predictedBalance),
      ..._dataPoints.map((p) => p.lowerBound),
      ..._dataPoints.map((p) => p.upperBound),
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
                    _formatAmount(value),
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
              interval: (_dataPoints.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _dataPoints.length) {
                  final date = _dataPoints[index].date;
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
          // Confidence interval (filled area between upper and lower)
          if (_showConfidenceInterval)
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
          if (_showConfidenceInterval)
            LineChartBarData(
              spots: lowerSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              belowBarData: BarAreaData(show: true, color: colors.background),
            ),
          // Main prediction line
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
                if (index >= 0 && index < _dataPoints.length) {
                  final point = _dataPoints[index];
                  return LineTooltipItem(
                    '${DateFormat('M/d').format(point.date)}\n¥${_formatAmount(point.predictedBalance)}',
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
      // Enable zoom and pan gestures (fl_chart 0.70.0+)
      transformationConfig: const FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal, // Horizontal-only zoom
        minScale: 1.0,
        maxScale: 3.0, // Max 3x zoom
        panEnabled: true,
        scaleEnabled: true,
      ),
    );
  }

  Widget _buildWarnings(BuildContext context, AmountTheme amountTheme) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amountTheme.expenseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: amountTheme.expenseColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _warnings.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.info,
                  size: 14,
                  color: amountTheme.expenseColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning.message,
                    style: theme.typography.body.xs.copyWith(
                      color: amountTheme.expenseColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, AmountTheme amountTheme) {
    final theme = context.theme;
    final summary = _summary;

    if (summary == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            t.chat.genui.cashFlowForecast.summary,
            style: AppTextStyles.listTrailing(theme),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.recurringIncome,
                  value: summary['total_recurring_income'],
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.recurringExpense,
                  value: summary['total_recurring_expense'],
                  isPositive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.variableExpense,
                  value: summary['predicted_variable_expense'],
                  isPositive: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.netChange,
                  value: summary['net_change'],
                  isPositive: ((summary['net_change'] as num?) ?? 0) >= 0,
                ),
              ),
            ],
          ),

          // Key events section
          if (_dataPoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              t.chat.genui.cashFlowForecast.keyEvents,
              style: AppTextStyles.listTrailing(theme),
            ),
            const SizedBox(height: 8),
            ..._buildKeyEvents(context, amountTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    AmountTheme amountTheme, {
    required String label,
    required dynamic value,
    required bool isPositive,
  }) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.detailLabel(theme)),
          const SizedBox(height: 4),
          Text(
            '¥${_formatAmount(value)}',
            style: AppTextStyles.listTrailing(theme).copyWith(
              color: isPositive
                  ? amountTheme.incomeColor
                  : amountTheme.expenseColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKeyEvents(BuildContext context, AmountTheme amountTheme) {
    final theme = context.theme;
    final colors = theme.colors;

    // Collect significant events (recurring with amount > 500)
    // Deduplicate by source_id, keep only the first occurrence of each recurring event
    final seenSourceIds = <String>{};
    final keyEvents = <Map<String, dynamic>>[];

    for (final point in _dataPoints) {
      for (final event in point.events) {
        final eventAmount = _eventAmount(event);
        if (event['type'] == 'RECURRING' && eventAmount.abs() > 500) {
          final sourceId = event['source_id']?.toString() ?? '';

          // Deduplicate: keep only the first occurrence per source_id
          if (sourceId.isEmpty || !seenSourceIds.contains(sourceId)) {
            if (sourceId.isNotEmpty) seenSourceIds.add(sourceId);
            keyEvents.add({'date': point.date, ...event});
          }
        }
      }
    }

    // Sort by absolute amount and take top 5
    keyEvents.sort(
      (a, b) => _eventAmount(b).abs().compareTo(_eventAmount(a).abs()),
    );
    final topEvents = keyEvents.take(5).toList();

    if (topEvents.isEmpty) {
      return [
        Text(
          t.chat.genui.cashFlowForecast.noSignificantEvents,
          style: AppTextStyles.detailLabel(theme),
        ),
      ];
    }

    return topEvents.map((event) {
      final date = event['date'] is DateTime
          ? event['date'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(0);
      final amount = _eventAmount(event);
      final rawDescription = event['description']?.toString();
      final description = _localizeDescription(rawDescription);
      final isIncome = amount > 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: isIncome
                    ? amountTheme.incomeColor
                    : amountTheme.expenseColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: theme.typography.body.xs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat(
                      t.chat.genui.cashFlowForecast.dateFormat,
                    ).format(date),
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : ''}¥${_formatAmount(amount)}',
              style: AppTextStyles.statLabel(theme).copyWith(
                color: isIncome
                    ? amountTheme.incomeColor
                    : amountTheme.expenseColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Data models for parsing forecast response
class _ForecastDataPoint {
  final DateTime date;
  final double predictedBalance;
  final double lowerBound;
  final double upperBound;
  final List<Map<String, dynamic>> events;

  _ForecastDataPoint({
    required this.date,
    required this.predictedBalance,
    required this.lowerBound,
    required this.upperBound,
    required this.events,
  });

  factory _ForecastDataPoint.fromJson(Map<String, dynamic> json) {
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

    return _ForecastDataPoint(
      date: parseDate(json['date']),
      predictedBalance: asDouble(json['predicted_balance']),
      lowerBound: asDouble(json['lower_bound']),
      upperBound: asDouble(json['upper_bound']),
      events: events,
    );
  }
}

class _ForecastWarning {
  final DateTime date;
  final String type;
  final String message;

  _ForecastWarning({
    required this.date,
    required this.type,
    required this.message,
  });

  factory _ForecastWarning.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return _ForecastWarning(
      date: parseDate(json['date']),
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

/// Computes a safe Y-axis [minY, maxY] range for the forecast curve.
///
/// Guards against a flat prediction curve (minY == maxY): without a baseline
/// span the range would be zero, producing a division-by-zero in the grid
/// interval and an invisible chart. Expands the range symmetrically instead.
({double minY, double maxY}) _safeChartRange(List<double> allValues) {
  var minY = allValues.reduce((a, b) => a < b ? a : b);
  var maxY = allValues.reduce((a, b) => a > b ? a : b);
  if (maxY == minY) {
    maxY += 100;
    minY -= 100;
  }
  return (minY: minY, maxY: maxY);
}
