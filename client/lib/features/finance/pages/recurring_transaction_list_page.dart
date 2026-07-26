import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:augo/core/widgets/top_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import '../../../shared/models/currency.dart';
import '../../profile/providers/financial_settings_provider.dart';
import 'package:augo/core/constants/category_constants.dart';
import 'package:augo/i18n/strings.g.dart';
import 'package:augo/shared/widgets/themed_icon.dart';
import '../../../shared/widgets/app_filter_chip.dart';

/// Recurring transaction list page
class RecurringTransactionListPage extends ConsumerStatefulWidget {
  const RecurringTransactionListPage({super.key});

  @override
  ConsumerState<RecurringTransactionListPage> createState() =>
      _RecurringTransactionListPageState();
}

class _RecurringTransactionListPageState
    extends ConsumerState<RecurringTransactionListPage> {
  RecurringTransactionType? _filterType;
  bool _sortAscending = true; // Sort by time ascending

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(() {
        unawaited(ref.read(recurringTransactionProvider.notifier).loadList());
      }),
    );
  }

  void _onFilterChanged(RecurringTransactionType? type) {
    setState(() => _filterType = type);
    unawaited(
      ref.read(recurringTransactionProvider.notifier).loadList(type: type),
    );
  }

  void _toggleSort() {
    setState(() => _sortAscending = !_sortAscending);
  }

  List<RecurringTransaction> _getSortedItems(List<RecurringTransaction> items) {
    final sorted = List<RecurringTransaction>.from(items);
    sorted.sort((a, b) {
      final aTime = a.nextExecutionAt ?? a.startDate;
      final bTime = b.nextExecutionAt ?? b.startDate;
      return _sortAscending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(recurringTransactionProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // If cannot pop, navigate to finance page
              context.go('/finance');
            }
          },
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        title: Text(
          t.forecast.recurringTransaction.title,
          style: theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(theme, colors),
          // List content
          Expanded(child: _buildContent(theme, colors, state)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/finance/recurring-transactions/new'),
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterTabs(FThemeData theme, FColors colors) {
    final filters = [
      (null, t.forecast.recurringTransaction.all),
      (
        RecurringTransactionType.expense,
        t.forecast.recurringTransaction.expense,
      ),
      (RecurringTransactionType.income, t.forecast.recurringTransaction.income),
      (
        RecurringTransactionType.transfer,
        t.forecast.recurringTransaction.transfer,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterType == filter.$1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: filter.$2,
                isSelected: isSelected,
                onTap: () => _onFilterChanged(filter.$1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(
    FThemeData theme,
    FColors colors,
    RecurringTransactionState state,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.circleAlert,
              size: 48,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              t.common.loadFailed,
              style: theme.typography.body.md.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: .outline,
              onPress: () => ref
                  .read(recurringTransactionProvider.notifier)
                  .loadList(type: _filterType),
              child: Text(t.common.retry),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    final sortedItems = _getSortedItems(state.items);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(recurringTransactionProvider.notifier)
          .loadList(type: _filterType),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // List header: show count + sort button
          _buildListHeader(theme, colors, sortedItems.length),
          const SizedBox(height: 12),
          // List items
          ...sortedItems.map(
            (item) => _buildTransactionCard(theme, colors, item),
          ),
        ],
      ),
    );
  }

  /// List header: count on left, sort button on right
  Widget _buildListHeader(FThemeData theme, FColors colors, int count) {
    final typeLabel = _filterType?.label ?? t.forecast.recurringTransaction.all;
    return Row(
      children: [
        Text(
          t.forecast.recurringTransaction.periodCount(
            type: typeLabel,
            count: count.toString(),
          ),
          style: theme.typography.body.sm.copyWith(
            color: colors.mutedForeground,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleSort,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _sortAscending ? FLucideIcons.arrowUp : FLucideIcons.arrowDown,
                size: 14,
                color: colors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                t.forecast.recurringTransaction.sortByTime,
                style: theme.typography.body.sm.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(FThemeData theme, FColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FLucideIcons.repeat, size: 64, color: colors.mutedForeground),
            const SizedBox(height: 16),
            Text(
              t.forecast.recurringTransaction.noRecurring,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.forecast.recurringTransaction.createHint,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () =>
                    context.push('/finance/recurring-transactions/new'),
                child: Text(t.forecast.recurringTransaction.create),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    FThemeData theme,
    FColors colors,
    RecurringTransaction transaction,
  ) {
    final typeColor = _getTypeColor(colors, transaction.type);
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
          return await _showDeleteConfirmDialog(transaction);
        } else {
          // Swipe right → toggle active state
          await _showToggleActiveDialog(transaction);
          return false; // Don't dismiss card
        }
      },
      // Left swipe background (pause/resume)
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: transaction.isActive ? colors.mutedForeground : Colors.green,
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
        onTap: () => context.push(
          '/finance/recurring-transactions/${transaction.id}/edit',
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
                        _getDisplayName(transaction),
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.foreground,
                        ),
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
                              _getShortFrequencyLabel(
                                transaction.recurrenceRule,
                              ),
                              style: theme.typography.body.xs.copyWith(
                                color: colors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
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
                                    style: theme.typography.body.xs.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                      '$amountSign${Currency.fromCode(ref.watch(financialSettingsProvider).primaryCurrency)?.symbol ?? '¥'}${transaction.amount}',
                      style: theme.typography.body.md.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.forecast.recurringTransaction.nextTime}: ${_formatShortDate(nextDate)}',
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

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmDialog(
    RecurringTransaction transaction,
  ) async {
    bool confirmed = false;

    await showFDialog<void>(
      context: context,
      builder: (dialogContext, style, animation) => FDialog(
        animation: animation,
        builder: (context, dialogStyle) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.forecast.recurringTransaction.confirmDelete,
                style: dialogStyle.titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                t.forecast.recurringTransaction.deleteConfirm(
                  name: _getDisplayName(transaction),
                ),
                style: dialogStyle.bodyTextStyle,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: () => Navigator.pop(dialogContext),
                child: Text(t.common.cancel),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: .destructive,
                onPress: () {
                  confirmed = true;
                  Navigator.pop(dialogContext);
                },
                child: Text(t.common.delete),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed) {
      unawaited(HapticFeedback.mediumImpact());
      final success = await ref
          .read(recurringTransactionProvider.notifier)
          .delete(transaction.id);

      if (mounted) {
        if (success) {
          TopToast.success(context, t.transaction.deleted);
        } else {
          TopToast.error(context, t.transaction.deleteFailed);
        }
      }
      return success;
    }
    return false;
  }

  /// Show toggle active state confirmation dialog
  Future<void> _showToggleActiveDialog(RecurringTransaction transaction) async {
    final newState = !transaction.isActive;
    bool confirmed = false;

    await showFDialog<void>(
      context: context,
      builder: (dialogContext, style, animation) => FDialog(
        animation: animation,
        builder: (context, dialogStyle) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                newState
                    ? t.forecast.recurringTransaction.confirmActivate
                    : t.forecast.recurringTransaction.confirmPause,
                style: dialogStyle.titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                newState
                    ? t.forecast.recurringTransaction.activateConfirm(
                        name: _getDisplayName(transaction),
                      )
                    : t.forecast.recurringTransaction.pauseConfirm(
                        name: _getDisplayName(transaction),
                      ),
                style: dialogStyle.bodyTextStyle,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: () => Navigator.pop(dialogContext),
                child: Text(t.common.cancel),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: newState ? .primary : .outline,
                onPress: () {
                  confirmed = true;
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  newState
                      ? t.forecast.recurringTransaction.activated
                      : t.forecast.recurringTransaction.paused,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed) {
      unawaited(HapticFeedback.mediumImpact());
      unawaited(
        ref
            .read(recurringTransactionProvider.notifier)
            .toggleActive(transaction.id, newState),
      );

      if (mounted) {
        TopToast.success(
          context,
          newState
              ? t.forecast.recurringTransaction.activated
              : t.forecast.recurringTransaction.paused,
        );
      }
    }
  }

  Color _getTypeColor(FColors colors, RecurringTransactionType type) {
    switch (type) {
      case RecurringTransactionType.expense:
        return colors.destructive;
      case RecurringTransactionType.income:
        return Colors.green;
      case RecurringTransactionType.transfer:
        return colors.primary;
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

  /// Get short frequency label
  String _getShortFrequencyLabel(String rule) {
    final isZh = LocaleSettings.currentLocale == AppLocale.zh;
    if (rule.contains('FREQ=DAILY')) {
      return isZh ? '每天' : 'Daily';
    } else if (rule.contains('FREQ=WEEKLY')) {
      return isZh ? '每周' : 'Weekly';
    } else if (rule.contains('FREQ=MONTHLY')) {
      return isZh ? '每月' : 'Monthly';
    } else if (rule.contains('FREQ=YEARLY')) {
      return isZh ? '每年' : 'Yearly';
    }
    return isZh ? '周期' : 'Cycle';
  }

  /// Format short date (i18n support)
  /// Uses switch expression for easy addition of more language support
  String _formatShortDate(DateTime date) {
    final locale = LocaleSettings.currentLocale;
    // Return corresponding DateFormat locale and format based on language
    final (dateFormatLocale, pattern) = switch (locale) {
      AppLocale.zh => ('zh_CN', 'M 月 d 日'),
      AppLocale.en => ('en', 'MMM d'),
      AppLocale.ja => ('ja', 'M月d日'),
      AppLocale.ko => ('ko', 'M월 d일'),
      AppLocale.zhHant => ('zh_TW', 'M 月 d 日'),
    };
    return DateFormat(pattern, dateFormatLocale).format(date);
  }

  /// Generate display name for transaction
  /// Uses description if available, otherwise uses localized category name
  String _getDisplayName(RecurringTransaction transaction) {
    if (transaction.description != null &&
        transaction.description!.isNotEmpty) {
      return transaction.description!;
    }

    // Use localized category display name (already internationalized)
    if (transaction.categoryKey != null) {
      final category = TransactionCategory.fromKey(transaction.categoryKey!);
      return category.displayText;
    }

    // Default name: return based on type
    return switch (transaction.type) {
      RecurringTransactionType.expense => t.transaction.expense,
      RecurringTransactionType.income => t.transaction.income,
      RecurringTransactionType.transfer => t.transaction.transfer,
    };
  }
}
