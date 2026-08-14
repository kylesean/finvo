import 'package:dio/dio.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/features/home/models/daily_expense_summary_model.dart';
import 'package:finvo/features/home/models/total_expense_model.dart';
import 'package:finvo/features/home/models/transaction_model.dart';

import 'package:finvo/shared/services/response_parser.dart';

class HomeService {
  final NetworkClient _networkClient;

  HomeService(this._networkClient);

  // Get daily expense summary for a specific month (for calendar heat map)
  Future<CalendarMonthData> getCalendarMonthDetails(
    int year,
    int month, {
    CancelToken? cancelToken,
  }) async {
    return await _networkClient.request<CalendarMonthData>(
      '/home/calendar-month-details',
      method: HttpMethod.get,
      queryParameters: {'year': year, 'month': month},
      cancelToken: cancelToken,
      fromJsonT: (json) => _parseItemResponse(json, CalendarMonthData.fromJson),
    );
  }

  // Get total expense amount
  Future<TotalExpenseData> getTotalExpense({CancelToken? cancelToken}) async {
    return await _networkClient.request<TotalExpenseData>(
      '/home/total-expense',
      method: HttpMethod.get,
      cancelToken: cancelToken,
      fromJsonT: (json) => _parseItemResponse(json, TotalExpenseData.fromJson),
    );
  }

  // Get transaction feed data
  // New endpoint: GET /api/v1/transactions
  Future<List<TransactionModel>> getTransactionFeed({
    int page = 1,
    int size = 20,
    String? type, // EXPENSE, INCOME, TRANSFER
    String? date, // (YYYY-MM-DD)
    CancelToken? cancelToken,
  }) async {
    // Build query parameters
    final Map<String, dynamic> queryParameters = {'page': page, 'size': size};
    if (type != null && type.isNotEmpty) {
      queryParameters['transaction_type'] = type.toUpperCase();
    }
    if (date != null && date.isNotEmpty) {
      queryParameters['date'] = date;
    }

    return await _networkClient.request<List<TransactionModel>>(
      '/transactions',
      method: HttpMethod.get,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          _parseListResponse(json, TransactionModel.fromApiJson),
    );
  }

  // Get transaction details
  Future<TransactionModel> getTransactionDetail(
    String transactionId, {
    CancelToken? cancelToken,
  }) async {
    return await _networkClient.request<TransactionModel>(
      '/transactions/$transactionId',
      method: HttpMethod.get,
      cancelToken: cancelToken,
      fromJsonT: (json) =>
          _parseItemResponse(json, TransactionModel.fromApiJson),
    );
  }

  // Delete a transaction record
  Future<void> deleteTransaction(String transactionId) async {
    await _networkClient.request<void>(
      '/transactions/$transactionId',
      method: HttpMethod.delete,
      fromJsonT: (_) {},
    );
  }

  /// Update the linked account of a transaction
  Future<void> updateTransactionAccount(
    String transactionId,
    String accountId,
  ) async {
    await _networkClient.request<void>(
      '/transactions/$transactionId/account',
      method: HttpMethod.patch,
      data: {'account_id': accountId},
      fromJsonT: (_) {},
    );
  }

  /// List shared spaces a transaction can be linked to
  Future<List<Map<String, dynamic>>> listSharedSpaces({
    CancelToken? cancelToken,
  }) async {
    return _networkClient.request<List<Map<String, dynamic>>>(
      '/shared-spaces',
      method: HttpMethod.get,
      cancelToken: cancelToken,
      fromJsonT: (json) => _networkClient.unwrapData(json, (data) {
        final spaces = data['spaces'];
        if (spaces is List) {
          return spaces.whereType<Map<String, dynamic>>().toList();
        }
        return const <Map<String, dynamic>>[];
      }, endpoint: '/shared-spaces'),
    );
  }

  /// Link a transaction to a shared space
  Future<void> linkTransactionToSpace(
    String transactionId,
    String spaceId,
  ) async {
    await _networkClient.request<void>(
      '/shared-spaces/$spaceId/transactions',
      method: HttpMethod.post,
      data: {'transaction_id': transactionId},
      fromJsonT: (_) {},
    );
  }

  // Search transactions - for infinite scroll pagination
  Future<Map<String, dynamic>> searchTransactions({
    int page = 1,
    int size = 20,
    String? keyword,
    String? startDate,
    String? endDate,
    String? type,
    String? categoryKeys,
    String? tags,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'size': size};
    if (keyword != null) queryParameters['keyword'] = keyword;
    if (startDate != null) queryParameters['start_date'] = startDate;
    if (endDate != null) queryParameters['end_date'] = endDate;
    if (type != null) queryParameters['transaction_type'] = type.toUpperCase();
    if (categoryKeys != null) queryParameters['category_keys'] = categoryKeys;
    if (tags != null) queryParameters['tags'] = tags;

    return await _networkClient.request<Map<String, dynamic>>(
      '/transactions/search',
      method: HttpMethod.get,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        (data) => data,
        endpoint: '/transactions/search',
      ),
    );
  }

  // --- Parsing helpers centralized in ResponseParser ---

  /// Helper to parse a single item response { code: 0, data: { ... } } or direct { ... }
  T _parseItemResponse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) => ResponseParser.parseItem(json, fromJson);

  /// Helper to parse a list response { code: 0, data: { items: [...] } }
  List<T> _parseListResponse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) => ResponseParser.parseList(json, fromJson);
}

// Provider for HomeService
final homeServiceProvider = Provider<HomeService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return HomeService(networkClient);
});
