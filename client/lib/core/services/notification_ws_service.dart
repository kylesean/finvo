// core/services/notification_ws_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/core/services/ws_channel/ws_channel.dart';

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
  StreamSubscription<dynamic>? _subscription;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;

  /// Last time a pong (or any server message) was received, used to detect
  /// half-open connections where the TCP socket is alive but the peer is not
  /// responding.
  DateTime _lastServerMessage = DateTime.now();

  // Retained so a dropped connection can be re-established.
  String? _baseUrl;
  SecureStorageService? _storageService;

  static const _heartbeatInterval = Duration(seconds: 30);
  static const _maxReconnectDelay = Duration(seconds: 30);

  NotificationCallback? onNotification;

  /// Connect to the notification WebSocket.
  Future<void> connect({
    required String baseUrl,
    required SecureStorageService storageService,
  }) async {
    if (_isDisposed) return;

    // Reconnect path (or server switch) may arrive while a previous channel
    // is still alive; tear it down first to avoid leaking the old socket.
    _cleanup();

    _baseUrl = baseUrl;
    _storageService = storageService;

    final token = await storageService.getToken();
    if (token == null || token.isEmpty) {
      _logger.warning('No auth token available, skipping WS connection');
      return;
    }

    // Convert http(s) to ws(s)
    final wsUrl = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://')
        .replaceFirst(RegExp(r'/+$'), '');
    final wsBase = '$wsUrl/ws/notifications';

    try {
      // Token is sent via Authorization header (IO) or query param (web).
      _channel = connectWs(wsBase, token: token);
      // Guard against a half-open TCP connection where the server accepts
      // the socket but never completes the WebSocket upgrade. Without a
      // timeout, `ready` would hang forever, blocking connect() and
      // preventing _scheduleReconnect from ever firing.
      await _channel!.ready.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out after 15s');
        },
      );
      _reconnectAttempts = 0;
      _lastServerMessage = DateTime.now();
      _logger.info('WebSocket connected');

      _startHeartbeat();
      _listen();
    } catch (e, stackTrace) {
      _logger.warning('WebSocket connection failed', e, stackTrace);
      // Clean up the failed channel (closes its sink to release underlying
      // resources) before scheduling a reconnect.
      _cleanup();
      _scheduleReconnect();
    }
  }

  void _listen() {
    _subscription = _channel?.stream.listen(
      (message) {
        try {
          _lastServerMessage = DateTime.now();
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
        _scheduleReconnect();
      },
      onDone: () {
        _logger.info('WebSocket closed');
        _cleanup();
        // A dropped connection after initial connect must also be reconnected.
        _scheduleReconnect();
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      // Detect half-open connections: if the server has not responded within
      // several heartbeat intervals, drop the socket and reconnect instead of
      // silently keeping an unresponsive connection alive.
      if (DateTime.now().difference(_lastServerMessage) >
          _heartbeatInterval * 3) {
        _logger.warning('Heartbeat pong timeout, reconnecting');
        _cleanup();
        _scheduleReconnect();
        return;
      }
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
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    final baseUrl = _baseUrl;
    final storageService = _storageService;
    if (baseUrl == null || storageService == null) {
      _logger.warning(
        'NotificationWsService: No connect config available, skipping reconnect',
      );
      return;
    }
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
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
    _baseUrl = null;
    _storageService = null;
  }
}
