import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A compact card to compare current vs previous period metrics
class MetricComparisonCard extends ConsumerWidget {
  final String label;
  final String currentAmount;
  final double changePercent;
  final String compareLabel;
  final bool isExpense;

  const MetricComparisonCard({
    super.key,
    required this.label,
    required this.currentAmount,
    required this.changePercent,
    required this.compareLabel,
    this.isExpense = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final amountTheme = ref.watch(currentAmountThemeProvider);
    final isPositive = changePercent >= 0;
    final currencyCode = ref.watch(financialSettingsProvider).primaryCurrency;
    final currencySymbol = AmountFormatter.getCurrencySymbol(currencyCode);

    final displayColor = isExpense
        ? amountTheme.expenseColor
        : amountTheme.incomeColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.detailLabel(theme)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currencySymbol,
                      style: theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: AmountText(
                        amount: AmountFormatter.parseDecimal(currentAmount),
                        type: isExpense
                            ? TransactionType.expense
                            : TransactionType.income,
                        semantic: AmountSemantic.transaction,
                        currency: currencyCode,
                        style: theme.typography.body.lg.copyWith(
                          fontWeight: AppFontConfig.amountBold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrendIndicator(theme, isPositive, displayColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(
    FThemeData theme,
    bool isPositive,
    Color displayColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? FLucideIcons.trendingUp : FLucideIcons.trendingDown,
              size: 12,
              color: displayColor,
            ),
            const SizedBox(width: 2),
            Text(
              '${isPositive ? '+' : ''}${changePercent.abs().toStringAsFixed(1)}%',
              style: theme.typography.body.xs.copyWith(
                color: displayColor,
                fontWeight: AppFontConfig.amountBold,
              ),
            ),
          ],
        ),
        Text(
          compareLabel,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
