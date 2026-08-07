import 'dart:async';

import 'package:logging/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

const String _authTokenKey = 'auth_token';
const String _authRefreshTokenKey = 'auth_refresh_token';
// Note: _userIdKey and _userDataKey removed - add back when implementing user data storage

class SecureStorageService {
  final _logger = Logger('SecureStorageService');
  final FlutterSecureStorage _secureStorage;

  // Memory cache to avoid repeated reading causing performance overhead
  String? _cachedToken;
  bool _tokenCacheInitialized = false;
  String? _cachedRefreshToken;
  bool _refreshTokenCacheInitialized = false;

  // Serializes cache-mutating operations. Dart awaits can interleave, so a
  // slow read() resolving after a write() would otherwise overwrite the freshly
  // cached value with a stale one (e.g. getToken() racing saveToken()). Chaining
  // every operation on this future guarantees they run one at a time.
  Future<void> _operationQueue = Future<void>.value();

  SecureStorageService(this._secureStorage);

  /// Runs [action] after all previously queued operations have completed,
  /// serializing concurrent reads/writes of the memory cache. A failure in one
  /// operation does not wedge the queue for later ones.
  Future<T> _synchronized<T>(Future<T> Function() action) {
    final operation = _operationQueue.then((_) => action());
    _operationQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  /// Save token to secure storage.
  ///
  /// Deliberately does NOT fall back to plaintext SharedPreferences: if
  /// Keychain/Keystore is unavailable the write fails hard (product decision:
  /// "fail closed" rather than storing secrets insecurely).
  Future<void> saveToken(String token) {
    return _synchronized(() async {
      try {
        await _secureStorage.write(key: _authTokenKey, value: token);
        _cachedToken = token;
        _tokenCacheInitialized = true;
        _logger.fine(
          'SecureStorageService: Token saved (${token.length} chars)',
        );
      } catch (e) {
        _tokenCacheInitialized = false;
        _logger.severe(
          'SecureStorageService: Failed to save token to Keychain/Keystore, refusing plaintext fallback: $e',
        );
        throw SecureStorageUnavailableException(
          'Failed to store token securely on this device.',
        );
      }
    });
  }

  Future<String?> getToken() {
    return _synchronized(() async {
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
        _logger.severe(
          'SecureStorageService: Failed to read token from Keychain/Keystore: $e',
        );
        throw SecureStorageUnavailableException(
          'Failed to read token from secure storage on this device.',
        );
      }
    });
  }

  Future<void> deleteToken() {
    return _synchronized(() async {
      try {
        await _secureStorage.delete(key: _authTokenKey);
        // Clear cache
        _cachedToken = null;
        _tokenCacheInitialized = true;
        _logger.info('SecureStorageService: Token deleted');
      } catch (e) {
        // A failed delete can leave the token in Keychain/Keystore AND in the
        // memory cache, so `getToken()` would keep returning the stale cached
        // value — contradicting the fail-closed policy used on writes.
        // Invalidate the cache (next read re-reads the real value from storage)
        // and surface the failure as a warning instead of swallowing it.
        _cachedToken = null;
        _tokenCacheInitialized = false;
        _logger.warning('SecureStorageService: Failed to delete token: $e');
      }
    });
  }

  /// Save the refresh token to secure storage (fail-closed, like the access token).
  Future<void> saveRefreshToken(String token) {
    return _synchronized(() async {
      try {
        await _secureStorage.write(key: _authRefreshTokenKey, value: token);
        _cachedRefreshToken = token;
        _refreshTokenCacheInitialized = true;
        _logger.fine(
          'SecureStorageService: Refresh token saved (${token.length} chars)',
        );
      } catch (e) {
        _refreshTokenCacheInitialized = false;
        _logger.severe(
          'SecureStorageService: Failed to save refresh token: $e',
        );
        throw SecureStorageUnavailableException(
          'Failed to store refresh token securely on this device.',
        );
      }
    });
  }

  /// Read the refresh token from secure storage.
  Future<String?> getRefreshToken() {
    return _synchronized(() async {
      if (_refreshTokenCacheInitialized) {
        return _cachedRefreshToken;
      }
      try {
        final token = await _secureStorage.read(key: _authRefreshTokenKey);
        _cachedRefreshToken = token;
        _refreshTokenCacheInitialized = true;
        return token;
      } catch (e) {
        _logger.severe(
          'SecureStorageService: Failed to read refresh token: $e',
        );
        throw SecureStorageUnavailableException(
          'Failed to read refresh token from secure storage on this device.',
        );
      }
    });
  }

  /// Delete the refresh token (best-effort during logout).
  Future<void> deleteRefreshToken() {
    return _synchronized(() async {
      try {
        await _secureStorage.delete(key: _authRefreshTokenKey);
        _cachedRefreshToken = null;
        _refreshTokenCacheInitialized = true;
        _logger.info('SecureStorageService: Refresh token deleted');
      } catch (e) {
        // Mirror deleteToken: invalidate the cache so a later read does not
        // serve a stale value from memory, and log the failure visibly.
        _cachedRefreshToken = null;
        _refreshTokenCacheInitialized = false;
        _logger.warning(
          'SecureStorageService: Failed to delete refresh token: $e',
        );
      }
    });
  }

  /// Clear memory cache (for scenarios such as server switching).
  /// Runs inside the serialized [_synchronized] queue so it cannot interleave
  /// with an in-flight read/write that might re-populate the cache afterwards.
  Future<void> invalidateCache() {
    return _synchronized(() async {
      _cachedToken = null;
      _tokenCacheInitialized = false;
      _cachedRefreshToken = null;
      _refreshTokenCacheInitialized = false;
      _logger.info('SecureStorageService: Cache invalidated');
    });
  }

  Future<void> clearAllData() async {
    await deleteToken();
    await deleteRefreshToken();
    await invalidateCache();
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
