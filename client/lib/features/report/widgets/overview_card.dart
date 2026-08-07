import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';

/// A premium overview that uses large typography and subtle depth
class OverviewCard extends ConsumerWidget {
  final StatisticsOverview overview;

  const OverviewCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final amountTheme = ref.watch(currentAmountThemeProvider);
    final currencyCode = ref.watch(financialSettingsProvider).primaryCurrency;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.95),
            colors.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              FLucideIcons.trendingUp,
              size: 160,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.statistics.overview.balance,
                  style: theme.typography.body.sm.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: AppFontConfig.bodyMedium,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: AmountText(
                      amount: AmountFormatter.parseDecimal(
                        overview.totalBalance,
                      ).toDouble(),
                      type:
                          AmountFormatter.parseDecimal(
                                overview.totalBalance,
                              ).toDouble() >=
                              0
                          ? TransactionType.income
                          : TransactionType.expense,
                      semantic: AmountSemantic.status,
                      currency: currencyCode,
                      shrinkCurrency: true,
                      style: theme.typography.body.xl4.copyWith(
                        color: Colors.white,
                        fontWeight: AppFontConfig.amountBold,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicator(
                        context,
                        ref,
                        theme,
                        t.statistics.overview.income,
                        overview.totalIncome,
                        overview.incomeChangePercent,
                        FLucideIcons.arrowUpRight,
                        amountTheme.incomeColor,
                        currencyCode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildIndicator(
                        context,
                        ref,
                        theme,
                        t.statistics.overview.expense,
                        overview.totalExpense,
                        overview.expenseChangePercent,
                        FLucideIcons.arrowDownRight,
                        amountTheme.expenseColor,
                        currencyCode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    String label,
    String amount,
    double change,
    IconData icon,
    Color color,
    String currencyCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.typography.body.xs.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AmountText(
                amount: AmountFormatter.parseDecimal(amount).toDouble(),
                type: label == t.statistics.overview.income
                    ? TransactionType.income
                    : TransactionType.expense,
                semantic: AmountSemantic.transaction,
                // AmountText resolves the symbol from the currency code, so pass
                // the code (not a pre-resolved symbol) here.
                currency: currencyCode,
                showSign: false,
                shrinkCurrency: true,
                style: theme.typography.body.md.copyWith(
                  color: Colors.white, // Ensure always white on large card
                  fontWeight: AppFontConfig.amountBold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AmountChangeIndicator(
              changePercent: change,
              inverseColor: label == t.statistics.overview.expense,
              theme: ref.watch(currentAmountThemeProvider),
              style: theme.typography.body.xs.copyWith(
                fontSize: 9,
                fontWeight: AppFontConfig.amountBold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
