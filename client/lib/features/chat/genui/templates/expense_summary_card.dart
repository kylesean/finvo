import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/chat/genui/organisms/organisms.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/features/chat/genui/catalog_helpers.dart';
import 'package:finvo/features/chat/services/genui_logger.dart';

import 'package:finvo/features/chat/genui/utils/genui_num_utils.dart';

/// Smart Expense Summary Card
class ExpenseSummaryCard extends ConsumerWidget {
  final Map<String, dynamic> data;

  const ExpenseSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final theme = context.theme;
      final colors = theme.colors;

      final summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'] as Map)
          : data;
      final totalExpense = AmountFormatter.parseDecimal(
        summary['totalExpense']?.toString(),
      );
      final distribution = summary['distribution'] is List
          ? (summary['distribution'] as List)
          : const <dynamic>[];
      final topItems = summary['topItems'] is List
          ? (summary['topItems'] as List)
          : const <dynamic>[];
      final totalCount = GenUiNumUtils.toInt(summary['count']);

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
            // 1. Top total section
            _buildTotalSection(context, theme, colors, totalExpense),

            // 2. Category distribution progress bar
            if (distribution.isNotEmpty)
              _buildDistributionSection(context, theme, colors, distribution),

            // 3. Top 3 transaction list
            if (topItems.isNotEmpty)
              _buildTopItemsSection(context, theme, colors, topItems),

            // 4. Bottom view-all button
            _buildViewAllButton(context, theme, colors, totalCount),
          ],
        ),
      );
    } catch (e, stackTrace) {
      final t = Translations.of(context);
      GenUiLogger.logError(
        message: 'ExpenseSummaryCard rendering failed',
        error: e,
        stackTrace: stackTrace,
      );
      return buildErrorWidget(context, t.chat.genui.error.fetchFailed);
    }
  }

  Widget _buildTotalSection(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    Decimal amount,
  ) {
    final t = Translations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.chat.genui.expenseSummary.totalExpense,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 4),
          // Use unified AmountText.large component
          AmountText.large(
            amount: amount,
            type: TransactionType.expense,
            semantic: AmountSemantic.status,
            showSign: false,
            dimDecimals: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    List<dynamic> distribution,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Combined progress bar
          Container(
            height: 12,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: distribution.asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final item = mapEntry.value is Map
                    ? Map<String, dynamic>.from(mapEntry.value as Map)
                    : <String, dynamic>{};
                final percentage = GenUiNumUtils.toDouble(item['percentage']);

                return Flexible(
                  flex: (percentage * 1000).toInt(),
                  child: Container(color: theme.chartColorAt(index)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Category legend (top 4)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: distribution.take(4).toList().asMap().entries.map((
              mapEntry,
            ) {
              final index = mapEntry.key;
              final item = mapEntry.value is Map
                  ? Map<String, dynamic>.from(mapEntry.value as Map)
                  : <String, dynamic>{};
              final categoryKey = item['categoryKey']?.toString();
              final percentage = GenUiNumUtils.toDouble(item['percentage']);
              final category = TransactionCategory.fromKey(categoryKey);
              final chartColor = theme.chartColorAt(index);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: chartColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${category.displayText} ${(percentage * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.detailLabel(theme),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsSection(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    List<dynamic> topItems,
  ) {
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              t.chat.genui.expenseSummary.mainExpenses,
              style: AppTextStyles.chatMeta(theme),
            ),
          ),
          const SizedBox(height: 8),
          ...topItems.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final item = mapEntry.value is Map
                ? Map<String, dynamic>.from(mapEntry.value as Map)
                : <String, dynamic>{};
            final categoryKey = item['categoryKey']?.toString();
            final category = TransactionCategory.fromKey(categoryKey);
            final amount = AmountFormatter.parseDecimal(
              item['amount']?.toString(),
            );
            final tagsList =
                (item['tags'] as List?)?.map((e) => e.toString()).toList() ??
                [];
            final tags = tagsList.join(' · ');
            final chartColor = theme.chartColorAt(index);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: chartColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, size: 16, color: chartColor),
                ),
                title: Text(
                  tags.isNotEmpty ? tags : category.displayText,
                  style: AppTextStyles.chatTag(theme),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: AmountText(
                  amount: amount,
                  type: TransactionType.expense,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    int totalCount,
  ) {
    final t = Translations.of(context);
    return InkWell(
      onTap: () => _showAllTransactions(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: 0.2),
          border: Border(
            top: Border.all(color: colors.border.withValues(alpha: 0.3)).top,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.chat.genui.expenseSummary.viewAll(count: totalCount),
              style: AppTextStyles.chatAction(theme),
            ),
            const SizedBox(width: 4),
            Icon(FLucideIcons.chevronRight, size: 14, color: colors.primary),
          ],
        ),
      ),
    );
  }

  void _showAllTransactions(BuildContext context) {
    final t = Translations.of(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GenUIBottomSheet(
          title: t.chat.genui.expenseSummary.details,
          child: TransactionListView(data: data),
        ),
      ),
    );
  }
}
