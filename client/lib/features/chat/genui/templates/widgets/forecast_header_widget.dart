import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class ForecastHeaderWidget extends StatelessWidget {
  final String? title;
  final Map<String, dynamic>? forecastPeriod;
  final double currentBalance;
  final bool hasWarnings;
  final AmountTheme amountTheme;
  final String Function(dynamic amount) formatAmount;

  const ForecastHeaderWidget({
    super.key,
    required this.title,
    required this.forecastPeriod,
    required this.currentBalance,
    required this.hasWarnings,
    required this.amountTheme,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final days = forecastPeriod?['days'] ?? 30;

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
                    title?.isNotEmpty == true
                        ? title!
                        : t.chat.genui.cashFlowForecast.title,
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
              '¥${formatAmount(currentBalance)}',
              style: AppTextStyles.listTrailing(
                theme,
              ).copyWith(color: colors.secondaryForeground),
            ),
          ),
        ],
      ),
    );
  }
}
