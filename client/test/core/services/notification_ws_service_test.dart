import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:fake_async/fake_async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:finvo/core/services/notification_ws_service.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  String? token;

  /// When non-null, `read` blocks until it completes (holds a connect()
  /// in flight mid-token-read for the generation test).
  Completer<void>? readGate;

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
    if (readGate != null) await readGate!.future;
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

class _FakeWebSocketSink extends DelegatingStreamSink<dynamic>
    implements WebSocketSink {
  final List<String> sent = [];
  bool closeCalled = false;

  _FakeWebSocketSink(super.inner);

  @override
  void add(dynamic data) {
    sent.add(data as String);
  }

  @override
  Future<dynamic> close([int? closeCode, String? closeReason]) {
    closeCalled = true;
    return Future<void>.value();
  }
}

/// In-memory [WebSocketChannel]: `ready` resolves (or fails, with
/// [failReady]); `stream` is fed by [emitServer]/[emitError]/[emitDone];
/// `sink` records outgoing frames without any socket.
class _FakeWebSocketChannel implements WebSocketChannel {
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final _FakeWebSocketSink _sink = _FakeWebSocketSink(
    StreamController<dynamic>().sink,
  );
  // The StreamChannelMixin helpers (cast/pipe/transform/...) are delegated
  // to this backing channel built from our stream + sink.
  late final StreamChannel<dynamic> _delegate = StreamChannel(
    _incoming.stream,
    _sink,
  );
  bool failReady = false;

  void emitServer(String data) => _incoming.add(data);
  void emitError(Object error) => _incoming.addError(error);
  Future<void> serverDisconnect() => _incoming.close();

  @override
  Future<void> get ready => failReady
      ? Future<void>.error(Exception('handshake failed'))
      : Future<void>.value();

  @override
  Stream<dynamic> get stream => _incoming.stream;
  @override
  WebSocketSink get sink => _sink;

  /// Typed access to the fake sink's test observations.
  _FakeWebSocketSink get fakeSink => _sink;

  @override
  String? get protocol => null;
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;

  @override
  StreamChannel<S> cast<S>() => _delegate.cast<S>();
  @override
  StreamChannel<dynamic> changeSink(
    StreamSink<dynamic> Function(StreamSink<dynamic>) change,
  ) => _delegate.changeSink(change);
  @override
  StreamChannel<dynamic> changeStream(
    Stream<dynamic> Function(Stream<dynamic>) change,
  ) => _delegate.changeStream(change);
  @override
  void pipe(StreamChannel<dynamic> other) => _delegate.pipe(other);
  @override
  StreamChannel<S> transform<S>(
    StreamChannelTransformer<S, dynamic> transformer,
  ) => _delegate.transform(transformer);
  @override
  StreamChannel<dynamic> transformSink(
    StreamSinkTransformer<dynamic, dynamic> transformer,
  ) => _delegate.transformSink(transformer);
  @override
  StreamChannel<dynamic> transformStream(
    StreamTransformer<dynamic, dynamic> transformer,
  ) => _delegate.transformStream(transformer);
}

void main() {
  group('NotificationWsService', () {
    SecureStorageService storageWithToken(String token) {
      return SecureStorageService(_FakeSecureStorage()..token = token);
    }

    test('connect skips connecting when no auth token is present', () async {
      final service = NotificationWsService();
      final storage = SecureStorageService(_FakeSecureStorage());

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storage,
      );

      expect(service.status, NotificationWsConnectionStatus.connecting);
      service.dispose();
    });

    test('dispose is safe and idempotent', () {
      final service = NotificationWsService();
      service.dispose();
      service.dispose();
    });

    test('connects, listens and dispatches notifications', () async {
      final created = <_FakeWebSocketChannel>[];
      final seenUrls = <String>{};
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) {
          seenUrls.add(url);
          final channel = _FakeWebSocketChannel();
          created.add(channel);
          return channel;
        };
      final received = <Map<String, dynamic>>[];
      service.onNotification = received.add;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );
      expect(service.status, NotificationWsConnectionStatus.connected);
      expect(created, hasLength(1));

      // H12: the token must never travel in the URL — it is handed to the
      // platform factory separately (Authorization header on IO, query
      // parameter only in the browser fallback), so the ws URL stays clean.
      expect(seenUrls.single, isNot(contains('jwt-token')));
      expect(seenUrls.single, contains('/ws/notifications'));

      created.single.emitServer(
        '{"type":"notification","payload":{"message":"hi"}}',
      );
      await Future<void>.delayed(Duration.zero);
      expect(received, [
        {'message': 'hi'},
      ]);
      service.dispose();
    });

    test('comment_updated payload is dispatched as-is', () async {
      final channel = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) => channel;
      final received = <Map<String, dynamic>>[];
      service.onNotification = received.add;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );
      channel.emitServer('{"type":"comment_updated","title":"Edited"}');
      await Future<void>.delayed(Duration.zero);
      expect(received, [
        {'type': 'comment_updated', 'title': 'Edited'},
      ]);
      service.dispose();
    });

    test('malformed and unknown messages are ignored gracefully', () async {
      final channel = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) => channel;
      final received = <Map<String, dynamic>>[];
      service.onNotification = received.add;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );

      channel.emitServer('not json at all');
      await Future<void>.delayed(Duration.zero);
      channel.emitServer('{"type":"pong"}');
      await Future<void>.delayed(Duration.zero);
      expect(received, isEmpty);
      service.dispose();
    });

    test('silent server is detected as half-open and reconnected', () async {
      // Shrink the heartbeat so the 3x-interval detection happens in test time.
      final channel = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..heartbeatInterval = const Duration(milliseconds: 100)
        ..connectChannelFactory = (url, {required token}) => channel;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );

      // Nothing answers yet; the check for pong is expected to kick in only
      // after 3+ intervals have passed untouched. Assert while the 3rd tick
      // (300ms) is still in the future so the window check cannot have fired.
      await Future<void>.delayed(const Duration(milliseconds: 230));
      expect(channel.fakeSink.sent, isNotEmpty);
      expect(jsonDecode(channel.fakeSink.sent.first)['type'], 'ping');
      expect(channel.fakeSink.closeCalled, isFalse);

      // Still silent: after the 3x window the socket is dropped and a
      // reconnect scheduled. The sink close is the observable signal.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(channel.fakeSink.closeCalled, isTrue);
      service.dispose();
    });

    test('answering server messages keeps the connection alive', () async {
      final channel = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..heartbeatInterval = const Duration(milliseconds: 100)
        ..connectChannelFactory = (url, {required token}) => channel;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );

      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        channel.emitServer('{"type":"pong"}');
        expect(channel.fakeSink.closeCalled, isFalse);
      }
      service.dispose();
    });

    test('socket error tears down and schedules a reconnect', () async {
      final channel = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) => channel;

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );
      channel.emitError(Exception('kaboom'));
      await Future<void>.delayed(Duration.zero);

      expect(service.status, NotificationWsConnectionStatus.reconnecting);
      expect(channel.fakeSink.closeCalled, isTrue);
      service.dispose();
    });

    test('server closing the socket schedules a reconnect', () async {
      var factoryCalls = 0;
      final first = _FakeWebSocketChannel();
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) {
          factoryCalls++;
          return first;
        };

      await service.connect(
        baseUrl: 'https://example.com',
        storageService: storageWithToken('jwt-token'),
      );
      await first.serverDisconnect();
      await Future<void>.delayed(Duration.zero);

      expect(service.status, NotificationWsConnectionStatus.reconnecting);
      // First reconnect is backoff-scheduled (1s), not immediate.
      expect(factoryCalls, 1);
      service.dispose();
    });

    test('reconnect budget follows exponential backoff and then gives up', () {
      final attempts = <String>[];
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) {
          attempts.add(url);
          return _FakeWebSocketChannel()..failReady = true;
        };

      fakeAsync((async) {
        unawaited(
          service.connect(
            baseUrl: 'https://example.com',
            storageService: storageWithToken('jwt-token'),
          ),
        );
        async.flushMicrotasks();
        expect(attempts, hasLength(1));

        // Exponential backoff: 1s, 2s, 4s, 8s — four automatic retries bring
        // the fifth attempt to fail; the budget check then flags `failed`
        // only once that fifth attempt itself fails again (16s elapse).
        for (final seconds in [1, 2, 4, 8, 16]) {
          async.elapse(Duration(seconds: seconds));
          async.flushMicrotasks();
        }
        expect(attempts, hasLength(6));
        expect(service.status, NotificationWsConnectionStatus.failed);
      });
      service.dispose();
    });

    test(
      'stale connect generation cannot tear down the newer socket',
      () async {
        final created = <_FakeWebSocketChannel>[];
        final service = NotificationWsService()
          ..connectChannelFactory = (url, {required token}) {
            final channel = _FakeWebSocketChannel();
            created.add(channel);
            return channel;
          };

        // First connect: token read is gated, so the channel is NOT yet made.
        final gatedStorage = _FakeSecureStorage()..token = 'token-a';
        gatedStorage.readGate = Completer<void>();
        unawaited(
          service.connect(
            baseUrl: 'https://example.com',
            storageService: SecureStorageService(gatedStorage),
          ),
        );
        await Future<void>.delayed(Duration.zero); // start the read

        // Second connect (fresh user action / re-login) completes normally.
        await service.connect(
          baseUrl: 'https://example.com',
          storageService: storageWithToken('token-b'),
        );
        expect(service.status, NotificationWsConnectionStatus.connected);
        expect(created, hasLength(1));

        // Release the gate: the stale connect must abort without touching the
        // live channel.
        gatedStorage.readGate!.complete();
        await Future<void>.delayed(Duration.zero);
        expect(created, hasLength(1));
        expect(created.single.fakeSink.closeCalled, isFalse);
        expect(service.status, NotificationWsConnectionStatus.connected);
        service.dispose();
      },
    );

    test('dispose prevents reconnect timers from firing', () async {
      var factoryCalls = 0;
      final service = NotificationWsService()
        ..connectChannelFactory = (url, {required token}) {
          factoryCalls++;
          return _FakeWebSocketChannel()..failReady = true;
        };

      fakeAsync((async) {
        unawaited(
          service.connect(
            baseUrl: 'https://example.com',
            storageService: storageWithToken('jwt-token'),
          ),
        );
        async.flushMicrotasks();
        expect(factoryCalls, 1);

        service.dispose();
        // Plenty of backoff time passes; nothing may reconnect a disposed
        // service.
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();
        expect(factoryCalls, 1);
      });
    });
  });
}
