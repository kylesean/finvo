import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/chat/genui/utils/genui_num_utils.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Budget analysis card (Layer 4: Template)
///
/// Displays in-depth budget analysis results, including:
/// - Total expense summary and trends
/// - Category distribution visualization
/// - Top spenders list
/// - AI suggestions
///
/// Difference from BudgetStatusCard:
/// - BudgetStatusCard: simple query, shows current budget status
/// - BudgetAnalysisCard: deep analysis, shows trends, insights, suggestions
class BudgetAnalysisCard extends ConsumerWidget {
  final Map<String, dynamic> data;

  const BudgetAnalysisCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final theme = context.theme;
      final colors = theme.colors;

      final totalExpense = GenUiNumUtils.toDouble(data['total_expense']);
      final currency =
          data['currency']?.toString() ??
          ref.watch(financialSettingsProvider).primaryCurrency;
      final currencySymbol = AmountFormatter.getCurrencySymbol(currency);
      final periodDays = GenUiNumUtils.toInt(data['period_days'], 90);
      final byCategoryRaw = data['by_category'];
      final byCategory = byCategoryRaw is Map
          ? Map<String, dynamic>.from(byCategoryRaw)
          : <String, dynamic>{};
      final trendsRaw = data['trends'];
      final trends = trendsRaw is Map
          ? Map<String, dynamic>.from(trendsRaw)
          : <String, dynamic>{};
      final topSpendersRaw = data['top_spenders'];
      final topSpenders = topSpendersRaw is List ? topSpendersRaw : <dynamic>[];
      final suggestionsRaw = data['suggestions'];
      final suggestions = suggestionsRaw is List ? suggestionsRaw : <dynamic>[];

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header bar (dark blue tone, distinct from status card)
            _buildHeader(theme, colors, periodDays),

            // 2. Total expense + trend indicators
            _buildTotalSection(theme, colors, totalExpense, trends, currency),

            // 3. Category distribution
            if (byCategory.isNotEmpty)
              _buildCategorySection(theme, colors, byCategory, currencySymbol),

            // 4. Top spenders
            if (topSpenders.isNotEmpty)
              _buildTopSpendersSection(theme, colors, topSpenders, currency),

            // 5. Suggestions (based on structured data)
            if (suggestions.isNotEmpty)
              _buildSuggestionsSection(theme, colors, suggestions),
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.theme.colors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Budget analysis format error: $e',
                style: TextStyle(
                  color: context.theme.colors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Header bar - using dark blue tone to distinguish from regular status card
  Widget _buildHeader(FThemeData theme, FColors colors, int periodDays) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.15),
            colors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: colors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data['title']?.toString() ?? t.chat.genui.budgetAnalysis.title,
              style: theme.typography.body.md.copyWith(
                color: colors.primary,
                fontWeight: AppFontConfig.titleSemibold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              t.chat.genui.budgetAnalysis.periodDays(days: periodDays),
              style: AppTextStyles.badge(theme),
            ),
          ),
        ],
      ),
    );
  }

  /// Total expense section + trend indicators
  Widget _buildTotalSection(
    FThemeData theme,
    FColors colors,
    double totalExpense,
    Map<String, dynamic> trends,
    String currency,
  ) {
    final momRaw = trends['month_over_month'];
    final mom = momRaw is Map ? Map<String, dynamic>.from(momRaw) : null;
    final changePercent = GenUiNumUtils.toDouble(mom?['change_percent']);
    final direction = mom?['direction']?.toString() ?? 'flat';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Total expense amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.chat.genui.budgetAnalysis.totalExpense,
                  style: AppTextStyles.listSubtitle(theme),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AmountText(
                      amount: totalExpense,
                      type: TransactionType.expense,
                      semantic: AmountSemantic.trend,
                      currency: currency,
                      style: theme.typography.body.xl.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trend indicators
          if (mom != null)
            _buildTrendBadge(theme, colors, changePercent, direction),
        ],
      ),
    );
  }

  /// Trend badge
  Widget _buildTrendBadge(
    FThemeData theme,
    FColors colors,
    double changePercent,
    String direction,
  ) {
    final semantic = theme.semantic;
    final isUp = direction == 'up';
    final isFlat = direction == 'flat';
    // Use semantic colors: up uses red (destructive), down uses green (success)
    final trendColor = isFlat
        ? colors.mutedForeground
        : (isUp ? colors.destructive : semantic.successAccent);
    final icon = isFlat
        ? FLucideIcons.minus
        : (isUp ? FLucideIcons.trendingUp : FLucideIcons.trendingDown);
    final prefix = isUp ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: trendColor),
          const SizedBox(width: 4),
          Text(
            t.chat.genui.budgetAnalysis.momChange(
              change: '$prefix${changePercent.toStringAsFixed(1)}',
            ),
            style: AppTextStyles.statLabel(theme).copyWith(color: trendColor),
          ),
        ],
      ),
    );
  }

  /// Category distribution section
  Widget _buildCategorySection(
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> byCategory,
    String currencySymbol,
  ) {
    // Sort by proportion
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) {
        final aTotal = (a.value['total'] as num?)?.toDouble() ?? 0;
        final bTotal = (b.value['total'] as num?)?.toDouble() ?? 0;
        return bTotal.compareTo(aTotal);
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.chat.genui.budgetAnalysis.categoryDistribution,
            style: AppTextStyles.statLabel(theme),
          ),
          const SizedBox(height: 12),
          // Combined progress bar
          Container(
            height: 10,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: sortedCategories.take(5).toList().asMap().entries.map((
                mapEntry,
              ) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                final percentage = GenUiNumUtils.toDouble(
                  entry.value['percentage'],
                );
                return Flexible(
                  flex: (percentage * 10).toInt().clamp(1, 100),
                  child: Container(color: theme.chartColorAt(index)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Category list (top 4)
          ...sortedCategories.take(4).toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final catData = entry.value is Map
                ? Map<String, dynamic>.from(entry.value as Map)
                : <String, dynamic>{};
            final percentage = GenUiNumUtils.toDouble(catData['percentage']);
            final total = GenUiNumUtils.toDouble(catData['total']);
            final category = TransactionCategory.fromKey(entry.key);
            final chartColor = theme.chartColorAt(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: chartColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.displayText,
                      style: AppTextStyles.listTrailing(theme),
                    ),
                  ),
                  Text(
                    '$currencySymbol${_formatAmount(total)}',
                    style: AppTextStyles.listSubtitle(theme),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.listTrailing(theme),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Top spenders list
  Widget _buildTopSpendersSection(
    FThemeData theme,
    FColors colors,
    List<dynamic> topSpenders,
    String currency,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            t.chat.genui.budgetAnalysis.topSpenders,
            style: AppTextStyles.statLabel(theme),
          ),
          const SizedBox(height: 8),
          ...topSpenders.take(3).toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final spender = mapEntry.value is Map
                ? Map<String, dynamic>.from(mapEntry.value as Map)
                : <String, dynamic>{};
            final amount = GenUiNumUtils.toDouble(spender['amount']);
            final categoryKey = spender['category']?.toString() ?? 'OTHERS';
            final description = spender['description']?.toString() ?? '';
            final date = spender['date']?.toString() ?? '';
            final category = TransactionCategory.fromKey(categoryKey);
            final chartColor = theme.chartColorAt(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: chartColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, size: 14, color: chartColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description.isNotEmpty
                              ? description
                              : category.displayText,
                          style: AppTextStyles.listTrailing(theme),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (date.isNotEmpty)
                          Text(date, style: AppTextStyles.detailLabel(theme)),
                      ],
                    ),
                  ),
                  AmountText(
                    amount: amount,
                    type: TransactionType.expense,
                    currency: currency,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Suggestions section
  Widget _buildSuggestionsSection(
    FThemeData theme,
    FColors colors,
    List<dynamic> suggestions,
  ) {
    // Use theme primary color variant, maintaining warning semantics while unified with theme
    final accentColor = colors.primary;
    final bgColor = colors.primary.withValues(alpha: 0.08);
    final borderColor = colors.primary.withValues(alpha: 0.2);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FLucideIcons.lightbulb, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                t.budgetSuggestion.financialInsights,
                style: theme.typography.body.sm.copyWith(
                  color: accentColor,
                  fontWeight: AppFontConfig.titleSemibold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...suggestions.take(3).map((suggestion) {
            // Process structured suggestion data
            final text = _formatSuggestion(suggestion);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: theme.typography.body.sm.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.foreground,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Format structured suggestion into readable text
  String _formatSuggestion(dynamic suggestion) {
    if (suggestion is String) return suggestion;
    if (suggestion is! Map) return suggestion.toString();

    final type = suggestion['type']?.toString();
    final categoryKey = suggestion['category_key']?.toString();
    final percentage = suggestion['percentage'];
    final count = suggestion['count'];

    // Get localized category name
    final categoryName = categoryKey != null
        ? TransactionCategory.fromKey(categoryKey).displayText
        : '';

    switch (type) {
      case 'high_percentage':
        return t.budgetSuggestion.highPercentage(
          category: categoryName,
          percentage: percentage.toString(),
        );
      case 'monthly_increase':
        return t.budgetSuggestion.monthlyIncrease(
          percentage: percentage.toString(),
        );
      case 'frequent_small':
        return t.budgetSuggestion.frequentSmall(
          category: categoryName,
          count: count.toString(),
        );
      default:
        return suggestion.toString();
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return t.chat.genui.budgetAnalysis.amountWan(
        amount: (amount / 10000).toStringAsFixed(1),
      );
    }
    return amount.toStringAsFixed(0);
  }
}
