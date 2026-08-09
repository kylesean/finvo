import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:animate_do/animate_do.dart';
import 'package:finvo/shared/widgets/app_filter_chip.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/providers/statistics_provider.dart';
import 'package:finvo/features/report/widgets/statistics_widgets.dart';
import 'package:finvo/features/report/widgets/filter_sheet.dart';
import 'package:finvo/features/report/widgets/date_range_picker_sheet.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'dart:async';
import 'package:finvo/shared/theme/form_text_styles.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Load statistics on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(statisticsProvider.notifier).loadStatistics());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(
        ref.read(statisticsProvider.notifier).loadMoreTopTransactions(),
      );
    }
  }

  void _showFilterSheet() {
    final state = ref.read(statisticsProvider);
    unawaited(
      FilterSheet.show(
        context,
        selectedAccountTypes: state.selectedAccountTypes,
        onApply: (accountTypes) {
          unawaited(
            ref.read(statisticsProvider.notifier).setAccountTypes(accountTypes),
          );
        },
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final initial = ref.read(statisticsProvider);
    bool confirmed = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerSheet(
        initialStart: initial.customStartDate,
        initialEnd: initial.customEndDate,
        onConfirm: (startDate, endDate) {
          confirmed = true;
          unawaited(
            ref
                .read(statisticsProvider.notifier)
                .setTimeRange(
                  TimeRange.custom,
                  startDate: startDate,
                  endDate: endDate,
                ),
          );
        },
      ),
    );
    // Re-read the provider after the await: the snapshot taken before the sheet
    // may be stale if a time-range change was applied while it was open.
    if (!confirmed) {
      final latest = ref.read(statisticsProvider);
      if (latest.timeRange == TimeRange.custom &&
          latest.customStartDate == null) {
        unawaited(
          ref.read(statisticsProvider.notifier).setTimeRange(TimeRange.month),
        );
      }
    }
  }

  void _onTimeRangeSelected(TimeRange timeRange) {
    if (timeRange == TimeRange.custom) {
      unawaited(_showDateRangePicker());
    } else {
      unawaited(ref.read(statisticsProvider.notifier).setTimeRange(timeRange));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),
            // Time range tabs (full width)
            _buildTimeRangeTabs(context, theme, state),
            // Content
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? _buildErrorState(context, theme, state.error!)
                  : _buildContent(context, theme, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FThemeData theme) {
    final colors = theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Left spacer to balance right button
          const SizedBox(width: 40),
          // Centered title
          Expanded(
            child: Text(
              t.statistics.title,
              style: AppTextStyles.listTitle(theme),
              textAlign: TextAlign.center,
            ),
          ),
          // Filter button
          FButton.icon(
            variant: .ghost,
            onPress: _showFilterSheet,
            child: Icon(FLucideIcons.settings, color: colors.foreground),
          ),
        ],
      ),
    );
  }

  /// Full-width time range tab bar (similar to home page design)
  Widget _buildTimeRangeTabs(
    BuildContext context,
    FThemeData theme,
    StatisticsState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: TimeRange.values.map((timeRange) {
          final isSelected = state.timeRange == timeRange;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: timeRange.label,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected && timeRange != TimeRange.custom) return;
                  _onTimeRangeSelected(timeRange);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    FThemeData theme,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.triangleAlert,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(t.common.loadFailed, style: AppTextStyles.listTitle(theme)),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: FButton(
                onPress: () {
                  unawaited(
                    ref.read(statisticsProvider.notifier).loadStatistics(),
                  );
                },
                child: Text(t.common.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FThemeData theme,
    StatisticsState state,
  ) {
    final colors = theme.colors;

    // Check if there is actual data to display
    // Compare numerically (via the typed extensions) rather than string equality,
    // so backend variants like "0", "0.0" or formatted values are handled.
    final hasNoData =
        state.overview == null ||
        (state.overview!.incomeNum == 0.0 &&
            state.overview!.expenseNum == 0.0 &&
            (state.categoryBreakdown?.items.isEmpty ?? true));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(statisticsProvider.notifier).loadStatistics();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Date range display (custom mode only)
            if (state.timeRange == TimeRange.custom &&
                state.dateRangeDisplayText != null) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.calendar,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.dateRangeDisplayText!,
                        style: AppTextStyles.actionText(theme),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (hasNoData) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: PremiumEmptyState(
                  onAddTransaction: () {
                    context.goNamed(AppRouteNames.ai);
                  },
                ),
              ),
            ] else ...[
              // Overview card
              if (state.overview != null) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: OverviewCard(overview: state.overview!),
                ),
                const SizedBox(height: 24),
              ],

              // Trend chart
              if (state.trendData != null) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: TrendChart(
                    trendData: state.trendData!,
                    chartType: state.chartType,
                    onChartTypeChanged: (chartType) {
                      unawaited(
                        ref
                            .read(statisticsProvider.notifier)
                            .setChartType(chartType),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Category Analysis (unified multi-view section)
              if (state.categoryBreakdown != null &&
                  state.categoryBreakdown!.items.isNotEmpty) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: CategoryAnalysisSection(
                    breakdown: state.categoryBreakdown!,
                    chartType: state.chartType,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Top transactions
              if (state.topTransactions != null &&
                  state.topTransactions!.items.isNotEmpty) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 600),
                  child: _buildTopTransactionsSection(context, theme, state),
                ),
                const SizedBox(height: 24),
              ],
            ],

            // Bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTransactionsSection(
    BuildContext context,
    FThemeData theme,
    StatisticsState state,
  ) {
    final colors = theme.colors;
    final transactions = state.topTransactions?.items ?? [];
    final hasMore = state.topTransactions?.hasMore ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t.statistics.ranking, style: AppTextStyles.listTitle(theme)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFilterChip(
                  icon: FLucideIcons.arrowDownWideNarrow,
                  isSelected: state.sortType == SortType.amount,
                  onTap: () => ref
                      .read(statisticsProvider.notifier)
                      .setSortType(SortType.amount),
                ),
                const SizedBox(width: 4),
                AppFilterChip(
                  icon: FLucideIcons.calendarRange,
                  isSelected: state.sortType == SortType.date,
                  onTap: () => ref
                      .read(statisticsProvider.notifier)
                      .setSortType(SortType.date),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Transaction list using ListView.builder for performance and simple pagination
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              transactions.length +
              (hasMore || state.isLoadingMoreTopTransactions ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index < transactions.length) {
              return TopTransactionCard(
                transaction: transactions[index],
                onTap: () {
                  unawaited(
                    context.pushNamed(
                      AppRouteNames.transactionDetail,
                      pathParameters: {'transactionId': transactions[index].id},
                    ),
                  );
                },
              );
            } else {
              if (state.isLoadingMoreTopTransactions) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              } else if (hasMore) {
                return const SizedBox(height: 40);
              } else {
                return const SizedBox();
              }
            }
          },
        ),
        if (!hasMore && transactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                t.statistics.noMoreData,
                style: AppTextStyles.detailLabel(theme),
              ),
            ),
          ),
      ],
    );
  }
}
