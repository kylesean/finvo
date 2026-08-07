// features/chat/services/websocket_speech_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finvo/features/chat/config/speech_config.dart';
import 'package:finvo/features/chat/services/audio_recorder_service.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';

final _logger = Logger('WebSocketSpeechService');

class WebSocketSpeechService implements SpeechRecognitionService {
  final String host;
  final int port;
  final String path;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  bool _isConnected = false;
  bool _isListening = false;
  bool _isManualStop = false; // User manual stop protection flag

  // Audio recording service
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  StreamSubscription<Uint8List>? _audioSubscription;

  // Stream controllers for different events
  final StreamController<String> _resultController =
      StreamController<String>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Idle reconnect bookkeeping. Mirrors NotificationWsService: bounded
  // exponential backoff so a dead ASR server is not polled forever, and no
  // reconnect is ever attempted mid-session (a dropped socket during an
  // active recording surfaces as an error to the user instead).
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  static const _maxReconnectAttempts = 3;
  static const _maxReconnectDelaySeconds = 8;

  // Public streams
  @override
  Stream<String> get onResult => _resultController.stream;
  @override
  Stream<String> get onStatus => _statusController.stream;
  @override
  Stream<String> get onError => _errorController.stream;

  @override
  bool get isInitialized => _isConnected;

  @override
  SpeechServiceType get serviceType => SpeechServiceType.websocket;

  @override
  bool get isIncrementalResult => true; // WebSocket is incremental mode

  WebSocketSpeechService({String? host, int? port, String? path})
    : host = host ?? SpeechConfig.host,
      port = port ?? SpeechConfig.port,
      path = path ?? SpeechConfig.path;

  /// Build the ASR endpoint URL, honoring an explicit scheme.
  ///
  /// A [host] carrying its own scheme (ws:// or wss://) is used verbatim so
  /// TLS-enabled deployments can be configured directly; otherwise the
  /// configured [SpeechConfig.scheme] applies (defaults to ws:// for
  /// backward compatibility with existing self-hosted setups).
  String _buildWsUrl() {
    if (host.startsWith('ws://') || host.startsWith('wss://')) {
      return '$host$path';
    }
    return '${SpeechConfig.scheme}://$host:$port$path';
  }

  /// Check microphone permission
  @override
  Future<bool> hasPermission() async {
    try {
      return await _audioRecorder.hasPermission();
    } catch (e, stackTrace) {
      _logger.severe('Failed to check microphone permission', e, stackTrace);
      return false;
    }
  }

  /// Request microphone permission
  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e, stackTrace) {
      _logger.severe('Failed to request microphone permission', e, stackTrace);
      return false;
    }
  }

  /// Initialize WebSocket connection
  @override
  Future<bool> initialize() async {
    // Guard against use after dispose: dispose() closes the stream
    // controllers, so any later add() would raise StateError. No reconnect
    // (timer callback or caller) may resurrect a released service.
    if (_isDisposed) {
      _logger.warning('WebSocket already disposed, cannot initialize');
      return false;
    }

    // If already connected, return success directly (simplified logic, avoid ping test issues)
    if (_isConnected && _channel != null) {
      _logger.info('WebSocket already connected, reusing existing connection');
      return true;
    }

    // Clean up previous connection
    await _cleanup();

    try {
      final wsUrl = _buildWsUrl();
      _logger.info('Connecting to WebSocket server: $wsUrl');
      if (!_statusController.isClosed) _statusController.add('connecting');

      // WebSocketChannel.connect is cross-platform (IO + web) and supports
      // both ws:// and wss://, unlike the previous IOWebSocketChannel.
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to connection status, add timeout mechanism (10 seconds)
      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw SpeechServiceException(
            'WebSocket connection timeout (10 seconds)',
          );
        },
      );
      _isConnected = true;
      _reconnectAttempts = 0;
      if (!_statusController.isClosed) _statusController.add('connected');
      _logger.info('WebSocket connected successfully');

      // Listen to messages
      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      return true;
    } catch (e, stackTrace) {
      final speechException = SpeechServiceException(
        'WebSocket connection failed: $e',
      );
      _logger.severe(
        'WebSocket connection failed',
        speechException,
        stackTrace,
      );
      if (!_errorController.isClosed) {
        _errorController.add('speech_connection_failed');
      }
      if (!_statusController.isClosed) {
        _statusController.add('disconnected');
      }
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<bool> ensureReady() async {
    // If already connected, return immediately
    if (_isConnected && _channel != null) {
      _logger.info('WebSocket already connected, ready for recognition');
      return true;
    }

    // Otherwise, try to connect/reconnect
    _logger.info('WebSocket not connected, attempting to connect...');
    return await initialize();
  }

  /// Clean up connection resources
  Future<void> _cleanup() async {
    if (_isListening) {
      await _audioRecorder.stopRecording();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      _isListening = false;
    }

    await _channelSubscription?.cancel();
    _channelSubscription = null;

    if (_channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        _logger.warning('Error closing WebSocket connection: $e');
      }
      _channel = null;
    }

    _isConnected = false;
  }

  /// Start speech recognition
  @override
  Future<void> startListening() async {
    // Defensive reset: a stale manual-stop flag from a previous session (whose
    // connection stayed open and never hit _onError/_onDisconnected) would
    // otherwise swallow the real errors of this new session.
    _isManualStop = false;

    if (!_isConnected) {
      _logger.warning('WebSocket not connected, cannot start listening');
      // Stable token (see SpeechErrorClassifier / chat_input_field dialog
      // mapping) instead of a raw English sentence.
      _errorController.add('speech_connection_failed');
      return;
    }

    if (_isListening) {
      _logger.warning('Already listening');
      return;
    }

    try {
      _logger.info('Starting speech recognition process...');

      // 1. Check permissions
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        _logger.severe('Microphone permission denied');
        // Stable token mapped to a localized dialog by the chat input UI.
        _errorController.add('permission_denied');
        return;
      }

      // 2. Start recording
      // Sound effect already played in ChatInputNotifier, start recording directly
      final recordingStarted = await _audioRecorder.startRecording();
      if (!recordingStarted) {
        _logger.severe('Failed to start recording');
        _errorController.add('Failed to start recording');
        return;
      }

      // 3. Listen to audio stream and send to WebSocket
      final audioStream = _audioRecorder.audioStream;
      if (audioStream != null) {
        _audioSubscription = audioStream.listen(
          (audioData) {
            if (kDebugMode) {
              _logger.finest('Sending audio data: ${audioData.length} bytes');
            }
            sendAudioData(audioData);
          },
          onError: (Object error) {
            // Some platforms may trigger errors when stopping recording, ignore during manual stop or non-listening state
            if (_isManualStop || !_isListening) {
              _logger.info(
                'Ignoring audio stream error during manual stop: $error',
              );
              return;
            }
            _logger.severe('Audio stream error: $error');
            _errorController.add('Recording error: $error');
          },
          onDone: () {
            _logger.info('Audio stream ended');
          },
        );
      }

      // Note: ASR server expects pure binary audio data only
      // Do not send JSON control messages as they will be misinterpreted as audio data

      _isListening = true;
      _statusController.add('listening');
      _logger.info('Speech recognition started');
    } catch (e) {
      _logger.severe('Failed to start listening: $e');
      _errorController.add('Failed to start listening: $e');
      _isListening = false;
      _statusController.add('error');

      // Clean up resources
      await _audioRecorder.stopRecording();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
    }
  }

  /// Stop speech recognition
  @override
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      _logger.info('Stopping speech recognition process...');

      // 1. Mark as manual stop and stop recording
      _isManualStop = true;
      await _audioRecorder.stopRecording();

      // 2. Cancel audio stream subscription
      await _audioSubscription?.cancel();
      _audioSubscription = null;

      // Note: ASR server expects pure binary audio data only
      // Do not send JSON control messages as they will be misinterpreted as audio data

      _isListening = false;
      // Reset the manual-stop flag once the stop sequence completes. The WS
      // connection usually stays open (keep-alive), so _onError/_onDisconnected
      // may never fire to clear it — leaving it set would swallow the real
      // errors of the next listening session.
      _isManualStop = false;
      _statusController.add('stopped');
      _logger.info('Speech recognition stopped');

      // Play stop recording sound (don't await to avoid blocking)
      _logger.info('Playing stop sound...');
      unawaited(SoundFeedbackService.instance.playStopSound());
    } catch (e) {
      _logger.severe('Failed to stop listening: $e');
      _errorController.add('Failed to stop listening: $e');
      _isListening = false;
      _statusController.add('error');
    }
  }

  /// Send audio data to WebSocket
  void sendAudioData(Uint8List audioData) {
    if (!_isConnected || !_isListening) {
      return;
    }

    try {
      // Send binary audio data directly
      _channel!.sink.add(audioData);
    } catch (e) {
      _logger.severe('Failed to send audio data: $e');
      _errorController.add('Failed to send audio data: $e');
    }
  }

  /// Handle received messages
  void _onMessage(dynamic message) {
    try {
      _logger.info('Received message: $message');

      // If message is plain text, use directly as recognition result
      if (message is String) {
        // Try to parse as JSON
        try {
          final jsonData = jsonDecode(message);
          if (jsonData is Map<String, dynamic>) {
            // Handle JSON format messages
            _handleJsonMessage(jsonData);
          } else {
            // Use directly as recognition result
            _resultController.add(message);
          }
        } catch (e) {
          // Not JSON format, use directly as recognition result
          _resultController.add(message);
        }
      } else {
        // Other format messages
        _resultController.add(message.toString());
      }
    } catch (e) {
      _logger.severe('Failed to process message: $e');
      _errorController.add('Failed to process message: $e');
    }
  }

  /// Handle JSON format messages
  void _handleJsonMessage(Map<String, dynamic> jsonData) {
    // Handle different types of messages based on backend protocol
    final type = jsonData['type'] ?? jsonData['action'];

    switch (type) {
      case 'result':
      case 'recognition_result':
        final text =
            (jsonData['text'] as String?) ??
            (jsonData['result'] as String?) ??
            '';
        if (text.isNotEmpty) {
          _resultController.add(text);
        }
        break;
      case 'status':
        final status = (jsonData['status'] as String?) ?? '';
        if (status.isNotEmpty) {
          _statusController.add(status);
        }
        break;
      case 'error':
        final error =
            (jsonData['error'] as String?) ??
            (jsonData['message'] as String?) ??
            'Unknown error';
        // Ignore errors from server during manual stop or non-listening state
        if (_isManualStop || !_isListening) {
          _logger.info(
            'Ignoring server error during manual stop or non-listening state: $error',
          );
          break;
        }
        _errorController.add(error);
        break;
      default:
        // If there is a text field, use as recognition result
        final text = jsonData['text'] ?? jsonData['result'];
        if (text != null && text.toString().isNotEmpty) {
          _resultController.add(text.toString());
        }
    }
  }

  /// Handle connection errors
  void _onError(Object error) {
    _logger.severe('WebSocket error: $error');

    // If disconnect caused by user manual stop, ignore error
    if (_isManualStop) {
      _logger.info(
        'WebSocket error caused by user manual stop, ignoring: $error',
      );
      _isManualStop = false; // Reset flag
      _statusController.add('disconnected');
      _isConnected = false;
      _isListening = false;
      return;
    }

    _errorController.add('speech_connection_failed');
    _statusController.add('error');
    _isConnected = false;
    final wasListening = _isListening;
    _isListening = false;

    // A drop outside an active session is transparently repaired in the
    // background; mid-session drops already surfaced an error to the user.
    if (!wasListening) {
      _maybeScheduleReconnect();
    }
  }

  /// Handle connection disconnect
  void _onDisconnected() {
    _logger.info('WebSocket connection disconnected');

    // If disconnect caused by user manual stop, treat as normal flow, don't dispatch error
    if (_isManualStop) {
      _logger.info('Disconnect caused by user manual stop, ignoring error');
      _isManualStop = false; // Reset flag
    } else if (_isListening && !_errorController.isClosed) {
      // Only dispatch error if abnormal disconnect and currently listening
      _errorController.add('speech_connection_failed');
    }

    // Only add status if controller is not closed (could be called after dispose)
    if (!_statusController.isClosed) {
      _statusController.add('disconnected');
    }
    _isConnected = false;
    final wasListening = _isListening;
    _isListening = false;

    // Clean up audio related resources
    unawaited(() async {
      try {
        await _audioRecorder.stopRecording();
      } catch (e) {
        _logger.warning('Error stopping recording: $e');
      }
    }());
    unawaited(_audioSubscription?.cancel());
    _audioSubscription = null;

    // Restore the warm connection in the background when the drop happened
    // outside an active session, so the next voice message does not pay the
    // full connect latency (or fail) because of a silently dead socket.
    if (!wasListening) {
      _maybeScheduleReconnect();
    }
  }

  /// Schedule a bounded, backoff-throttled reconnect for the idle state.
  ///
  /// Never reconnects mid-session ([_isListening]), after disposal, or after
  /// [_maxReconnectAttempts] consecutive failures (a later user-initiated
  /// [ensureReady]/[initialize] resets the counter on success).
  void _maybeScheduleReconnect() {
    if (_isDisposed || _isListening || _isManualStop) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.warning(
        'Speech WS: giving up after $_maxReconnectAttempts reconnect '
        'attempts; next session will retry from scratch',
      );
      return;
    }

    _reconnectTimer?.cancel();
    final delaySeconds = min(
      pow(2, _reconnectAttempts).toInt(),
      _maxReconnectDelaySeconds,
    );
    _reconnectAttempts++;
    _logger.info(
      'Speech WS: reconnecting in ${delaySeconds}s '
      '(attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_isDisposed || _isListening || _isConnected) return;
      unawaited(initialize());
    });
  }

  /// Release resources
  @override
  Future<void> dispose() async {
    _logger.info('Releasing WebSocketSpeechService resources');
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Use unified cleanup method
    await _cleanup();

    // Release audio recording service
    _audioRecorder.dispose();

    // Close stream controllers
    if (!_resultController.isClosed) unawaited(_resultController.close());
    if (!_statusController.isClosed) unawaited(_statusController.close());
    if (!_errorController.isClosed) unawaited(_errorController.close());
  }

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Get listening status
  @override
  bool get isListening => _isListening;
}
