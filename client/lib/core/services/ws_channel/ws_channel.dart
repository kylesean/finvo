// core/services/ws_channel/ws_channel.dart
//
// Cross-platform WebSocket connector. On IO platforms (iOS/Android/desktop)
// the auth token is sent via an `Authorization` header instead of the URL to
// avoid leaking it into server/proxy logs. On web (where custom headers are
// unavailable) the token falls back to a query parameter.
export 'ws_channel_stub.dart'
    if (dart.library.io) 'ws_channel_io.dart'
    if (dart.library.js_interop) 'ws_channel_web.dart';
