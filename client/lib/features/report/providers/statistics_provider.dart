import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/features/report/services/statistics_service.dart';

part 'statistics_provider.g.dart';

final _logger = Logger('Statistics');

/// Statistics state
class StatisticsState {
  final TimeRange timeRange;
  final ChartType chartType;
  final SortType sortType;
  final List<String> selectedAccountTypes;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool isLoading;
  final bool isLoadingMoreTopTransactions;
  final String? error;

  /// The date range text used for display in the UI (only has a value in custom mode).
  final String? dateRangeDisplayText;

  // Data
  final StatisticsOverview? overview;
  final TrendDataResponse? trendData;
  final CategoryBreakdownResponse? categoryBreakdown;
  final TopTransactionsResponse? topTransactions;
  final CashFlowAnalysis? cashFlow;
  final HealthScore? healthScore;

  const StatisticsState({
    this.timeRange = TimeRange.month,
    this.chartType = ChartType.expense,
    this.sortType = SortType.amount,
    this.selectedAccountTypes = const [],
    this.customStartDate,
    this.customEndDate,
    this.isLoading = false,
    this.isLoadingMoreTopTransactions = false,
    this.error,
    this.dateRangeDisplayText,
    this.overview,
    this.trendData,
    this.categoryBreakdown,
    this.topTransactions,
    this.cashFlow,
    this.healthScore,
  });

  StatisticsState copyWith({
    TimeRange? timeRange,
    ChartType? chartType,
    SortType? sortType,
    List<String>? selectedAccountTypes,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool? isLoading,
    bool? isLoadingMoreTopTransactions,
    String? error,
    String? dateRangeDisplayText,
    StatisticsOverview? overview,
    TrendDataResponse? trendData,
    CategoryBreakdownResponse? categoryBreakdown,
    TopTransactionsResponse? topTransactions,
    CashFlowAnalysis? cashFlow,
    HealthScore? healthScore,
  }) {
    return StatisticsState(
      timeRange: timeRange ?? this.timeRange,
      chartType: chartType ?? this.chartType,
      sortType: sortType ?? this.sortType,
      selectedAccountTypes: selectedAccountTypes ?? this.selectedAccountTypes,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMoreTopTransactions:
          isLoadingMoreTopTransactions ?? this.isLoadingMoreTopTransactions,
      error: error,
      dateRangeDisplayText: dateRangeDisplayText ?? this.dateRangeDisplayText,
      overview: overview ?? this.overview,
      trendData: trendData ?? this.trendData,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      topTransactions: topTransactions ?? this.topTransactions,
      cashFlow: cashFlow ?? this.cashFlow,
      healthScore: healthScore ?? this.healthScore,
    );
  }
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

  /// Load all statistics data
  Future<void> loadStatistics() async {
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(statisticsServiceProvider);
      // Fetch all data in parallel. Overview/trend/category/top-transactions are
      // core and fail together; cash-flow and health-score are supplementary and
      // degrade gracefully to null on error so the report still renders.
      final (
        StatisticsOverview overview,
        TrendDataResponse trendData,
        CategoryBreakdownResponse categoryBreakdown,
        TopTransactionsResponse topTransactions,
        CashFlowAnalysis? cashFlow,
        HealthScore? healthScore,
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
        ),
        service.getTopTransactions(
          timeRange: state.timeRange,
          sortBy: state.sortType,
          startDate: state.customStartDate,
          endDate: state.customEndDate,
          accountTypes: state.selectedAccountTypes.isNotEmpty
              ? state.selectedAccountTypes
              : null,
          page: 1,
          pageSize: 15,
        ),
        service
            .getCashFlow(
              timeRange: state.timeRange.name,
              startDate: state.customStartDate?.toIso8601String(),
              endDate: state.customEndDate?.toIso8601String(),
              accountTypes: state.selectedAccountTypes.isNotEmpty
                  ? state.selectedAccountTypes
                  : null,
            )
            .then<CashFlowAnalysis?>((res) => res)
            .catchError((_) => null),
        service
            .getHealthScore(
              timeRange: state.timeRange.name,
              startDate: state.customStartDate?.toIso8601String(),
              endDate: state.customEndDate?.toIso8601String(),
              accountTypes: state.selectedAccountTypes.isNotEmpty
                  ? state.selectedAccountTypes
                  : null,
            )
            .then<HealthScore?>((res) => res)
            .catchError((_) => null),
      ).wait;

      // Discard stale responses from superseded filter/sort/range changes.
      if (generation != _loadGeneration) {
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
        cashFlow: cashFlow,
        healthScore: healthScore,
      );
    } catch (e) {
      // Only surface errors for the latest generation; older failures belong
      // to superseded requests.
      if (generation == _loadGeneration) {
        state = state.copyWith(isLoading: false, error: e.toString());
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
      final format = DateFormat('yyyy.MM.dd');
      displayText = '${format.format(startDate)} - ${format.format(endDate)}';
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
    final generation = ++_loadGeneration;
    state = state.copyWith(chartType: chartType);
    try {
      final service = ref.read(statisticsServiceProvider);
      final trendData = await service.getTrendData(
        timeRange: state.timeRange,
        chartType: chartType,
        startDate: state.customStartDate,
        endDate: state.customEndDate,
        accountTypes: state.selectedAccountTypes.isNotEmpty
            ? state.selectedAccountTypes
            : null,
      );
      if (generation != _loadGeneration) return;
      state = state.copyWith(trendData: trendData);
    } catch (e) {
      if (generation == _loadGeneration) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  /// Change sort type and reload top transactions
  Future<void> setSortType(SortType sortType) async {
    final generation = ++_loadGeneration;
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
      if (generation == _loadGeneration) {
        state = state.copyWith(error: e.toString());
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

      state = state.copyWith(
        topTransactions: result.copyWith(
          items: [...state.topTransactions!.items, ...result.items],
        ),
        isLoadingMoreTopTransactions: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMoreTopTransactions: false);
      // Keep the already-loaded data visible; log the failure for diagnostics.
      _logger.warning('Failed to load more top transactions: $e');
    }
  }
}
