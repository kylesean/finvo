// The web WS fallback attaches the auth token as a query parameter
// (browsers cannot send custom headers). These tests pin the exact URL shape
// so the token never leaks into path/fragment and existing query params are
// preserved. The helper lives in a platform-neutral file (not the conditional
// export, and free of web_socket_channel/html.dart) so it runs on the VM.
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/services/ws_channel/web_socket_uri.dart';

void main() {
  group('webSocketUriWithToken', () {
    test('attaches the token as a single query parameter', () {
      final uri = webSocketUriWithToken(
        'wss://example.com/api/ws/notifications',
        token: 'jwt-abc',
      );
      expect(uri.queryParameters['token'], 'jwt-abc');
      expect(uri.scheme, 'wss');
      expect(uri.path, '/api/ws/notifications');
    });

    test('preserves pre-existing query parameters', () {
      final uri = webSocketUriWithToken(
        'ws://192.168.1.5:8080/ws?trace=1&room=42',
        token: 'secret',
      );
      expect(uri.queryParameters['trace'], '1');
      expect(uri.queryParameters['room'], '42');
      expect(uri.queryParameters['token'], 'secret');
    });

    test('token never lands in the path or fragment', () {
      final uri = webSocketUriWithToken(
        'wss://example.com/ws#stats',
        token: 'secret-token',
      );
      expect(uri.path, '/ws');
      expect(uri.path, isNot(contains('secret-token')));
      expect(uri.queryParameters['token'], 'secret-token');
    });
  });
}
