import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/shared/models/financial_account.dart';
import 'package:finvo/features/profile/models/financial_settings.dart';
import 'package:finvo/features/profile/models/user_info.dart';

class ProfileService {
  final NetworkClient _networkClient;

  ProfileService(this._networkClient);

  /// Get current user information
  Future<UserInfo> getCurrentUser() async {
    return await _networkClient.request<UserInfo>(
      '/user',
      method: HttpMethod.get,
      fromJsonT: (json) =>
          _networkClient.unwrapData(json, UserInfo.fromJson, endpoint: '/user'),
    );
  }

  /// Update user profile (username, avatar)
  Future<UserInfo> updateProfile({String? username, String? avatarUrl}) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    return await _networkClient.request<UserInfo>(
      '/user',
      method: HttpMethod.patch,
      data: data,
      fromJsonT: (json) =>
          _networkClient.unwrapData(json, UserInfo.fromJson, endpoint: '/user'),
    );
  }

  Future<FinancialAccountResponse> getFinancialAccounts() async {
    return await _networkClient.request<FinancialAccountResponse>(
      '/user/financial-accounts',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialAccountResponse.fromJson,
        endpoint: '/user/financial-accounts',
        // A missing envelope is treated as an empty account set so the net
        // worth view degrades gracefully instead of erroring on first run.
        onNull: () => FinancialAccountResponse(totalBalance: Decimal.zero),
      ),
    );
  }

  /// Save user financial accounts information
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

  /// Get user financial settings
  Future<FinancialSettingsResponse> getFinancialSettings() async {
    return await _networkClient.request<FinancialSettingsResponse>(
      '/financial-settings',
      method: HttpMethod.get,
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialSettingsResponse.fromJson,
        endpoint: '/financial-settings',
      ),
    );
  }

  /// Update user financial settings
  Future<FinancialSettingsResponse> updateFinancialSettings(
    FinancialSettingsRequest request,
  ) async {
    return await _networkClient.request<FinancialSettingsResponse>(
      '/financial-settings',
      method: HttpMethod.patch,
      data: request.toJson(),
      fromJsonT: (json) => _networkClient.unwrapData(
        json,
        FinancialSettingsResponse.fromJson,
        endpoint: '/financial-settings',
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

  /// Merge one account into another (correction for wrong/duplicate accounts).
  ///
  /// The source's transactions and recurring rules are re-pointed to the
  /// target, the target balance is recomputed from the ledger and the source
  /// is deleted. No new transaction record is created.
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

// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ProfileService(networkClient);
});
