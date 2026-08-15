// Web implementation: the browser WebSocket API does not allow custom headers,
// so the auth token is sent as a query parameter instead.
import 'package:finvo/core/services/ws_channel/web_socket_uri.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'web_socket_uri.dart' show webSocketUriWithToken;

/// WebSocketChannel factory (web): [token] travels as a query parameter
/// because the browser cannot attach authorization headers to WebSockets.
WebSocketChannel connectWs(String wsUrl, {required String token}) {
  return HtmlWebSocketChannel.connect(
    webSocketUriWithToken(wsUrl, token: token),
  );
}
