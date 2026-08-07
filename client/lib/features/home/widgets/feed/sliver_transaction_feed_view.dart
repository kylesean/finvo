import 'dart:async';

import 'package:flutter/material.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/home/widgets/feed/transaction_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class SliverTransactionFeedView extends ConsumerWidget {
  final TransactionFeedType intendedFeedType;

  const SliverTransactionFeedView({super.key, required this.intendedFeedType});

  // Build skeleton for a single transaction card
  Widget _buildTransactionCardSkeleton(BuildContext context) {
    final semantic = context.theme.semantic;

    final Color shimmerBaseColor = semantic.shimmerBase;
    final Color shimmerHighlightColor = semantic.shimmerHighlight;
    final Color placeholderShapeColor = semantic.shimmerBase;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ), // Match padding of real card
      color: Colors
          .transparent, // Transparent background, background color controlled by external container
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1200),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Match real card centering
          children: [
            // Left: category icon
            Container(
              width: 44, // Match real card width 44
              height: 44,
              decoration: BoxDecoration(
                color: placeholderShapeColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16), // Match real card spacing 16
            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: title and time
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 100,
                        color: placeholderShapeColor,
                      ),
                      const Spacer(), // Key: push right elements to the edge, match Expanded layout of real card
                      Container(
                        height: 12,
                        width: 40,
                        color: placeholderShapeColor,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 12, // Simulate more icon
                        width: 12,
                        decoration: BoxDecoration(
                          color: placeholderShapeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second row: labels and amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 24,
                        width: 60,
                        decoration: BoxDecoration(
                          color: placeholderShapeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 80,
                        color: placeholderShapeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;

    final TransactionFeedType globalCurrentFeedType = ref.watch(
      currentTransactionFeedTypeProvider,
    );
    final TransactionFeedState feedState = ref.watch(transactionFeedProvider);
    final List<TransactionModel> transactions = feedState.transactions;

    final shouldShowSkeletonDueToTypeMismatch =
        intendedFeedType != globalCurrentFeedType;

    // Skeleton state: only replace the list with skeletons when there is
    // nothing to show yet. A pull-to-refresh (isLoading with data already
    // present) must keep the current rows visible — the RefreshIndicator's
    // own spinner already communicates progress.
    if (shouldShowSkeletonDueToTypeMismatch ||
        (feedState.isLoading &&
            transactions.isEmpty &&
            intendedFeedType == globalCurrentFeedType) ||
        (feedState.isLoadingMore &&
            transactions.isEmpty &&
            !feedState.hasReachedMax)) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index.isOdd) {
              return const FDivider(axis: Axis.horizontal);
            }
            return _buildTransactionCardSkeleton(context);
          },
          childCount: 5 * 2 - 1, // 5 items + 4 dividers
        ),
      );
    }

    // Error state: only when there is nothing to show. A load-more failure
    // (hasLoadMoreError) must not wipe the already-rendered feed — it is
    // surfaced via the retry footer instead.
    if (feedState.errorMessage != null &&
        transactions.isEmpty &&
        intendedFeedType == globalCurrentFeedType) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${t.common.loadFailed}: ${feedState.errorMessage}',
                style: AppTextStyles.listSubtitle(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FButton(
                variant: .outline,
                onPress: () => unawaited(
                  ref.read(transactionFeedProvider.notifier).refreshFeed(),
                ),
                child: Text(t.common.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (transactions.isEmpty &&
        !feedState.isLoadingMore &&
        intendedFeedType == globalCurrentFeedType) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.home.noTransactions,
                style: theme.typography.body.md.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              FButton(
                mainAxisSize: MainAxisSize.min,
                onPress: () => unawaited(
                  ref.read(transactionFeedProvider.notifier).refreshFeed(),
                ),
                child: Text(t.home.tryRefresh),
              ),
            ],
          ),
        ),
      );
    }

    if (intendedFeedType != globalCurrentFeedType) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Normal list
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Handle divider logic
          // Actual item index = index ~/ 2
          // Divider index = odd numbers

          final int itemIndex = index ~/ 2;

          // Load more / no more at the end of the list
          if (itemIndex >= transactions.length) {
            // Extra items at the bottom of the list (Loading skeleton or no more text)
            // At this point index must be even, because the divider logic handled middle parts
            if (feedState.isLoadingMore && transactions.isNotEmpty) {
              return _buildTransactionCardSkeleton(context);
            } else if (feedState.hasReachedMax && transactions.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    t.home.noMoreData,
                    style: AppTextStyles.listSubtitle(theme),
                  ),
                ),
              );
            } else if (feedState.hasLoadMoreError && transactions.isNotEmpty) {
              // Load-more failed: keep the rendered list, offer a retry
              // instead of a misleading "no more data" footer.
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: FButton(
                    variant: .outline,
                    onPress: () => ref
                        .read(transactionFeedProvider.notifier)
                        .fetchMoreTransactions(),
                    child: Text(t.common.retry),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          if (index.isOdd) {
            return Divider(
              height: 0.5,
              thickness: 0.5,
              color: colors.border.withValues(alpha: 0.7),
            );
          }

          final transaction = transactions[itemIndex];
          return TransactionCard(transaction: transaction);
        },
        // Calculate childCount
        // N items have N-1 dividers -> 2*N - 1
        // Plus footer (Loading/NoMore, as 1 extra item) -> (N+1) items -> 2*(N+1) - 1 ?
        // Simplifying logic:
        // childCount = (transactions.length * 2) - 1; // Base count
        // If has footer (loading or no more):
        //   childCount += 2; // +1 divider +1 footer item
        // Edge case: if list is empty, childCount is 0 (already handled by empty state)
        childCount: _calculateChildCount(transactions.length, feedState),
      ),
    );
  }

  int _calculateChildCount(int transactionCount, TransactionFeedState state) {
    if (transactionCount == 0) return 0;
    int count = transactionCount * 2 - 1;
    if ((state.isLoadingMore && transactionCount > 0) ||
        (state.hasReachedMax && transactionCount > 0) ||
        (state.hasLoadMoreError && transactionCount > 0)) {
      count += 2; // +1 Divider +1 Footer
    }
    return count;
  }
}
