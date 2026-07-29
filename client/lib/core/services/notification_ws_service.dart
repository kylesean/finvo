// core/services/notification_ws_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';

final _logger = Logger('NotificationWsService');

/// Callback when a real-time notification is received.
typedef NotificationCallback = void Function(Map<String, dynamic> payload);

/// WebSocket service for real-time notification push.
///
/// Connects to: ws(s)://host/api/ws/notifications?token=jwt
/// Implements automatic reconnection with exponential backoff.
class NotificationWsService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;

  static const _heartbeatInterval = Duration(seconds: 30);
  static const _maxReconnectDelay = Duration(seconds: 30);

  NotificationCallback? onNotification;

  /// Connect to the notification WebSocket.
  Future<void> connect({
    required String baseUrl,
    required SecureStorageService storageService,
  }) async {
    if (_isDisposed) return;

    final token = await storageService.getToken();
    if (token == null || token.isEmpty) {
      _logger.warning('No auth token available, skipping WS connection');
      return;
    }

    // Convert http(s) to ws(s)
    final wsUrl = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final uri = Uri.parse('$wsUrl/ws/notifications?token=$token');

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _reconnectAttempts = 0;
      _logger.info('WebSocket connected');

      _startHeartbeat();
      _listen();
    } catch (e) {
      _logger.warning('WebSocket connection failed: $e');
      _scheduleReconnect(baseUrl: baseUrl, storageService: storageService);
    }
  }

  void _listen() {
    _channel?.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'] as String?;

          if (type == 'notification') {
            final payload = data['payload'] as Map<String, dynamic>?;
            if (payload != null) {
              onNotification?.call(payload);
            }
          } else if (type == 'comment_updated') {
            onNotification?.call(data);
          }
          // Ignore 'pong' responses
        } catch (e) {
          _logger.warning('Failed to parse WS message: $e');
        }
      },
      onError: (Object error) {
        _logger.warning('WebSocket error: $error');
        _cleanup();
      },
      onDone: () {
        _logger.info('WebSocket closed');
        _cleanup();
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        _logger.fine('Heartbeat send failed: $e');
      }
    });
  }

  void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _channel = null;
  }

  void _scheduleReconnect({
    required String baseUrl,
    required SecureStorageService storageService,
  }) {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();

    // Exponential backoff: 1s, 2s, 4s, 8s, ... max 30s
    final delay = Duration(
      seconds: min(
        pow(2, _reconnectAttempts).toInt(),
        _maxReconnectDelay.inSeconds,
      ),
    );
    _reconnectAttempts++;

    _logger.info(
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, () {
      unawaited(connect(baseUrl: baseUrl, storageService: storageService));
    });
  }

  /// Disconnect and dispose resources.
  void dispose() {
    _isDisposed = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    unawaited(_channel?.sink.close());
    _channel = null;
  }
}
