import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/auth/models/user.dart';
import 'package:finvo/core/utils/map_require.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/shared/services/timezone_service.dart';

class AuthService {
  final NetworkClient _networkClient;
  final TimezoneService _timezoneService;
  final SecureStorageService _storageService;
  final SharedPreferences _prefs;
  final _logger = Logger('AuthService');

  // Keys for shared preferences (non-sensitive user data)
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';

  /// [storageService] is the single secure-storage entry point for
  /// credentials. Previously this class kept its own `FlutterSecureStorage`
  /// instance (default namespace) alongside `SecureStorageService` (Finvo_
  /// namespace) — a dual-write scheme whose cleanup paths could diverge,
  /// leaving tokens behind after logout/session expiry.
  AuthService(
    this._networkClient,
    this._timezoneService,
    this._prefs,
    this._storageService,
  );

  // Helper to save authentication data
  Future<void> _saveAuthData(
    String token,
    String refreshToken,
    UserModel user,
  ) async {
    // Save sensitive data through the single secure-storage entry point.
    // Deliberately fail closed: if Keychain/Keystore is unavailable, throw
    // instead of falling back to plaintext SharedPreferences.
    await _storageService.saveToken(token);
    await _storageService.saveRefreshToken(refreshToken);

    // Save non-sensitive data to shared preferences
    await _prefs.setString(_userIdKey, user.id);
    await _prefs.setString(_userNameKey, user.username?.toString() ?? '');
    if (user.email != null) {
      await _prefs.setString(_userEmailKey, user.email!);
    } else {
      await _prefs.remove(_userEmailKey);
    }
    if (user.phone != null) {
      await _prefs.setString(_userPhoneKey, user.phone!);
    } else {
      await _prefs.remove(_userPhoneKey);
    }
    _logger.info('Auth data saved to secure storage and shared preferences.');
  }

  // Helper to delete authentication data
  Future<void> _deleteAuthData() async {
    // Fail-closed credential deletion: if Keychain/Keystore refuses the
    // delete, propagate the failure instead of reporting a clean logout while
    // the credentials remain stored. SharedPreferences cleanup only runs once
    // the secure deletion succeeded.
    await _storageService.deleteToken();
    await _storageService.deleteRefreshToken();

    // Clear non-sensitive data from shared preferences
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userPhoneKey);
    _logger.info(
      'Auth data deleted from secure storage and shared preferences.',
    );
  }

  /// Update stored username in shared preferences
  Future<void> updateStoredUsername(String newUsername) async {
    await _prefs.setString(_userNameKey, newUsername);
    // AUTH-4: do not log the username — it is PII and the log may be
    // shipped to crash/error reporting pipelines.
    _logger.info('Updated stored username in shared preferences.');
  }

  // Method to retrieve stored authentication data
  Future<Map<String, dynamic>?> getStoredAuthData() async {
    String? token;
    String? userId;
    try {
      token = await _storageService.getToken();
      userId = _prefs.getString(_userIdKey);
    } catch (e, stackTrace) {
      _logger.severe(
        'SecureStorage read failed, refusing plaintext fallback',
        e,
        stackTrace,
      );
      throw SecureStorageUnavailableException(
        'Failed to read credentials from secure storage on this device.',
      );
    }

    if (token != null && userId != null) {
      // Retrieve non-sensitive data from shared preferences
      final username = _prefs.getString(_userNameKey);
      final email = _prefs.getString(_userEmailKey);
      final phone = _prefs.getString(_userPhoneKey);

      if (username != null) {
        // Ensure at least username is present for a valid user model
        final user = UserModel(
          id: userId,
          username: username,
          email: email,
          phone: phone,
        );
        _logger.info('Stored auth data retrieved.');
        return {'user': user, 'token': token};
      }
    }
    return null;
  }

  /// Detect account type from its format. Mirrors the registration UI which
  /// accepts either a phone number or an email address.
  ///
  /// The value MUST be `mobile` (not `phone`): the server's
  /// LoginRequest/RegisterRequest/SendCodeRequest schemas restrict `type` to
  /// `Literal["email", "mobile"]`, so any other string is rejected with 422.
  static String _accountType(String account) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(account.trim()) ? 'mobile' : 'email';
  }

  Future<({UserModel user, String token})> login(
    String account,
    String password,
  ) async {
    // Get user timezone
    final timezone = await _timezoneService.getCurrentTimezone();

    final response = await _networkClient.request<Map<String, dynamic>>(
      ApiConstants.authLoginPath,
      method: HttpMethod.post,
      data: {
        'account': account,
        'password': password,
        'type': _accountType(account),
        'timezone': timezone, // Add timezone information
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
    // Extract data from response['data']
    final data = response.require<Map<String, dynamic>>('data');
    final userJson = data.require<Map<String, dynamic>>('user');
    final token = data.require<String>('token');
    final refreshToken = data.require<String>('refresh_token');
    final UserModel user = UserModel.fromJson(userJson);
    await _saveAuthData(
      token,
      refreshToken,
      user,
    ); // Save data after successful login
    // Return a tuple with strongly typed objects (Record)
    return (user: user, token: token);
  }

  // --- Connect to send verification code API ---
  Future<void> sendVerificationCode(String account) async {
    await _networkClient.request<void>(
      ApiConstants.authSendCodePath,
      method: HttpMethod.post,
      data: {'account': account, 'type': _accountType(account)},
    );
    // AUTH-4: the account is a phone number or email — PII. Log only the
    // account type so logs remain useful without leaking identity.
    _logger.info(
      'Verification code sent (${_accountType(account)} API call successful)',
    );
  }

  // User registration
  Future<({UserModel user, String token})> register({
    required String account,
    required String password,
    required String verificationCode,
  }) async {
    // Get user timezone
    final timezone = await _timezoneService.getCurrentTimezone();

    // Get device locale for smart currency default (no permission required)
    final locale = _getDeviceLocale();

    final response = await _networkClient.request<Map<String, dynamic>>(
      ApiConstants.authRegisterPath,
      method: HttpMethod.post,
      data: {
        'type': _accountType(account),
        'account': account,
        'password': password,
        'code': verificationCode,
        'timezone': timezone, // Add timezone information
        'locale': locale, // Add locale for smart currency default
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
    // Extract data from response['data']
    final data = response.require<Map<String, dynamic>>('data');
    final userJson = data.require<Map<String, dynamic>>('user');
    final token = data.require<String>('token');
    final refreshToken = data.require<String>('refresh_token');
    final UserModel user = UserModel.fromJson(userJson);
    await _saveAuthData(
      token,
      refreshToken,
      user,
    ); // Save data after successful registration

    _logger.info('User registered with locale: $locale');

    // Return a tuple with strongly typed objects (Record)
    return (user: user, token: token);
  }

  /// Get device locale string (e.g., 'zh_CN', 'en_US')
  /// This does NOT require any permission.
  String _getDeviceLocale() {
    try {
      // On web, `Platform` is unavailable; fall back to the browser locale.
      if (kIsWeb) {
        final locale = WidgetsBinding.instance.platformDispatcher.locale;
        final code = locale.countryCode == null
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';
        _logger.fine('Device locale detected (web): $code');
        return code;
      }
      // Platform.localeName returns the device's locale (e.g., 'zh_CN', 'en_US')
      // This is a synchronous call and does not require any permission
      final locale = Platform.localeName;
      _logger.fine('Device locale detected: $locale');
      return locale;
    } catch (e, stackTrace) {
      _logger.warning('Failed to get device locale', e, stackTrace);
      return 'zh_CN'; // Fallback to Chinese
    }
  }

  // Removed unnecessary validateToken and getCurrentUser methods
  // Because login already retrieves complete user information and Token, no additional API calls needed

  /// Clear locally stored auth data (secure tokens + shared-preference user
  /// PII) without calling the server. Used on session expiry (401) so the
  /// local state matches a full logout; otherwise cold-start would still find
  /// leaked user PII in SharedPreferences after the session died.
  Future<void> clearLocalAuthData() async {
    await _deleteAuthData();
    _logger.info('Local auth data cleared (session expiry).');
  }

  Future<void> logout() async {
    await _deleteAuthData(); // Clear token and user data from secure storage and shared preferences
    _logger.info('User logged out and data cleared.');
  }
}

// Provider for AuthService (ensure NetworkClientProvider is defined)
final authServiceProvider = Provider<AuthService>((ref) {
  final networkClient = ref.watch(
    networkClientProvider,
  ); // Get from your network layer
  final timezoneService = ref.watch(
    timezoneServiceProvider,
  ); // Get timezone service
  final prefs = ref.watch(sharedPreferencesProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthService(networkClient, timezoneService, prefs, storageService);
});
