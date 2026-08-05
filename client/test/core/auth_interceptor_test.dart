import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/interceptors/auth_interceptor.dart';
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

class _ThrowingSecureStorage extends FlutterSecureStorage {
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
    throw Exception('Keychain unavailable');
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
    throw Exception('Keychain unavailable');
  }
}

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late SecureStorageService storageService;
    late _FakeSecureStorage fakeStorage;
    final unauthorizedCalls = <String>[];

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      storageService = SecureStorageService(fakeStorage);
      unauthorizedCalls.clear();
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => unauthorizedCalls.add('triggered'),
        ),
      );
    });

    test('adds Bearer token from secure storage on request', () async {
      await fakeStorage.write(key: 'auth_token', value: 'tok123');
      RequestOptions? capturedOptions;
      dio.httpClientAdapter = _CaptureAdapter((options) {
        capturedOptions = options;
      });

      await dio.get<dynamic>('https://example.com/api');
      expect(capturedOptions?.headers['Authorization'], 'Bearer tok123');
    });

    test('401 triggers onUnauthorized callback', () async {
      var called = false;
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => called = true,
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onError: (e, handler) async {
            handler.next(e);
          },
        ),
      );
      dio.httpClientAdapter = _MockAdapter(401);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
      expect(called, isTrue);
    });

    test('non-401 does not trigger onUnauthorized', () async {
      var called = false;
      dio = Dio();
      dio.interceptors.add(
        AuthInterceptor(
          storageService,
          onUnauthorized: () async => called = true,
        ),
      );
      dio.httpClientAdapter = _MockAdapter(500);

      await expectLater(
        dio.get<dynamic>('https://example.com/api'),
        throwsA(isA<DioException>()),
      );
      expect(called, isFalse);
    });

    test('missing token attaches no Authorization header', () async {
      RequestOptions? seenOptions;
      dio.httpClientAdapter = _CaptureAdapter((options) {
        seenOptions = options;
      });

      await dio.get<dynamic>('https://example.com/api');
      expect(seenOptions?.headers['Authorization'], isNull);
    });
  });

  group('SecureStorageService fail-closed', () {
    test(
      'saveToken throws when Keychain fails (no plaintext fallback)',
      () async {
        final service = SecureStorageService(_ThrowingSecureStorage());
        await expectLater(
          service.saveToken('secret'),
          throwsA(isA<SecureStorageUnavailableException>()),
        );
      },
    );

    test('getToken throws when Keychain read fails', () async {
      final service = SecureStorageService(_ThrowingSecureStorage());
      await expectLater(
        service.getToken(),
        throwsA(isA<SecureStorageUnavailableException>()),
      );
    });

    test('save/get roundtrip works when Keychain is healthy', () async {
      final service = SecureStorageService(_FakeSecureStorage());
      await service.saveToken('secret');
      expect(await service.getToken(), 'secret');
      await service.deleteToken();
      expect(await service.getToken(), isNull);
    });

    test('deleteToken failure does not block logout', () async {
      final service = SecureStorageService(_ThrowingSecureStorage());
      // Should not throw: deletion is best-effort during logout
      await service.deleteToken();
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  final int statusCode;
  _MockAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (statusCode == 200) {
      return ResponseBody.fromString(
        '{"code":0,"data":{}}',
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: statusCode,
        statusMessage: 'error',
        data: '{"code":1}',
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CaptureAdapter implements HttpClientAdapter {
  final void Function(RequestOptions options) onRequest;
  _CaptureAdapter(this.onRequest);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options);
    return ResponseBody.fromString(
      '{"code":0,"data":{}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
