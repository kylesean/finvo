import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/network_client.dart';
import '../models/statistics_models.dart';
import '../../../shared/services/response_parser.dart';

part 'statistics_service.g.dart';

class StatisticsService {
  final NetworkClient _networkClient;

  StatisticsService(this._networkClient);

  /// Get statistics overview
  Future<StatisticsOverview> getOverview({
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? accountTypes,
  }) async {
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
    final queryParams = <String, String>{
      'time_range': timeRange.name,
      'transaction_type': chartType.name,
    };
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }

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
    final queryParams = <String, String>{
      'time_range': timeRange.name,
      'limit': limit.toString(),
    };
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }

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
    final queryParams = <String, String>{
      'time_range': timeRange.name,
      'sort_by': sortBy.name,
      'page': page.toString(),
      'size': pageSize.toString(),
    };
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }

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
    required String timeRange,
    String? startDate,
    String? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = <String, dynamic>{'time_range': timeRange};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }

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
    required String timeRange,
    String? startDate,
    String? endDate,
    List<String>? accountTypes,
  }) async {
    final queryParams = <String, dynamic>{'time_range': timeRange};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (accountTypes != null && accountTypes.isNotEmpty) {
      queryParams['account_types'] = accountTypes.join(',');
    }

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
