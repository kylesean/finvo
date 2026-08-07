import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/chat/genui/templates/widgets/forecast_chart_widget.dart';

class ForecastDetailsWidget extends StatelessWidget {
  final Map<String, dynamic>? summary;
  final List<ForecastDataPoint> dataPoints;
  final AmountTheme amountTheme;
  final String Function(dynamic amount) formatAmount;

  const ForecastDetailsWidget({
    super.key,
    required this.summary,
    required this.dataPoints,
    required this.amountTheme,
    required this.formatAmount,
  });

  double _eventAmount(Map<String, dynamic> event) {
    final value = event['amount'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _localizeDescription(String? description) {
    if (description == null || description.isEmpty) {
      return t.chat.genui.cashFlowForecast.recurringTransaction;
    }

    final upper = description.toUpperCase();

    switch (upper) {
      case 'INCOME':
        return t.chat.genui.cashFlowForecast.recurringIncome;
      case 'EXPENSE':
        return t.chat.genui.cashFlowForecast.recurringExpense;
      case 'TRANSFER':
        return t.chat.genui.cashFlowForecast.recurringTransfer;
    }

    final category = TransactionCategory.fromKey(upper);
    if (category.key == upper) {
      return category.displayText;
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
                  value: summary!['total_recurring_income'],
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.recurringExpense,
                  value: summary!['total_recurring_expense'],
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
                  value: summary!['predicted_variable_expense'],
                  isPositive: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  amountTheme,
                  label: t.chat.genui.cashFlowForecast.netChange,
                  value: summary!['net_change'],
                  isPositive: ((summary!['net_change'] as num?) ?? 0) >= 0,
                ),
              ),
            ],
          ),
          if (dataPoints.isNotEmpty) ...[
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
            '¥${formatAmount(value)}',
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

    final seenSourceIds = <String>{};
    final keyEvents = <Map<String, dynamic>>[];

    for (final point in dataPoints) {
      for (final event in point.events) {
        final eventAmount = _eventAmount(event);
        if (event['type'] == 'RECURRING' && eventAmount.abs() > 500) {
          final sourceId = event['source_id']?.toString() ?? '';

          if (sourceId.isEmpty || !seenSourceIds.contains(sourceId)) {
            if (sourceId.isNotEmpty) seenSourceIds.add(sourceId);
            keyEvents.add({'date': point.date, ...event});
          }
        }
      }
    }

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
              '${isIncome ? '+' : ''}¥${formatAmount(amount)}',
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
