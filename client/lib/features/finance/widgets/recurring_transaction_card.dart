import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/features/finance/models/recurring_transaction.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/finance/utils/recurrence_rule_utils.dart';
import 'package:finvo/features/finance/utils/recurring_transaction_display.dart'
    show formatShortDate, recurringTransactionDisplayName;
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// Swipeable recurring-transaction row for the list page.
///
/// M-28: extracted from `RecurringTransactionListPage._buildTransactionCard` so
/// the page stays focused on list state while this widget owns the card UI
/// (type icon/colour, rule + dynamic-amount tags, amount and next-date).
class RecurringTransactionCard extends ConsumerWidget {
  final RecurringTransaction transaction;
  final Future<bool> Function(RecurringTransaction) onDelete;
  final Future<void> Function(RecurringTransaction) onToggleActive;

  const RecurringTransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final typeColor = _getTypeColor(theme, transaction.type);
    final typeIcon = _getTypeIcon(transaction.type);
    final amountSign = transaction.type == RecurringTransactionType.income
        ? '+'
        : transaction.type == RecurringTransactionType.expense
        ? '-'
        : '';

    // Get next execution date (prefer nextExecutionAt, fallback to startDate)
    final nextDate = transaction.nextExecutionAt ?? transaction.startDate;

    return Dismissible(
      key: Key('recurring_${transaction.id}'),
      direction: DismissDirection.horizontal, // Support horizontal swipe
      dismissThresholds: const {
        DismissDirection.endToStart: 0.4,
        DismissDirection.startToEnd: 0.4,
      },
      confirmDismiss: (direction) async {
        unawaited(HapticFeedback.selectionClick());
        if (direction == DismissDirection.endToStart) {
          // Swipe left → delete
          return await onDelete(transaction);
        } else {
          // Swipe right → toggle active state
          await onToggleActive(transaction);
          return false; // Don't dismiss card
        }
      },
      // Left swipe background (pause/resume)
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: transaction.isActive
              ? colors.mutedForeground
              : theme.semantic.successAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              transaction.isActive ? FLucideIcons.pause : FLucideIcons.play,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              transaction.isActive
                  ? t.forecast.recurringTransaction.paused
                  : t.forecast.recurringTransaction.activated,
              style: theme.typography.body.sm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      // Right swipe background (delete)
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.destructive,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(FLucideIcons.trash2, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: () => context.pushNamed(
          AppRouteNames.recurringTransactionEdit,
          pathParameters: {'id': transaction.id},
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left: type icon
                ThemedIcon.large(icon: typeIcon),
                const SizedBox(width: 14),
                // Center: title + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recurringTransactionDisplayName(transaction),
                        style: AppTextStyles.listTitle(theme),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Rule tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.muted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              shortFrequencyLabel(transaction.recurrenceRule),
                              style: AppTextStyles.statLabel(theme),
                            ),
                          ),
                          // Dynamic amount tag
                          if (transaction.amountType == AmountType.estimate)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FLucideIcons.circleAlert,
                                    size: 12,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    t
                                        .forecast
                                        .recurringTransaction
                                        .dynamicAmount,
                                    style: AppTextStyles.badge(theme),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right: amount + next date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$amountSign${Currency.fromCode(ref.watch(financialSettingsProvider).primaryCurrency)?.symbol ?? '¥'}${transaction.amount.toDouble().toStringAsFixed(2)}',
                      style: AppTextStyles.listTitle(
                        theme,
                      ).copyWith(color: typeColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.forecast.recurringTransaction.nextTime}: ${formatShortDate(nextDate)}',
                      style: theme.typography.body.sm.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(FThemeData theme, RecurringTransactionType type) {
    switch (type) {
      case RecurringTransactionType.expense:
        return theme.colors.destructive;
      case RecurringTransactionType.income:
        return theme.semantic.successAccent;
      case RecurringTransactionType.transfer:
        return theme.colors.primary;
    }
  }

  IconData _getTypeIcon(RecurringTransactionType type) {
    switch (type) {
      case RecurringTransactionType.expense:
        return FLucideIcons.arrowUpRight;
      case RecurringTransactionType.income:
        return FLucideIcons.arrowDownLeft;
      case RecurringTransactionType.transfer:
        return FLucideIcons.arrowRightLeft;
    }
  }
}
