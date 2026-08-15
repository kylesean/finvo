// IO implementation: sends the auth token via an `Authorization` header so it
// does not appear in the URL (avoids leaking into server/proxy logs).
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connect to [wsUrl] using [token] in the `Authorization` header.
WebSocketChannel connectWs(String wsUrl, {required String token}) {
  return IOWebSocketChannel.connect(
    Uri.parse(wsUrl),
    headers: {'Authorization': 'Bearer $token'},
  );
}
