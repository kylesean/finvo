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

/// Observable connection lifecycle of [NotificationWsService]. Exposed so UI
/// and diagnostics can react to connectivity (show a banner, log, etc.) instead
/// of treating the WS as an opaque background connection.
enum NotificationWsConnectionStatus {
  /// No connection attempt is in flight (initial or after explicit dispose).
  disconnected,

  /// A socket handshake is in progress.
  connecting,

  /// The socket is open and being listened on.
  connected,

  /// A retry is scheduled after a dropped/failed connection.
  reconnecting,

  /// The reconnect budget was exhausted; automatic retries have stopped.
  failed,
}

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

  /// Broadcast stream of connection state transitions, and the current value.
  final _statusController =
      StreamController<NotificationWsConnectionStatus>.broadcast();
  NotificationWsConnectionStatus _status =
      NotificationWsConnectionStatus.disconnected;
  Stream<NotificationWsConnectionStatus> get statusStream =>
      _statusController.stream;
  NotificationWsConnectionStatus get status => _status;

  void _setStatus(NotificationWsConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }

  /// Last time a pong (or any server message) was received, used to detect
  /// half-open connections where the TCP socket is alive but the peer is not
  /// responding.
  DateTime _lastServerMessage = DateTime.now();

  // Retained so a dropped connection can be re-established.
  String? _baseUrl;
  SecureStorageService? _storageService;

  static const _heartbeatInterval = Duration(seconds: 30);
  static const _maxReconnectDelay = Duration(seconds: 30);
  // Bounded reconnect attempts: once exceeded, automatic reconnection stops so
  // a permanently unreachable server doesn't keep waking the device every
  // backoff interval forever. connect() is still re-invoked externally when
  // the auth token changes (provider rebuild) or the server config is edited.
  static const _maxReconnectAttempts = 5;

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
    _setStatus(NotificationWsConnectionStatus.connecting);

    String? token;
    try {
      token = await storageService.getToken();
    } catch (e, stackTrace) {
      // A platform-channel failure is transient, not a signal that no token
      // exists. Schedule a reconnect so the connection is attempted again
      // instead of silently skipping forever (the caller fires this
      // unawaited, so an uncaught error would otherwise escape unnoticed).
      _logger.warning('Token read failed, scheduling reconnect', e, stackTrace);
      _scheduleReconnect();
      return;
    }
    // Disposal can race with the awaited token read (e.g. logout during
    // startup). Abort instead of resurrecting a socket on a disposed object.
    if (_isDisposed) return;

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
      // The socket may have been disposed while `ready` was pending.
      if (_isDisposed) {
        _cleanup();
        return;
      }
      _reconnectAttempts = 0;
      _lastServerMessage = DateTime.now();
      _logger.info('WebSocket connected');
      _setStatus(NotificationWsConnectionStatus.connected);

      _startHeartbeat();
      _listen();
    } catch (e, stackTrace) {
      _logger.warning('WebSocket connection failed', e, stackTrace);
      // Clean up the failed channel (closes its sink to release underlying
      // resources) before scheduling a reconnect.
      _cleanup();
      _setStatus(NotificationWsConnectionStatus.reconnecting);
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
        _setStatus(NotificationWsConnectionStatus.reconnecting);
        _scheduleReconnect();
      },
      onDone: () {
        _logger.info('WebSocket closed');
        _cleanup();
        // A dropped connection after initial connect must also be reconnected.
        _setStatus(NotificationWsConnectionStatus.reconnecting);
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
        _setStatus(NotificationWsConnectionStatus.reconnecting);
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

    // Give up once the attempt budget is exhausted rather than reconnecting
    // forever. A later connect() (e.g. after login or a server edit) restarts
    // the counter because _reconnectAttempts is reset to 0 on success.
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.severe(
        'NotificationWsService: giving up after $_maxReconnectAttempts '
        'reconnect attempts; call connect() again to retry',
      );
      _setStatus(NotificationWsConnectionStatus.failed);
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
    _setStatus(NotificationWsConnectionStatus.disconnected);
    unawaited(_statusController.close());
  }
}
