// core/services/ws_channel/ws_channel_web.dart
//
// Web implementation: the browser WebSocket API does not allow custom headers,
// so the auth token is sent as a query parameter instead.
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connect to [wsUrl] including [token] as a query parameter (web fallback).
WebSocketChannel connectWs(String wsUrl, {required String token}) {
  final uri = Uri.parse(wsUrl).replace(queryParameters: {'token': token});
  return HtmlWebSocketChannel.connect(uri);
}
