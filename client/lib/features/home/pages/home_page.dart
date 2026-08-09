import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/home/widgets/calendar/monthly_calendar_view.dart';
import 'package:finvo/features/home/widgets/feed/sliver_transaction_feed_view.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/shared_space/widgets/notification_icon.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/features/home/models/total_expense_model.dart';
import 'dart:async';

/// Height factor for the top overscroll cover layer (see [HomePage]).
const double _overscrollCoverFactor = 0.5;

/// Resolve the scroll physics for the home feed.
///
/// On iOS, use ClampingScrollPhysics to prevent excessive bouncing overscroll
/// that causes large visual gaps. RefreshIndicator still works because it
/// detects pull-down via dragDetails in ScrollUpdateNotification, not via
/// negative scroll pixels. Android keeps default ClampingScrollPhysics.
/// Guarded with kIsWeb: dart:io Platform is unavailable on web and would throw
/// UnsupportedError at build time.
ScrollPhysics? _resolveHomeScrollPhysics() {
  return !kIsWeb && Platform.isIOS ? const ClampingScrollPhysics() : null;
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
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
              height:
                  MediaQuery.of(context).size.height * _overscrollCoverFactor,
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
                physics: _resolveHomeScrollPhysics(),
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

  // Feed types are a compile-time constant; only the i18n label is resolved at
  // build time so locale switches still refresh the text. Keeping the type list
  // static avoids re-allocating a record list on every build.
  static const List<TransactionFeedType> _types = [
    TransactionFeedType.all,
    TransactionFeedType.expense,
    TransactionFeedType.income,
  ];

  String _labelFor(TransactionFeedType type) => switch (type) {
    TransactionFeedType.all => t.common.all,
    TransactionFeedType.expense => t.transaction.expense,
    TransactionFeedType.income => t.transaction.income,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final currentSelectedType = ref.watch(currentTransactionFeedTypeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _types.map((type) {
          final isSelected = type == currentSelectedType;

          if (isSelected) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: () {}, // Empty function to keep button enabled
                  child: Text(
                    _labelFor(type),
                    style: AppTextStyles.tabSelected(theme),
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
                        .set(type);
                  },
                  child: Text(
                    _labelFor(type),
                    style: AppTextStyles.tabUnselected(theme),
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
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Re-render at the next local midnight so the year countdown and any
  /// date-derived labels stay fresh without requiring a manual rebuild.
  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      () {
        if (mounted) {
          setState(() {});
          _scheduleMidnightRefresh();
        }
      },
    );
  }

  // Calculate yearly remaining time (countdown)
  ({
    int remainingDays,
    int totalDays,
    double remainingFraction,
    int remainingPercentage,
  })
  _getYearRemaining() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);
    final totalDays = endOfYear.difference(startOfYear).inDays;
    final remainingDays = endOfYear.difference(now).inDays;
    final remainingFraction = (remainingDays / totalDays).clamp(0.0, 1.0);
    final remainingPercentage = (remainingFraction * 100).round();
    return (
      remainingDays: remainingDays,
      totalDays: totalDays,
      remainingFraction: remainingFraction,
      remainingPercentage: remainingPercentage,
    );
  }

  String _formatAmount(TotalExpenseData data) {
    // Prefer backend-returned formatted string
    if (data.display != null) {
      return data.display!.fullString;
    }

    // Fallback to local formatting (totalExpense is a server-serialized string)
    return AmountFormatter.formatWithCurrency(
      data.totalExpense,
      currencyCode: data.currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final colors = theme.colors;
    final now = DateTime.now();
    final totalExpenseAsync = ref.watch(totalExpenseProvider);

    final yearRemaining = _getYearRemaining();

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
                              style: AppTextStyles.statLabelOnDark(theme),
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
                                style: AppTextStyles.statValueOnDark(theme),
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
                            style: AppTextStyles.statValueOnDark(theme),
                          ),
                          error: (error, _) => Text(
                            _isAmountVisible
                                ? AmountFormatter.formatCommon(
                                    0,
                                    currencyCode: ref
                                        .read(financialSettingsProvider)
                                        .primaryCurrency,
                                  )
                                : t.home.amountHidden,
                            style: AppTextStyles.statValueOnDark(theme),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Yearly remaining time (Countdown) progress bar with sense of urgency
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FLucideIcons.calendarDays,
                                      size: 13,
                                      color: colors.primaryForeground
                                          .withValues(alpha: 0.9),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      t.home.yearProgress(
                                        year: now.year.toString(),
                                      ),
                                      style: AppTextStyles.statLabelOnDark(
                                        theme,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  t.home.yearRemainingInfo(
                                    days: yearRemaining.remainingDays
                                        .toString(),
                                    percent: yearRemaining.remainingPercentage
                                        .toString(),
                                  ),
                                  style: AppTextStyles.statLabelOnDark(
                                    theme,
                                  ).copyWith(letterSpacing: 0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colors.primaryForeground.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: yearRemaining.remainingFraction,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: colors.primaryForeground,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.primaryForeground
                                              .withValues(alpha: 0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
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
  final String amount;
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

    final displayString = AmountFormatter.formatWithCurrency(
      amount,
      currencyCode: currency,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.statLabelOnDarkSecondary(theme)),
        const SizedBox(height: 2),
        Text(
          isVisible ? displayString : '••••',
          style: AppTextStyles.statValueOnDarkSecondary(theme),
        ),
      ],
    );
  }
}
