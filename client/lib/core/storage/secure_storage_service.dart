import 'package:logging/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _authTokenKey = 'auth_token';
// Note: _userIdKey and _userDataKey removed - add back when implementing user data storage

class SecureStorageService {
  final _logger = Logger('SecureStorageService');
  final FlutterSecureStorage _secureStorage;

  // Memory cache to avoid repeated reading causing performance overhead
  String? _cachedToken;
  bool _tokenCacheInitialized = false;

  SecureStorageService(this._secureStorage);

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      _cachedToken = token;
      _tokenCacheInitialized = true;
      _logger.fine('SecureStorageService: Token saved (${token.length} chars)');
    } catch (e) {
      _logger.warning(
        'SecureStorageService: Failed to save token to Keychain, falling back to SharedPreferences: $e',
      );
      _cachedToken = token;
      _tokenCacheInitialized = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_authTokenKey, token);
      } catch (err) {
        _logger.warning('SharedPreferences fallback failed: $err');
      }
    }
  }

  Future<String?> getToken() async {
    // If cache is initialized, return cache value directly
    if (_tokenCacheInitialized) {
      _logger.fine('SecureStorageService: Read token from cache');
      return _cachedToken;
    }

    try {
      final token = await _secureStorage.read(key: _authTokenKey);
      _cachedToken = token;
      _tokenCacheInitialized = true;
      _logger.fine(
        'SecureStorageService: Read token (${token != null ? 'present' : 'null'})',
      );
      return token;
    } catch (e) {
      _logger.warning(
        'SecureStorageService: Failed to read token from Keychain, trying SharedPreferences: $e',
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_authTokenKey);
        _cachedToken = token;
        _tokenCacheInitialized = true;
        return token;
      } catch (err) {
        _tokenCacheInitialized = true;
        _cachedToken = null;
        return null;
      }
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      // Clear cache
      _cachedToken = null;
      _tokenCacheInitialized = true;
      _logger.info('SecureStorageService: Token deleted');
    } catch (e) {
      _logger.info('SecureStorageService: Failed to delete token: $e');
    }
  }

  /// Clear memory cache (for scenarios such as server switching)
  void invalidateCache() {
    _cachedToken = null;
    _tokenCacheInitialized = false;
    _logger.info('SecureStorageService: Cache invalidated');
  }

  Future<void> clearAllData() async {
    await deleteToken();
    invalidateCache();
    // Clear other authentication-related data
  }
}

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    // Configure Android options
    // Note: encryptedSharedPreferences has been deprecated in v10+, the library will automatically use Tink encryption
    aOptions: AndroidOptions(
      // Set storage namespace (replaces deprecated sharedPreferencesName)
      storageNamespace: 'Finvo_secure_storage',
      // Set key prefix
      preferencesKeyPrefix: 'Finvo_',
    ),
    // Configure iOS options
    iOptions: IOSOptions(
      // first_unlock provides better performance while maintaining security
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final secureStorage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(secureStorage);
});
