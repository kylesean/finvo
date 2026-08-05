import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import '../../../core/network/network_client.dart';
import 'package:finvo/features/auth/models/user.dart';
import 'package:finvo/core/utils/map_require.dart';
import 'package:finvo/core/services/server_config_service.dart';
import '../../../shared/services/timezone_service.dart';

class AuthService {
  final NetworkClient _networkClient;
  final TimezoneService _timezoneService;
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  final _logger = Logger('AuthService');

  // Keys for secure storage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userIdKey = 'user_id'; // Store user ID securely

  // Keys for shared preferences
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';

  AuthService(this._networkClient, this._timezoneService, this._prefs)
    : _storage = const FlutterSecureStorage();

  // Helper to save authentication data
  Future<void> _saveAuthData(
    String token,
    String refreshToken,
    UserModel user,
  ) async {
    // Save sensitive data to secure storage. Deliberately fail closed: if
    // Keychain/Keystore is unavailable, throw instead of falling back to
    // plaintext SharedPreferences (product decision for P1-1).
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userIdKey, value: user.id);
    } catch (e) {
      _logger.severe(
        'SecureStorage write failed, refusing plaintext fallback: $e',
      );
      throw SecureStorageUnavailableException(
        'Failed to store credentials securely on this device.',
      );
    }

    // Save non-sensitive data to shared preferences
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
    // Clear sensitive data from secure storage
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      _logger.warning('SecureStorage delete failed: $e');
    }

    // Clear non-sensitive data from shared preferences
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userPhoneKey);
    _logger.info(
      'Auth data deleted from secure storage and shared preferences.',
    );
  }

  // Method to retrieve stored authentication data
  Future<Map<String, dynamic>?> getStoredAuthData() async {
    String? token;
    String? userId;
    try {
      token = await _storage.read(key: _tokenKey);
      userId = await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.severe(
        'SecureStorage read failed, refusing plaintext fallback: $e',
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

  Future<({UserModel user, String token})> login(
    String account,
    String password,
  ) async {
    // Get user timezone
    final timezone = await _timezoneService.getCurrentTimezone();

    final response = await _networkClient.request<Map<String, dynamic>>(
      '/auth/login',
      method: HttpMethod.post,
      data: {
        'account': account,
        'password': password,
        'type': 'email',
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
      '/auth/send-code',
      method: HttpMethod.post,
      data: {'account': account, 'type': 'email'},
    );
    _logger.info('Verification code sent to $account (API call successful)');
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
      '/auth/register',
      method: HttpMethod.post,
      data: {
        'type': 'email',
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
    } catch (e) {
      _logger.warning('Failed to get device locale: $e');
      return 'zh_CN'; // Fallback to Chinese
    }
  }

  // Removed unnecessary validateToken and getCurrentUser methods
  // Because login already retrieves complete user information and Token, no additional API calls needed

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
  return AuthService(networkClient, timezoneService, prefs);
});
