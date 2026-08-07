import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/utils/map_extensions.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/features/chat/genui/templates/widgets/forecast_header_widget.dart';
import 'package:finvo/features/chat/genui/templates/widgets/forecast_chart_widget.dart';
import 'package:finvo/features/chat/genui/templates/widgets/forecast_warnings_widget.dart';
import 'package:finvo/features/chat/genui/templates/widgets/forecast_details_widget.dart';

/// Cash flow forecast chart - GenUI Template
///
/// Displays user's future cash flow forecast in AI chat.
@immutable
class _CashFlowForecastViewModel {
  final String title;
  final List<ForecastDataPoint> dataPoints;
  final List<ForecastWarning> warnings;
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
    return _CashFlowForecastViewModel(
      title: data.getString('title'),
      dataPoints: data.getList('data_points', ForecastDataPoint.fromJson),
      warnings: data.getList('warnings', ForecastWarning.fromJson),
      summary: data.getMap('summary'),
      forecastPeriod: data.getMap('forecast_period'),
      currentBalance: data.getDouble('current_balance'),
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = context.theme;
        final colors = theme.colors;
        final amountTheme = ref.watch(currentAmountThemeProvider);
        final hasWarnings = _viewModel.warnings.isNotEmpty;

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
                ForecastHeaderWidget(
                  title: _viewModel.title,
                  forecastPeriod: _viewModel.forecastPeriod,
                  currentBalance: _viewModel.currentBalance,
                  hasWarnings: hasWarnings,
                  amountTheme: amountTheme,
                  formatAmount: _formatAmount,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 180,
                    child: ForecastChartWidget(
                      dataPoints: _viewModel.dataPoints,
                      formatAmount: _formatAmount,
                    ),
                  ),
                ),

                if (hasWarnings)
                  ForecastWarningsWidget(
                    warnings: _viewModel.warnings,
                    amountTheme: amountTheme,
                  ),

                if (_isExpanded)
                  ForecastDetailsWidget(
                    summary: _viewModel.summary,
                    dataPoints: _viewModel.dataPoints,
                    amountTheme: amountTheme,
                    formatAmount: _formatAmount,
                  ),

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
}
