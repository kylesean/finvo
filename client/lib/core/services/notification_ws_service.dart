// core/services/notification_ws_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:meta/meta.dart';
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

  /// Monotonic token that invalidates stale async connect() callbacks. Each
  /// call to [connect] bumps it; any awaited continuation that observes a
  /// changed token (a newer connect or a dispose) must abort. Without this, two
  /// concurrent connect() calls can tear each other down via [_cleanup] and
  /// race to reinstate a half-open socket.
  int _connectGeneration = 0;

  /// Shared RNG for reconnect-backoff jitter (deterministic seeding is not
  /// needed; the service is not created in tests unless jitter is asserted).
  final _random = Random();

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

  /// Elapsed time since the last pong (or any server message) was received,
  /// used to detect half-open connections where the TCP socket is alive but
  /// the peer is not responding. A monotonic [Stopwatch] is used instead of a
  /// wall-clock [DateTime] so system clock changes cannot corrupt the timeout.
  final Stopwatch _sinceLastServerMessage = Stopwatch()..start();

  // Retained so a dropped connection can be re-established.
  String? _baseUrl;
  SecureStorageService? _storageService;

  static const _heartbeatIntervalProduction = Duration(seconds: 30);
  static const _maxReconnectDelay = Duration(seconds: 30);
  // Bounded reconnect attempts: once exceeded, automatic reconnection stops so
  // a permanently unreachable server doesn't keep waking the device every
  // backoff interval forever. connect() is still re-invoked externally when
  // the auth token changes (provider rebuild) or the server config is edited.
  static const _maxReconnectAttempts = 5;

  /// Heartbeat cadence. Declared as an instance field (not a const) so tests
  /// can shrink it to make the half-open connection detection observable;
  /// production uses the 30s default.
  Duration heartbeatInterval = _heartbeatIntervalProduction;

  /// Test seam: replaces the platform [connectWs] so tests can inject a fake
  /// channel without opening a real socket. Production code never sets this.
  @visibleForTesting
  WebSocketChannel Function(String wsUrl, {required String token})?
  connectChannelFactory;

  /// Test seam: disables reconnect-delay jitter so tests can elapse exact
  /// exponential-backoff durations. Production never sets this.
  @visibleForTesting
  bool enableReconnectJitter = true;

  NotificationCallback? onNotification;

  /// Connect to the notification WebSocket.
  ///
  /// [resetBudget] resets the reconnect attempt counter. External callers
  /// (auth change, server edit) should pass the default `true` so a fresh user
  /// action starts with a full reconnect budget; internal automatic reconnects
  /// pass `false` so the budget accumulates toward [_maxReconnectAttempts].
  Future<void> connect({
    required String baseUrl,
    required SecureStorageService storageService,
    bool resetBudget = true,
  }) async {
    if (_isDisposed) return;

    // Claim this connect as the newest. A stale connect() that was already
    // awaiting a token read / handshake will see the new generation and abort
    // instead of stepping on the socket we are about to establish.
    final generation = ++_connectGeneration;

    // A fresh external connect is a new connection session: give it a full
    // reconnect budget instead of inheriting a possibly-exhausted counter from
    // a previous session (H3 fix).
    if (resetBudget) {
      _reconnectAttempts = 0;
    }

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
    // Disposal or a newer connect() can race with the awaited token read
    // (e.g. logout during startup). Abort instead of resurrecting a socket on
    // a stale generation / disposed object.
    if (_isDisposed || generation != _connectGeneration) return;

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
      // connectChannelFactory lets tests inject a fake channel; production
      // always falls through to the platform connectWs.
      final channel = (connectChannelFactory ?? connectWs)(
        wsBase,
        token: token,
      );
      _channel = channel;
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
      // The socket may have been disposed (or superseded by a newer connect)
      // while `ready` was pending.
      if (_isDisposed || generation != _connectGeneration) {
        _cleanup();
        return;
      }
      _reconnectAttempts = 0;
      _sinceLastServerMessage.reset();
      _logger.info('WebSocket connected');
      _setStatus(NotificationWsConnectionStatus.connected);

      _startHeartbeat();
      _listen(channel, generation);
    } catch (e, stackTrace) {
      _logger.warning('WebSocket connection failed', e, stackTrace);
      // Clean up the failed channel (closes its sink to release underlying
      // resources) before scheduling a reconnect.
      _cleanup();
      _setStatus(NotificationWsConnectionStatus.reconnecting);
      _scheduleReconnect();
    }
  }

  void _listen(WebSocketChannel channel, int generation) {
    _subscription = channel.stream.listen(
      (message) {
        // A stale channel's late event must not be attributed to the current
        // connection (e.g. the message timer or an in-flight message arriving
        // after a newer connect() replaced this channel).
        if (generation != _connectGeneration || !identical(channel, _channel)) {
          return;
        }
        _sinceLastServerMessage.reset();
        // Parse first, dispatch second: a failure in the callback is NOT a
        // parse failure. Keeping them in one try/catch would mislabel a
        // callback exception as "Failed to parse WS message" and mask the
        // real bug.
        late final Map<String, dynamic> data;
        try {
          data = jsonDecode(message as String) as Map<String, dynamic>;
        } catch (e) {
          _logger.warning('Failed to parse WS message: $e');
          return;
        }
        final type = data['type'] as String?;
        try {
          if (type == 'notification') {
            final payload = data['payload'] as Map<String, dynamic>?;
            if (payload != null) {
              onNotification?.call(payload);
            }
          } else if (type == 'comment_updated') {
            onNotification?.call(data);
          }
          // Ignore 'pong' responses
        } catch (e, st) {
          _logger.warning('Notification callback failed', e, st);
        }
      },
      onError: (Object error) {
        // Only the current connection may tear down state: an old channel's
        // terminal event must not _cleanup() (and cancel the heartbeat/
        // reconnect timer of) the channel that has replaced it.
        if (generation != _connectGeneration || !identical(channel, _channel)) {
          return;
        }
        _logger.warning('WebSocket error: $error');
        _cleanup();
        _setStatus(NotificationWsConnectionStatus.reconnecting);
        _scheduleReconnect();
      },
      onDone: () {
        if (generation != _connectGeneration || !identical(channel, _channel)) {
          return;
        }
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
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      // Detect half-open connections: if the server has not responded within
      // several heartbeat intervals, drop the socket and reconnect instead of
      // silently keeping an unresponsive connection alive.
      if (_sinceLastServerMessage.elapsed > heartbeatInterval * 3) {
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
    // Cancel any pending reconnect so a torn-down connection doesn't schedule
    // a fresh one from a stale timer while a newer connect() is in flight.
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
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

    // Exponential backoff: 1s, 2s, 4s, 8s, ... max 30s, with a small random
    // jitter (±25%) so many clients reconnecting at once (e.g. after a server
    // restart) do not synchronize into a thundering herd on the same cadence.
    final baseDelay = Duration(
      seconds: min(
        pow(2, _reconnectAttempts).toInt(),
        _maxReconnectDelay.inSeconds,
      ),
    );
    final jitterMs = (baseDelay.inMilliseconds * 0.25).round();
    final delay = enableReconnectJitter
        ? baseDelay +
              Duration(
                milliseconds: _random.nextInt(jitterMs * 2 + 1) - jitterMs,
              )
        : baseDelay;
    _reconnectAttempts++;

    _logger.info(
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, () {
      unawaited(
        connect(
          baseUrl: baseUrl,
          storageService: storageService,
          resetBudget: false,
        ),
      );
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
