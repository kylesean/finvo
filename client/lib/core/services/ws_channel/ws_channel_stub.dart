// Default/unsupported-platform implementation. The conditional exporter in
// `ws_channel.dart` selects the IO or web implementation at compile time.
import 'package:web_socket_channel/web_socket_channel.dart';

/// Not expected to be selected at runtime; exists as the import fallback.
WebSocketChannel connectWs(String wsUrl, {required String token}) {
  throw UnsupportedError('connectWs is not supported on this platform');
}
