import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/report/models/statistics_models.dart';
import 'package:finvo/shared/services/response_parser.dart';

part 'statistics_service.g.dart';

class StatisticsService {
  final NetworkClient _networkClient;

  StatisticsService(this._networkClient);

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
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
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
    int limit = 10,
  }) async {
    final queryParams = _baseQuery(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      accountTypes: accountTypes,
    )..['limit'] = limit.toString();

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
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams =
        _baseQuery(
            timeRange: timeRange,
            startDate: startDate,
            endDate: endDate,
            accountTypes: accountTypes,
          )
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
