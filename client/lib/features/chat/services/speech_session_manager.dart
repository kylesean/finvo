// features/chat/services/speech_session_manager.dart
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/services/speech_service_factory.dart';
import 'package:finvo/features/chat/services/system_speech_service.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';

/// Classifies raw speech error strings into stable, user-facing tokens.
///
/// Extracted from the chat input notifier so that error mapping is a pure,
/// unit-testable function instead of inline substring matching.
class SpeechErrorClassifier {
  const SpeechErrorClassifier._();

  /// Map a raw service error message to a stable classification token.
  ///
  /// Returns one of the known token constants, or the original message when
  /// the error cannot be recognized.
  static String classify(String error) {
    final lower = error.toLowerCase();
    if (error == 'system_speech_restricted' ||
        error == 'dictation_disabled' ||
        error == 'permission_denied') {
      return error;
    }
    if (error == 'speech_not_configured') {
      return 'speech_not_configured';
    }
    if (error == 'speech_connection_failed' ||
        lower.contains('connection') ||
        lower.contains('connect') ||
        lower.contains('failed') ||
        lower.contains('refused') ||
        lower.contains('socket')) {
      return 'speech_connection_failed';
    }
    if (lower.contains('timeout')) {
      return 'no_speech_recognized';
    }
    return error;
  }
}

/// Manages the speech recognition service lifecycle and session state,
/// decoupled from the UI state.
///
/// Responsibilities:
/// - Creating / swapping the concrete [SpeechRecognitionService] via the factory.
/// - Wiring and tearing down service subscriptions.
/// - Starting / stopping a recognition session (including the no-input timeout).
/// - Classifying raw errors into stable tokens.
///
/// The owning notifier reacts to [onResult], [onStatus] and [onError] callbacks
/// and keeps its own UI state machine.
class SpeechSessionManager {
  static final _logger = Logger('SpeechSessionManager');

  SpeechRecognitionService? _service;
  SpeechServiceType? _serviceType;

  StreamSubscription<String>? _resultSubscription;
  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<String>? _errorSubscription;

  Timer? _noSpeechInputTimer;
  bool _isListening = false;

  /// Recognized text pushed by the active service (raw, un-concatenated).
  void Function(String text)? onResult;

  /// Status pushed by the active service ('listening' / 'stopped', ...).
  void Function(String status)? onStatus;

  /// Classified error token pushed when the service reports an error.
  void Function(String errorToken)? onError;

  SpeechServiceType? get serviceType => _serviceType;
  bool get isListening => _isListening;

  /// Whether the active service emits incremental (replace-mode) partial
  /// results rather than discrete final results. The chat input notifier uses
  /// this to decide between replacing the recognized text (incremental) and
  /// appending it (discrete finals).
  bool get isIncrementalResult => _service?.isIncrementalResult ?? false;

  /// Last classified error token, retained for callers that need it.
  String? lastError;

  /// Selects the active service type, creating or replacing the underlying
  /// service when [previousType] differs from [type] or no service exists yet.
  void setServiceType({
    required SpeechServiceType type,
    required SpeechServiceType? previousType,
    String? websocketHost,
    int? websocketPort,
    String? websocketPath,
  }) {
    if (previousType == type && _service != null) {
      return;
    }
    disposeService();
    _serviceType = type;
    _service = SpeechServiceFactory.create(
      type,
      websocketHost: websocketHost,
      websocketPort: websocketPort,
      websocketPath: websocketPath,
    );
    _ensureSubscriptions();
  }

  /// Starts a recognition session.
  ///
  /// Returns `null` on success, or a classified error token on failure.
  Future<String?> startSession() async {
    final service = _service;
    if (service == null) {
      return _serviceType == SpeechServiceType.system
          ? 'system_speech_restricted'
          : 'speech_not_configured';
    }

    if (_serviceType == SpeechServiceType.websocket) {
      await SoundFeedbackService.instance.playStartSound();
    }

    bool isReady = false;
    try {
      isReady = await service.ensureReady();
    } catch (_) {
      isReady = false;
    }

    if (!isReady) {
      if (_serviceType == SpeechServiceType.system &&
          service is SystemSpeechService) {
        return service.lastError ?? 'system_speech_restricted';
      }
      return _serviceType == SpeechServiceType.system
          ? 'system_speech_restricted'
          : 'speech_connection_failed';
    }

    _ensureSubscriptions();
    await service.startListening();
    _isListening = true;

    _noSpeechInputTimer?.cancel();
    _noSpeechInputTimer = Timer(const Duration(seconds: 30), () {
      if (_isListening) {
        _logger.info(
          'SpeechSessionManager: No valid speech input after 30 seconds, stopping actively',
        );
        unawaited(service.stopListening());
      }
    });
    return null;
  }

  /// Stops the current session. [manual] distinguishes a user-initiated stop
  /// from an automatic stop (e.g. silence), which affects error handling.
  Future<void> stopListening({required bool manual}) async {
    _noSpeechInputTimer?.cancel();
    await _service?.stopListening();
  }

  /// Cancels the no-input timeout timer (e.g. when the user types manually).
  void cancelNoInputTimer() {
    _noSpeechInputTimer?.cancel();
  }

  /// Releases all service resources and subscriptions.
  void disposeService() {
    unawaited(_resultSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    _noSpeechInputTimer?.cancel();
    _resultSubscription = null;
    _statusSubscription = null;
    _errorSubscription = null;
    _noSpeechInputTimer = null;
    unawaited(_service?.dispose());
    _service = null;
    _serviceType = null;
    _isListening = false;
  }

  void _ensureSubscriptions() {
    final service = _service;
    if (service == null || _resultSubscription != null) return;

    _resultSubscription = service.onResult.listen(_handleResult);
    _statusSubscription = service.onStatus.listen(_handleStatus);
    _errorSubscription = service.onError.listen(_handleError);
  }

  void _handleResult(String text) {
    _noSpeechInputTimer?.cancel();
    onResult?.call(text);
  }

  void _handleStatus(String status) {
    _noSpeechInputTimer?.cancel();
    _isListening = status == 'listening';
    onStatus?.call(status);
  }

  void _handleError(String error) {
    _noSpeechInputTimer?.cancel();
    final token = SpeechErrorClassifier.classify(error);
    lastError = token;
    onError?.call(token);
  }
}
