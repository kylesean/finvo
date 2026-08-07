import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/profile/models/financial_account.dart';
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
          _unwrapData(json, UserInfo.fromJson, endpoint: '/user'),
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
          _unwrapData(json, UserInfo.fromJson, endpoint: '/user'),
    );
  }

  Future<FinancialAccountResponse> getFinancialAccounts() async {
    return await _networkClient.request<FinancialAccountResponse>(
      '/user/financial-accounts',
      method: HttpMethod.get,
      fromJsonT: (json) => _unwrapData(
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
      fromJsonT: (json) => _unwrapData(
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
      fromJsonT: (json) => _unwrapData(
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
      fromJsonT: (json) => _unwrapData(
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
      fromJsonT: (json) => _unwrapData(
        json,
        FinancialAccount.fromJson,
        endpoint: '/user/financial-accounts/$accountId',
      ),
    );
  }

  /// Delete a single account
  Future<void> deleteFinancialAccount(String accountId) async {
    await _networkClient.request<void>(
      '/user/financial-accounts/$accountId',
      method: HttpMethod.delete,
      fromJsonT: (_) {},
    );
  }

  /// Unwrap the standard `{code, message, data}` response envelope and decode
  /// the payload under `data` with [fromJson]. Consolidates the near-identical
  /// parsing blocks that otherwise repeat across every service method.
  ///
  /// - Non-object envelopes and non-object/`null` payloads raise
  ///   [DataParsingException] with a consistent message (unless [onNull]
  ///   supplies a fallback for a null payload).
  /// - Decode failures are re-wrapped so the raw parser error never leaks.
  T _unwrapData<T>(
    dynamic json,
    T Function(Map<String, dynamic> data) fromJson, {
    required String endpoint,
    T Function()? onNull,
  }) {
    if (json is! Map<String, dynamic>) {
      throw DataParsingException(
        'API $endpoint expects an object, but received ${json.runtimeType}',
      );
    }
    final data = json['data'];
    if (data == null) {
      if (onNull != null) return onNull();
      throw DataParsingException('data field is null');
    }
    if (data is! Map<String, dynamic>) {
      throw DataParsingException(
        'data field is not an object, but ${data.runtimeType}',
      );
    }
    try {
      return fromJson(data);
    } catch (e) {
      throw DataParsingException(
        'Failed to parse $endpoint response: ${e.toString()}',
      );
    }
  }
}

// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ProfileService(networkClient);
});
