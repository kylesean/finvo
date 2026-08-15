import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/services/statistics_service.dart';
import 'package:finvo/shared/utils/error_message.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/i18n/strings.g.dart';

part 'statistics_provider.freezed.dart';
part 'statistics_provider.g.dart';

final _logger = Logger('Statistics');

/// Statistics state
@freezed
abstract class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    @Default(TimeRange.month) TimeRange timeRange,
    @Default(ChartType.expense) ChartType chartType,
    @Default(SortType.amount) SortType sortType,
    @Default(<String>[]) List<String> selectedAccountTypes,
    DateTime? customStartDate,
    DateTime? customEndDate,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMoreTopTransactions,
    String? error,

    /// The date range text used for display in the UI (only has a value in custom mode).
    String? dateRangeDisplayText,

    // Data
    StatisticsOverview? overview,
    TrendDataResponse? trendData,
    CategoryBreakdownResponse? categoryBreakdown,
    TopTransactionsResponse? topTransactions,
    CashFlowAnalysis? cashFlow,
    HealthScore? healthScore,
  }) = _StatisticsState;
}

/// Statistics state notifier
@riverpod
class Statistics extends _$Statistics {
  /// Monotonically increasing request generation. Any filter/range/sort change
  /// bumps it; responses whose generation no longer matches the latest one are
  /// stale and must be discarded so a fast filter switch can't be overwritten
  /// by an older, slower response.
  int _loadGeneration = 0;

  @override
  StatisticsState build() {
    return const StatisticsState();
  }

  /// Bump the load generation and clear the loading flag.
  ///
  /// Orphans any in-flight [loadStatistics] so it can't overwrite the state set
  /// by the caller, and resets `isLoading` because the orphaned request's own
  /// completion path (which normally clears it) will be skipped — otherwise the
  /// report would get stuck in a permanent loading state. Returns the new
  /// generation to compare against after the awaited fetch.
  int _orphanInFlight() {
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: false);
    return generation;
  }

  /// Load all statistics data
  Future<void> loadStatistics() async {
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(statisticsServiceProvider);
      // BRH-04: the cash-flow and health-score endpoints were fetched on every
      // report load but NO UI ever renders them (dead data) — two wasted
      // network round-trips per visit. They are removed from the load path;
      // the service methods and state fields stay for when a real report
      // surfaces them.
      final (
        StatisticsOverview overview,
        TrendDataResponse trendData,
        CategoryBreakdownResponse categoryBreakdown,
        TopTransactionsResponse topTransactions,
      ) = await (
        service.getOverview(
          timeRange: state.timeRange,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
        ),
        service.getTrendData(
          timeRange: state.timeRange,
          chartType: state.chartType,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
        ),
        service.getCategoryBreakdown(
          timeRange: state.timeRange,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
          // RPT-1: the category breakdown must follow the selected
          // income/expense chart type (server defaults to expense).
          transactionType: state.chartType.name,
        ),
        service.getTopTransactions(
          timeRange: state.timeRange,
          sortBy: state.sortType,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
          // RPT-1: same as above for the top-transactions ranking.
          transactionType: state.chartType.name,
          page: 1,
          pageSize: 15,
        ),
      ).wait;

      // Discard stale responses from superseded filter/sort/range changes,
      // or if the provider was disposed while fetching.
      if (!ref.mounted || generation != _loadGeneration) {
        _logger.fine(
          'Statistics: discarding stale response (generation $generation)',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        overview: overview,
        trendData: trendData,
        categoryBreakdown: categoryBreakdown,
        topTransactions: topTransactions,
      );
    } catch (e) {
      // Only surface errors for the latest generation; older failures belong
      // to superseded requests.
      if (!ref.mounted || generation == _loadGeneration) {
        state = state.copyWith(isLoading: false, error: safeErrorMessage(e));
      }
    }
  }

  /// Change time range and reload data
  Future<void> setTimeRange(
    TimeRange timeRange, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String? displayText;
    if (timeRange == TimeRange.custom && startDate != null && endDate != null) {
      displayText = formatDateRange(startDate, endDate);
    }
    state = state.copyWith(
      timeRange: timeRange,
      customStartDate: startDate,
      customEndDate: endDate,
      dateRangeDisplayText: displayText,
    );
    await loadStatistics();
  }

  /// Change chart type and reload trend data
  Future<void> setChartType(ChartType chartType) async {
    // Bump the shared generation so any in-flight loadStatistics for the old
    // chart type is discarded (otherwise it would overwrite the new chart).
    final generation = _orphanInFlight();
    state = state.copyWith(chartType: chartType);
    try {
      final service = ref.read(statisticsServiceProvider);
      // RPT-1: reload EVERY chart-type-dependent dataset — not just the
      // trend. The category breakdown and top-transactions ranking are also
      // filtered by income/expense (transaction_type) and would otherwise
      // keep showing the previous tab's data under the new tab's title.
      final (
        TrendDataResponse trendData,
        CategoryBreakdownResponse categoryBreakdown,
        TopTransactionsResponse topTransactions,
      ) = await (
        service.getTrendData(
          timeRange: state.timeRange,
          chartType: chartType,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
        ),
        service.getCategoryBreakdown(
          timeRange: state.timeRange,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
          transactionType: chartType.name,
        ),
        service.getTopTransactions(
          timeRange: state.timeRange,
          sortBy: state.sortType,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
          transactionType: chartType.name,
          page: 1,
          pageSize: 15,
        ),
      ).wait;
      if (generation != _loadGeneration) return;
      state = state.copyWith(
        trendData: trendData,
        categoryBreakdown: categoryBreakdown,
        topTransactions: topTransactions,
      );
    } catch (e) {
      _logger.warning('Report chart-type reload failed', e);
      // BRH-02: a sub-task failure must not flip the whole report page into
      // the error state — keep showing the already loaded data and surface
      // the failure as a transient toast instead.
      if (generation == _loadGeneration) {
        ToastService.showDestructive(
          description: Text('${t.common.loadFailed}: ${safeErrorMessage(e)}'),
        );
      }
    }
  }

  /// Change sort type and reload top transactions
  Future<void> setSortType(SortType sortType) async {
    // Same generation bump + isLoading reset as setChartType: orphan the
    // in-flight loadStatistics rather than let it clobber the new sort while
    // leaving isLoading stuck true.
    final generation = _orphanInFlight();
    state = state.copyWith(sortType: sortType);
    try {
      final service = ref.read(statisticsServiceProvider);
      final topTransactions = await service.getTopTransactions(
        timeRange: state.timeRange,
        sortBy: sortType,
        startDate: state.customStartDate,
        endDate: state.customEndDate,
        accountTypes: state.selectedAccountTypes.isNotEmpty
            ? state.selectedAccountTypes
            : null,
        page: 1,
        pageSize: 15,
      );
      if (generation != _loadGeneration) return;
      state = state.copyWith(topTransactions: topTransactions);
    } catch (e) {
      _logger.warning('Report top-transactions reload failed', e);
      // BRH-02: same degradation as setChartType — never flip the page into
      // the full error state for a sub-task failure.
      if (generation == _loadGeneration) {
        ToastService.showDestructive(
          description: Text('${t.common.loadFailed}: ${safeErrorMessage(e)}'),
        );
      }
    }
  }

  /// Set account type filters and reload data
  Future<void> setAccountTypes(List<String> accountTypes) async {
    state = state.copyWith(selectedAccountTypes: accountTypes);
    await loadStatistics();
  }

  /// Load more top transactions
  Future<void> loadMoreTopTransactions() async {
    if (state.isLoadingMoreTopTransactions ||
        state.topTransactions == null ||
        !state.topTransactions!.hasMore) {
      return;
    }

    // Capture the generation: a filter/range/sort switch invalidates this
    // request. Without this guard, a stale page-2 response from the old filter
    // would be appended to the new filter's list, producing a mixed view.
    final generation = _loadGeneration;

    state = state.copyWith(isLoadingMoreTopTransactions: true);

    try {
      final service = ref.read(statisticsServiceProvider);
      final nextPage = (state.topTransactions?.page ?? 1) + 1;

      final result = await service.getTopTransactions(
        timeRange: state.timeRange,
        sortBy: state.sortType,
        startDate: state.customStartDate,
        endDate: state.customEndDate,
        accountTypes: state.selectedAccountTypes.isNotEmpty
            ? state.selectedAccountTypes
            : null,
        page: nextPage,
        pageSize: state.topTransactions?.pageSize ?? 15,
      );

      // Drop stale responses from superseded filters/sorts. The whole list is
      // about to be replaced by the newer loadStatistics, so also clear the
      // in-flight flag to avoid a stuck "loading more" spinner.
      if (generation != _loadGeneration) {
        state = state.copyWith(isLoadingMoreTopTransactions: false);
        return;
      }

      state = state.copyWith(
        topTransactions: result.copyWith(
          items: [...state.topTransactions!.items, ...result.items],
        ),
        isLoadingMoreTopTransactions: false,
      );
    } catch (e) {
      // F1: reset the flag UNCONDITIONALLY. The success path already handles
      // the stale-generation case, but when the request FAILS after a filter/
      // sort switch bumped the generation, neither branch would reset it —
      // leaving isLoadingMoreTopTransactions true forever: the footer spins
      // forever AND the entry guard above blocks all future load-more calls
      // (pagination is permanently dead until a full reload).
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingMoreTopTransactions: false);
      if (generation == _loadGeneration) {
        // Keep the already-loaded data visible; log the failure for diagnostics.
        _logger.warning('Failed to load more top transactions: $e');
      }
    }
  }
}
