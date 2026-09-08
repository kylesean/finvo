import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/shared/models/financial_account.dart';

/// API client for the user's financial accounts.
///
/// Lives in the shared layer (not features/profile) because the financial
/// account notifier is application-wide state consumed by home, finance,
/// chat and server features alike; a feature-owned service would force
/// every consumer to depend on that feature.
class FinancialAccountService {
  final NetworkClient _networkClient;

  FinancialAccountService(this._networkClient);

  Future<FinancialAccountResponse> getFinancialAccounts() async {
    return await _networkClient.request<FinancialAccountResponse>(
      '/user/financial-accounts',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialAccountResponse.fromJson,
        endpoint: '/user/financial-accounts',
        onNull: () => FinancialAccountResponse(totalBalance: Decimal.zero),
      ),
    );
  }

  Future<FinancialAccountSummary> saveFinancialAccounts(
    List<FinancialAccount> accounts,
  ) async {
    final request = FinancialAccountRequest(accounts: accounts);

    return await _networkClient.request<FinancialAccountSummary>(
      '/user/financial-accounts',
      method: HttpMethod.post,
      data: request.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialAccountSummary.fromJson,
        endpoint: '/user/financial-accounts',
      ),
    );
  }

  /// Create a single account server-side.
  ///
  /// The bulk [saveFinancialAccounts] endpoint replaces the user's whole
  /// account list; creating through it from a stale client snapshot would
  /// clobber concurrent server-side changes. This dedicated endpoint touches
  /// exactly one row.
  Future<FinancialAccount> createFinancialAccount(
    FinancialAccount account,
  ) async {
    return await _networkClient.request<FinancialAccount>(
      '/user/financial-accounts/create',
      method: HttpMethod.post,
      data: account.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialAccount.fromJson,
        endpoint: '/user/financial-accounts/create',
      ),
    );
  }

  /// Update a single account
  Future<FinancialAccount> updateFinancialAccount(
    String accountId,
    FinancialAccount account,
  ) async {
    return await _networkClient.request<FinancialAccount>(
      '/user/financial-accounts/$accountId',
      method: HttpMethod.patch,
      data: account.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialAccount.fromJson,
        endpoint: '/user/financial-accounts/$accountId',
      ),
    );
  }

  /// Delete a single account (guarded server-side: only empty accounts).
  Future<void> deleteFinancialAccount(String accountId) async {
    await _networkClient.request<void>(
      '/user/financial-accounts/$accountId',
      method: HttpMethod.delete,
      fromJsonT: (_) {},
    );
  }

  Future<void> mergeFinancialAccounts(String sourceId, String targetId) async {
    await _networkClient.request<void>(
      '/user/financial-accounts/$sourceId/merge',
      method: HttpMethod.post,
      data: {'target_account_id': targetId},
      fromJsonT: (_) {},
    );
  }

  /// Close (archive) an account while keeping its full transaction history.
  ///
  /// [disposal] decides how a non-zero balance is handled: 'keep' (freeze the
  /// snapshot), 'transfer' (generate a TRANSFER to [targetAccountId]) or
  /// 'writeoff' (generate an EXPENSE/INCOME write-off entry).
  Future<void> closeFinancialAccount(
    String accountId, {
    required String disposal,
    String? targetAccountId,
  }) async {
    await _networkClient.request<void>(
      '/user/financial-accounts/$accountId/close',
      method: HttpMethod.post,
      data: {'disposal': disposal, 'target_account_id': ?targetAccountId},
      fromJsonT: (_) {},
    );
  }
}

final financialAccountServiceProvider = Provider<FinancialAccountService>((
  ref,
) {
  return FinancialAccountService(ref.watch(networkClientProvider));
});
