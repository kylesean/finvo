import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/services/notification_ws_service.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  String? token;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') token = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') return token;
    return null;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (key == 'auth_token') token = null;
  }
}

void main() {
  group('NotificationWsService', () {
    test('connect skips connecting when no auth token is present', () async {
      final service = NotificationWsService();
      final storage = SecureStorageService(_FakeSecureStorage());

      // Should complete without throwing or attempting a real connection.
      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storage,
      );

      service.dispose();
    });

    test('dispose is safe and idempotent', () {
      final service = NotificationWsService();
      service.dispose();
      service.dispose();
    });
  });
}
