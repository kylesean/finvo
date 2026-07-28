import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/exceptions/app_exception.dart';
import '../models/statistics_models.dart';

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
      fromJsonT: (json) => _parseDataResponse<StatisticsOverview>(
        json,
        (data) => StatisticsOverview.fromJson(data),
        'overview',
      ),
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
      fromJsonT: (json) => _parseDataResponse<TrendDataResponse>(
        json,
        (data) => TrendDataResponse.fromJson(data),
        'trends',
      ),
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
      fromJsonT: (json) => _parseDataResponse<CategoryBreakdownResponse>(
        json,
        (data) => CategoryBreakdownResponse.fromJson(data),
        'categories',
      ),
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
      fromJsonT: (json) => _parseDataResponse<TopTransactionsResponse>(
        json,
        (data) => TopTransactionsResponse.fromJson(data),
        'top-transactions',
      ),
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
      fromJsonT: (json) => _parseDataResponse<CashFlowAnalysis>(
        json,
        (data) => CashFlowAnalysis.fromJson(data),
        'cash-flow',
      ),
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
      fromJsonT: (json) => _parseDataResponse<HealthScore>(
        json,
        (data) => HealthScore.fromJson(data),
        'health-score',
      ),
    );
  }

  /// Parse the unified response format
  T _parseDataResponse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
    String endpoint,
  ) {
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        try {
          return fromJson(data);
        } catch (e) {
          throw DataParsingException(
            'Failed to parse statistics response ($endpoint): ${e.toString()}',
          );
        }
      }
      throw DataParsingException(
        'API /statistics/$endpoint response data field format error, expected object, got ${data.runtimeType}',
      );
    }
    throw DataParsingException(
      'API /statistics/$endpoint expected an object response, but got ${json.runtimeType}',
    );
  }
}

// Provider
@riverpod
StatisticsService statisticsService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return StatisticsService(networkClient);
}
