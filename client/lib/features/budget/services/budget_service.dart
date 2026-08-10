import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/budget/models/budget_models.dart';

class BudgetService {
  final NetworkClient _networkClient;

  BudgetService(this._networkClient);

  /// Get budget summary
  ///
  /// Includes usage, totals, and other statistics for all budgets
  /// [includePaused] whether to include paused budgets
  Future<BudgetSummary> getSummary({bool includePaused = false}) async {
    return await _networkClient.request<BudgetSummary>(
      '/budgets/summary',
      method: HttpMethod.get,
      queryParameters: {'include_paused': includePaused},
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        BudgetSummary.fromJson,
        endpoint: '/budgets/summary',
      ),
    );
  }

  /// Get list of all budgets
  Future<List<Budget>> getAll() async {
    return await _networkClient.request<List<Budget>>(
      '/budgets',
      method: HttpMethod.get,
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'];
          if (data is List) {
            return data
                .map((e) => Budget.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        throw DataParsingException('Invalid format for /budgets response');
      },
    );
  }

  /// Get single budget details
  Future<Budget> getById(String id) async {
    return await _networkClient.request<Budget>(
      '/budgets/$id',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        Budget.fromJson,
        endpoint: '/budgets/$id',
      ),
    );
  }

  /// Get single budget with usage details (spent, remaining, percentage, status)
  Future<BudgetWithUsage> getDetailWithUsage(String id) async {
    return await _networkClient.request<BudgetWithUsage>(
      '/budgets/$id',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        BudgetWithUsage.fromBudgetResponse,
        endpoint: '/budgets/$id detail',
      ),
    );
  }

  /// Delete budget
  Future<void> delete(String id) async {
    await _networkClient.request<void>(
      '/budgets/$id',
      method: HttpMethod.delete,
      fromJsonT: (_) {},
    );
  }

  /// Create budget
  Future<Budget> create(BudgetCreateRequest request) async {
    return await _networkClient.request<Budget>(
      '/budgets',
      method: HttpMethod.post,
      data: request.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        Budget.fromJson,
        endpoint: 'POST /budgets',
      ),
    );
  }

  /// Update budget
  Future<Budget> update(String id, BudgetUpdateRequest request) async {
    return await _networkClient.request<Budget>(
      '/budgets/$id',
      method: HttpMethod.put,
      data: request.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        Budget.fromJson,
        endpoint: 'PUT /budgets/$id',
      ),
    );
  }

  /// Get budget threshold settings
  Future<BudgetSettings> getSettings() async {
    return await _networkClient.request<BudgetSettings>(
      '/budgets/settings/me',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        BudgetSettings.fromJson,
        endpoint: '/budgets/settings/me',
      ),
    );
  }

  /// Update budget threshold settings
  Future<BudgetSettings> updateSettings(
    BudgetSettingsUpdateRequest request,
  ) async {
    return await _networkClient.request<BudgetSettings>(
      '/budgets/settings/me',
      method: HttpMethod.put,
      data: request.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        BudgetSettings.fromJson,
        endpoint: 'PUT /budgets/settings/me',
      ),
    );
  }
}

/// BudgetService Provider
final budgetServiceProvider = Provider<BudgetService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return BudgetService(networkClient);
});
