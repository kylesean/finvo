// features/shared_space/widgets/detail/shared_space_detail_sections.dart
//
// M-28: presentational widgets extracted from `SharedSpaceDetailPage` so the
// page State keeps only state + interaction + navigation logic.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/shared/config/category_config.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Full-page loading state shown while the space detail is first fetched.
class SpaceDetailLoadingState extends StatelessWidget {
  const SpaceDetailLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.sharedSpace.title, style: theme.typography.body.xl),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Full-page error state with a retry action.
class SpaceDetailErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const SpaceDetailErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.sharedSpace.title, style: theme.typography.body.xl),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
                t.sharedSpace.detail.loadFailed,
                style: AppTextStyles.pageTitle(theme),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.listSubtitle(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FButton(
                variant: .outline,
                onPress: onRetry,
                child: Text(t.sharedSpace.detail.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton card shown while the settlement summary is loading.
class SpaceSettlementLoadingCard extends StatelessWidget {
  const SpaceSettlementLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final semantic = theme.semantic;

    final Color shimmerBaseColor = semantic.shimmerBase;
    final Color shimmerHighlightColor = semantic.shimmerHighlight;
    final Color placeholderShapeColor = semantic.shimmerBase;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1200),
        child: Column(
          children: [
            // Top panel skeleton
            Container(
              height: 160,
              width: double.infinity,
              color: placeholderShapeColor,
            ),
            // Bottom content skeleton
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    2,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: placeholderShapeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 80,
                                  color: placeholderShapeColor,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 12,
                                  width: 40,
                                  color: placeholderShapeColor,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 60,
                            color: placeholderShapeColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact error card for a failed settlement with a retry action.
class SpaceSettlementErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const SpaceSettlementErrorCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 24,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            t.sharedSpace.detail.loadFailed,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: .outline,
            onPress: onRetry,
            child: Text(t.sharedSpace.detail.retry),
          ),
        ],
      ),
    );
  }
}

/// Column of transaction card skeletons shown while the list loads.
class SpaceTransactionsLoadingList extends StatelessWidget {
  const SpaceTransactionsLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const SpaceTransactionCardSkeleton(),
      ),
    );
  }
}

/// Single shimmer skeleton for a transaction card.
class SpaceTransactionCardSkeleton extends StatelessWidget {
  const SpaceTransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = context.theme.semantic;
    final Color shimmerBaseColor = semantic.shimmerBase;
    final Color shimmerHighlightColor = semantic.shimmerHighlight;
    final Color placeholderShapeColor = semantic.shimmerBase;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1200),
        child: Row(
          children: [
            // Icon skeleton
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: placeholderShapeColor,
              ),
            ),
            const SizedBox(width: 12),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    color: placeholderShapeColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: placeholderShapeColor,
                  ),
                ],
              ),
            ),
            // Amount skeleton
            Container(height: 20, width: 60, color: placeholderShapeColor),
          ],
        ),
      ),
    );
  }
}

/// Compact error card for a failed transaction list with a retry action.
class SpaceTransactionsErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const SpaceTransactionsErrorCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            FLucideIcons.circleAlert,
            size: 24,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            t.sharedSpace.detail.loadFailed,
            style: AppTextStyles.listSubtitle(theme),
          ),
          const SizedBox(height: 16),
          FButton(
            variant: .outline,
            onPress: onRetry,
            child: Text(t.sharedSpace.detail.retry),
          ),
        ],
      ),
    );
  }
}

/// Transaction list with an inline empty state and an infinite-scroll footer.
class SpaceTransactionList extends StatelessWidget {
  final List<SpaceTransaction> transactions;
  final bool hasMore;
  final bool isLoading;

  /// Invoked after returning from the transaction detail route (real-time sync).
  final Future<void> Function()? onTransactionReturned;

  const SpaceTransactionList({
    super.key,
    required this.transactions,
    this.hasMore = false,
    this.isLoading = false,
    this.onTransactionReturned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    // Empty state
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: colors.muted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              FLucideIcons.receipt,
              size: 40,
              color: colors.mutedForeground.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              t.sharedSpace.detail.noTransactions,
              style: AppTextStyles.listTitle(theme),
            ),
            const SizedBox(height: 4),
            Text(
              t.sharedSpace.detail.noTransactionsHint,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Transaction list + infinite-scroll footer
    return Column(
      children: [
        ...transactions.map(
          (tx) =>
              SpaceTransactionItem(tx: tx, onReturned: onTransactionReturned),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (!hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              t.sharedSpace.detail.noMoreTransactions,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}

/// Single transaction row with amount color derived from the current theme.
class SpaceTransactionItem extends ConsumerWidget {
  final SpaceTransaction tx;

  /// Invoked after returning from the transaction detail route (real-time sync).
  final Future<void> Function()? onReturned;

  const SpaceTransactionItem({super.key, required this.tx, this.onReturned});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    // Parse transaction type
    final isExpense = tx.type.toUpperCase() == 'EXPENSE';
    final isIncome = tx.type.toUpperCase() == 'INCOME';
    final transactionType = isExpense
        ? TransactionType.expense
        : (isIncome ? TransactionType.income : TransactionType.transfer);
    final amountTheme = ref.watch(currentAmountThemeProvider);
    final amountColor = AmountFormatter.getAmountColor(
      transactionType,
      amountTheme,
    );

    // Format time
    String timeDisplay = '';
    if (tx.transactionAt != null) {
      timeDisplay = relativeTime(tx.transactionAt!);
    }

    return GestureDetector(
      onTap: () async {
        // Real-time sync: refresh the space transactions when returning from
        // the transaction detail route (a tx may have been edited/deleted).
        await context.pushNamed(
          AppRouteNames.transactionDetail,
          pathParameters: {'transactionId': tx.id},
        );
        if (context.mounted) {
          await onReturned?.call();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amountColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                tx.categoryKey != null
                    ? CategoryConfig.getCategoryIcon(tx.categoryKey)
                    : (isExpense
                          ? FLucideIcons.trendingDown
                          : FLucideIcons.trendingUp),
                size: 18,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 12),
            // Description and added by
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description != null && tx.description!.isNotEmpty
                        ? tx.description!
                        : (tx.categoryKey != null
                              ? TransactionCategory.fromKey(
                                  tx.categoryKey,
                                ).displayText
                              : t.category.other),
                    style: AppTextStyles.listTitle(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.addedByUsername ?? "Unknown"} · $timeDisplay',
                    style: AppTextStyles.detailLabel(theme),
                  ),
                ],
              ),
            ),
            // Amount - using unified AmountText component
            tx.display != null
                ? AmountText.fromDisplay(
                    display: tx.display!,
                    type: transactionType,
                    style: AppTextStyles.listTitle(theme),
                  )
                : AmountText(
                    amount: AmountFormatter.parseDecimal(tx.amount),
                    type: transactionType,
                    currency: tx.currency,
                    style: AppTextStyles.listTitle(theme),
                  ),
          ],
        ),
      ),
    );
  }
}
