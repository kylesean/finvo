// features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar/monthly_calendar_view.dart';
import '../widgets/feed/sliver_transaction_feed_view.dart';
import '../providers/home_providers.dart';
import 'package:forui/forui.dart';
import '../../shared_space/widgets/notification_icon.dart';
import 'package:augo/i18n/strings.g.dart';
import 'package:augo/shared/utils/amount_formatter.dart';
import '../models/total_expense_model.dart';
import 'dart:async';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // Add scroll listener to trigger load more
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.axis == Axis.vertical &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          final notifier = ref.read(transactionFeedProvider.notifier);
          final feedState = ref.read(transactionFeedProvider);
          if (!feedState.isLoadingMore && !feedState.hasReachedMax) {
            unawaited(notifier.fetchMoreTransactions());
          }
        }
        return false;
      },
      child: Scaffold(
        // Set Scaffold background to white (background), fully resolving bottom overscroll black line issue
        backgroundColor: theme.colors.background,
        body: Stack(
          children: [
            // Bottom layer: top black background, covering iOS pull-down overscroll area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(color: theme.colors.primary),
            ),
            // Main content layer
            RefreshIndicator(
              color: theme.colors.primary,
              // Pull-to-refresh indicator background color, keep white
              backgroundColor: theme.colors.background,
              onRefresh: () async {
                await ref.read(transactionFeedProvider.notifier).refreshFeed();
              },
              child: CustomScrollView(
                slivers: [
                  // Header - SliverAppBar (black)
                  SliverAppBar(
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: false,
                    backgroundColor: theme.colors.primary,
                    flexibleSpace: const _WelcomeHeader(),
                    actions: const [NotificationIcon(), SizedBox(width: 16)],
                  ),
                  // Main content area
                  SliverToBoxAdapter(
                    child: Container(
                      // Key: outer container set to black (primary) to seamlessly connect with Header
                      color: theme.colors.primary,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme
                              .colors
                              .background, // Inner content set to white
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              theme.style.borderRadius.xl.topLeft.x + 4,
                            ),
                            topRight: Radius.circular(
                              theme.style.borderRadius.xl.topRight.x + 4,
                            ),
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Calendar component
                            Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 4),
                              child: MonthlyCalendarView(),
                            ),
                            // Tab button bar
                            _FixedTabBar(),
                            // Remove bottom padding since list follows immediately
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Transaction list - using Sliver version
                  // Wrapped in SliverMainAxisGroup to ensure consistent background color (if needed)
                  // or placed directly. We need to set background color for the list, which can be done via
                  // SliverToBoxAdapter drawing a background, or handled in SliverTransactionFeedView.
                  // Since SliverList has no backgroundColor property, the common approach is
                  // to keep the entire CustomScrollView background consistent, or use DecoratedSliver (Flutter 3.13+)

                  // To ensure the list background is white (theme.colors.background),
                  // we can place a DecoratedSliver before it, wrapping the FeedView.
                  // But DecoratedSliver requires a specific Flutter version.
                  // Simple approach: Scaffold already sets background below Header (via main content area Container).
                  // But for Infinite List, we need to ensure it extends to the bottom.
                  // We use a Consumer to build SliverTransactionFeedView based on current Tab type
                  Consumer(
                    builder: (context, ref, child) {
                      final currentSelectedType = ref.watch(
                        currentTransactionFeedTypeProvider,
                      );
                      // Use DecoratedSliver to ensure list area background is white
                      return DecoratedSliver(
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                        ),
                        sliver: SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 16,
                          ),
                          sliver: SliverTransactionFeedView(
                            key: ValueKey(currentSelectedType),
                            intendedFeedType: currentSelectedType,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ], // Stack children
        ), // Stack
      ),
    );
  }
}

// Fixed Tab button bar component
class _FixedTabBar extends ConsumerWidget {
  const _FixedTabBar();

  // Define Tab data structure - needs dynamic generation at build time for i18n support
  List<({TransactionFeedType type, String label})> _getTabData() {
    return [
      (type: TransactionFeedType.all, label: t.common.all),
      (type: TransactionFeedType.expense, label: t.transaction.expense),
      (type: TransactionFeedType.income, label: t.transaction.income),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final currentSelectedType = ref.watch(currentTransactionFeedTypeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _getTabData().map((tabInfo) {
          final isSelected = tabInfo.type == currentSelectedType;

          if (isSelected) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {}, // Empty function to keep button enabled
                  child: Text(
                    tabInfo.label,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.primaryForeground,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FButton(
                  variant: .outline,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {
                    ref
                        .read(currentTransactionFeedTypeProvider.notifier)
                        .set(tabInfo.type);
                  },
                  child: Text(
                    tabInfo.label,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}

// Header component showing total expense amount and yearly progress
class _WelcomeHeader extends ConsumerStatefulWidget {
  const _WelcomeHeader();

  @override
  ConsumerState<_WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends ConsumerState<_WelcomeHeader> {
  bool _isAmountVisible = true;

  // Calculate yearly time progress
  double _getYearProgress() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);
    final totalDays = endOfYear.difference(startOfYear).inDays;
    final passedDays = now.difference(startOfYear).inDays;
    return passedDays / totalDays;
  }

  String _formatAmount(TotalExpenseData data) {
    // Prefer backend-returned formatted string
    if (data.display != null) {
      return data.display!.fullString;
    }

    // Fallback to local formatting
    return AmountFormatter.formatCommon(
      data.totalExpense,
      currencyCode: data.currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final now = DateTime.now();
    final totalExpenseAsync = ref.watch(totalExpenseProvider);

    final yearProgress = _getYearProgress();
    final progressPercentage = (yearProgress * 100).toInt();

    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(color: colors.primary),
        child: ClipRect(
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Total expense label and eye icon
                        Row(
                          children: [
                            Text(
                              t.home.totalExpense,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colors.primaryForeground.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FButton.icon(
                              variant: .ghost,
                              onPress: () {
                                setState(() {
                                  _isAmountVisible = !_isAmountVisible;
                                });
                              },
                              child: Icon(
                                _isAmountVisible
                                    ? FLucideIcons.eye
                                    : FLucideIcons.eyeOff,
                                color: colors.primaryForeground.withValues(
                                  alpha: 0.8,
                                ),
                                size: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        // Total expense amount
                        totalExpenseAsync.when(
                          data: (data) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isAmountVisible
                                    ? _formatAmount(data)
                                    : t.home.amountHidden,
                                style: theme.typography.body.xl2.copyWith(
                                  color: colors.primaryForeground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _QuickStatItem(
                                    label: t.home.todayExpense,
                                    amount: data.todayExpense,
                                    currency: data.currency,
                                    isVisible: _isAmountVisible,
                                  ),
                                  const SizedBox(width: 24),
                                  _QuickStatItem(
                                    label: t.home.monthExpense,
                                    amount: data.monthExpense,
                                    currency: data.currency,
                                    isVisible: _isAmountVisible,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          loading: () => Text(
                            t.common.loading,
                            style: theme.typography.body.xl2.copyWith(
                              color: colors.primaryForeground.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (error, _) => Text(
                            _isAmountVisible ? '¥0.00' : t.home.amountHidden,
                            style: theme.typography.body.xl2.copyWith(
                              color: colors.primaryForeground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Yearly time progress bar - simplified version
                        Row(
                          children: [
                            Text(
                              t.home.yearProgress(year: now.year),
                              style: theme.typography.body.xs.copyWith(
                                color: colors.primaryForeground.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: colors.primaryForeground.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: yearProgress,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: colors.primaryForeground,
                                        borderRadius: BorderRadius.circular(
                                          1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$progressPercentage%',
                              style: theme.typography.body.xs.copyWith(
                                color: colors.primaryForeground.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final bool isVisible;

  const _QuickStatItem({
    required this.label,
    required this.amount,
    required this.currency,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final displayString = AmountFormatter.formatCommon(
      amount,
      currencyCode: currency,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: colors.primaryForeground.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isVisible ? displayString : '••••',
          style: theme.typography.body.md.copyWith(
            color: colors.primaryForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
