import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/shared/services/response_parser.dart';

part 'statistics_service.g.dart';

class StatisticsService {
  final NetworkClient _networkClient;

  StatisticsService(this._networkClient);

  /// Format a date as `yyyy-MM-dd` (the server-side "calendar day" contract).
  ///
  /// F3: the previous `toIso8601String()` emitted local wall-clock time with
  /// NO offset (e.g. `2026-08-01T00:00:00.000`), which the server interprets
  /// as UTC. For a UTC+8 user, transactions between 00:00 and 08:00 on the
  /// boundary day fall OUTSIDE the requested range — a silent one-day drift
  /// on every custom range. The feed (home) already sends plain `yyyy-MM-dd`
  /// and the server treats it as the local calendar day; statistics must
  /// follow the same convention.
  static String _formatDateParam(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  /// Build the shared time-range + date + account-type query parameters that
  /// every statistics endpoint accepts, so the repeated per-method construction
  /// is expressed once.
  Map<String, String> _baseQuery({
    required TimeRange timeRange,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) {
    final queryParams = <String, String>{'time_range': timeRange.name};
    if (startDate != null) {
      queryParams['start_date'] = _formatDateParam(startDate);
    }
    if (endDate != null) {
      queryParams['end_date'] = _formatDateParam(endDate);
    }
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }
    return queryParams;
  }

  /// Get statistics overview
  Future<StatisticsOverview> getOverview({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    );

    return await _networkClient.request<StatisticsOverview>(
      '/statistics/overview',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, StatisticsOverview.fromJson),
    );
  }

  /// Get trend data
  Future<TrendDataResponse> getTrendData({
    TimeRange timeRange = TimeRange.month,
    ChartType chartType = ChartType.expense,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    )..['transaction_type'] = chartType.name;

    return await _networkClient.request<TrendDataResponse>(
      '/statistics/trends',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, TrendDataResponse.fromJson),
    );
  }

  /// Get category breakdown
  Future<CategoryBreakdownResponse> getCategoryBreakdown({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
    String? transactionType,
    int limit = 10,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    );
    // RPT-1: without transaction_type the server defaults to expense, so the
    // income tab showed expense categories. When null, the parameter is
    // omitted entirely (server default preserved).
    if (transactionType != null) {
      queryParams['transaction_type'] = transactionType;
    }
    queryParams['limit'] = limit.toString();

    return await _networkClient.request<CategoryBreakdownResponse>(
      '/statistics/categories',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, CategoryBreakdownResponse.fromJson),
    );
  }

  /// Get large expense ranking
  Future<TopTransactionsResponse> getTopTransactions({
    TimeRange timeRange = TimeRange.month,
    SortType sortBy = SortType.amount,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
    String? transactionType,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    );
    // RPT-1: mirror the trend endpoint's transaction_type so the top list
    // follows the selected income/expense tab (server defaults to expense).
    if (transactionType != null) {
      queryParams['transaction_type'] = transactionType;
    }
    queryParams
      ..['sort_by'] = sortBy.name
      ..['page'] = page.toString()
      ..['size'] = pageSize.toString();

    return await _networkClient.request<TopTransactionsResponse>(
      '/statistics/top-transactions',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, TopTransactionsResponse.fromJson),
    );
  }

  /// Get cash flow analysis for the period
  Future<CashFlowAnalysis> getCashFlow({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    );

    return await _networkClient.request<CashFlowAnalysis>(
      '/statistics/cash-flow',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          ResponseParser.parseItem(json, CashFlowAnalysis.fromJson),
    );
  }

  /// Get financial health score for the period
  Future<HealthScore> getHealthScore({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    );

    return await _networkClient.request<HealthScore>(
      '/statistics/health-score',
      method: HttpMethod.get,
      queryParameters: queryParams,
      fromJsonT: (json) => ResponseParser.parseItem(json, HealthScore.fromJson),
    );
  }
}

// Provider
@riverpod
StatisticsService statisticsService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return StatisticsService(networkClient);
}
