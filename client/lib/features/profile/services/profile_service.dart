import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/shared/models/financial_settings.dart';
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
}

// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ProfileService(networkClient);
});
