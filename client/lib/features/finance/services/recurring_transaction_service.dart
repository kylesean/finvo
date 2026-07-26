import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/network_client.dart';
import '../models/recurring_transaction.dart';

part 'recurring_transaction_service.g.dart';

/// Recurring transaction service
class RecurringTransactionService {
  final NetworkClient _networkClient;

  RecurringTransactionService(this._networkClient);

  /// Get recurring transaction list
  Future<List<RecurringTransaction>> getList({
    RecurringTransactionType? type,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) {
      queryParams['type'] = type.value;
    }
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final response = await _networkClient.requestMap(
      '/transactions/recurring',
      method: HttpMethod.get,
      queryParameters: queryParams,
    );

    final data = response['data'] as List<dynamic>;
    return data
        .map(
          (json) => RecurringTransaction.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get recurring transaction details
  Future<RecurringTransaction> getById(String id) async {
    final response = await _networkClient.requestMap(
      '/transactions/recurring/$id',
      method: HttpMethod.get,
    );
    return RecurringTransaction.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Create recurring transaction
  Future<RecurringTransaction> create(
    RecurringTransactionCreateRequest request,
  ) async {
    final response = await _networkClient.requestMap(
      '/transactions/recurring',
      method: HttpMethod.post,
      data: request.toJson(),
    );
    return RecurringTransaction.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Update recurring transaction
  Future<RecurringTransaction> update(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _networkClient.requestMap(
      '/transactions/recurring/$id',
      method: HttpMethod.put,
      data: updates,
    );
    return RecurringTransaction.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Delete recurring transaction
  Future<void> delete(String id) async {
    await _networkClient.requestMap(
      '/transactions/recurring/$id',
      method: HttpMethod.delete,
    );
  }

  /// Get pending transactions awaiting confirmation
  Future<List<PendingTransaction>> getPending() async {
    final response = await _networkClient.requestMap(
      '/transactions/pending',
      method: HttpMethod.get,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map(
          (json) => PendingTransaction.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Confirm a pending transaction
  Future<void> confirmPending(String id) async {
    await _networkClient.requestMap(
      '/transactions/$id/confirm',
      method: HttpMethod.post,
    );
  }

  /// Skip (delete) a pending transaction
  Future<void> skipPending(String id) async {
    await _networkClient.requestMap(
      '/transactions/$id/skip',
      method: HttpMethod.post,
    );
  }
}

/// Recurring transaction service provider
@riverpod
RecurringTransactionService recurringTransactionService(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return RecurringTransactionService(networkClient);
}
