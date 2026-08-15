import 'dart:async';

import 'package:logging/logging.dart';

import 'package:finvo/features/chat/models/speech_error_type.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/services/speech_service_factory.dart';
import 'package:finvo/features/chat/services/system_speech_service.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';
// ignore_for_file: prefer_initializing_formals - private fields with public named ctor params

final _logger = Logger('SpeechSessionManager');

/// Classifies raw speech error strings into strongly-typed [SpeechErrorType] tokens.
class SpeechErrorClassifier {
  const SpeechErrorClassifier._();

  /// Map a raw service error message to a strongly-typed [SpeechErrorType].
  static SpeechErrorType classify(String error) {
    return SpeechErrorType.classify(error);
  }
}

/// Manages the speech recognition service lifecycle and session state,
/// decoupled from the UI state.
///
/// Responsibilities:
/// - Creating / swapping the concrete [SpeechRecognitionService] via the factory.
/// - Wiring and tearing down service subscriptions.
/// - Starting / stopping a recognition session (including the no-input timeout).
/// - Classifying raw errors into stable strongly-typed [SpeechErrorType] tokens.
///
/// The owning notifier reacts to [onResult], [onStatus] and [onError] callbacks
/// and keeps its own UI state machine.
class SpeechSessionManager {
  final SoundFeedbackService _soundFeedback;

  SpeechRecognitionService? _service;
  SpeechServiceType? _serviceType;

  StreamSubscription<String>? _resultSubscription;
  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<String>? _errorSubscription;

  Timer? _noSpeechInputTimer;
  bool _isListening = false;

  SpeechSessionManager({required SoundFeedbackService soundFeedback})
    : _soundFeedback = soundFeedback;

  /// Recognized text pushed by the active service (raw, un-concatenated).
  void Function(String text)? onResult;

  /// Status pushed by the active service ('listening' / 'stopped', ...).
  void Function(String status)? onStatus;

  /// Strongly-typed error pushed when the service reports an error.
  void Function(SpeechErrorType errorType)? onError;

  SpeechServiceType? get serviceType => _serviceType;
  bool get isListening => _isListening;

  /// Whether the active service emits incremental (replace-mode) partial
  /// results rather than discrete final results. The chat input notifier uses
  /// this to decide between replacing the recognized text (incremental) and
  /// appending it (discrete finals).
  bool get isIncrementalResult => _service?.isIncrementalResult ?? false;

  /// Last classified error token, retained for callers that need it.
  SpeechErrorType? lastError;

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
      soundFeedback: _soundFeedback,
      websocketHost: websocketHost,
      websocketPort: websocketPort,
      websocketPath: websocketPath,
    );
    _ensureSubscriptions();
  }

  /// Starts a recognition session.
  ///
  /// Returns `null` on success, or a strongly-typed [SpeechErrorType] on failure.
  Future<SpeechErrorType?> startSession() async {
    final service = _service;
    if (service == null) {
      return _serviceType == SpeechServiceType.system
          ? SpeechErrorType.systemRestricted
          : SpeechErrorType.notConfigured;
    }

    if (_serviceType == SpeechServiceType.websocket) {
      await _soundFeedback.playStartSound();
    }

    bool isReady = false;
    try {
      isReady = await service.ensureReady();
    } catch (e) {
      _logger.warning('Speech service readiness check failed', e);
      isReady = false;
    }

    if (!isReady) {
      if (_serviceType == SpeechServiceType.system &&
          service is SystemSpeechService) {
        final rawError = service.lastError;
        return rawError != null
            ? SpeechErrorClassifier.classify(rawError)
            : SpeechErrorType.systemRestricted;
      }
      return _serviceType == SpeechServiceType.system
          ? SpeechErrorType.systemRestricted
          : SpeechErrorType.connectionFailed;
    }

    _ensureSubscriptions();
    await service.startListening();
    _isListening = true;

    _armNoInputTimer(service: service);
    return null;
  }

  /// (Re)arms the no-input watchdog. Called when a session starts and after
  /// every recognized result, so silence — not elapsed wall time — triggers
  /// the timeout. Without the re-arm on results, a user who said a single
  /// word and then went silent could hold the session open forever.
  void _armNoInputTimer({SpeechRecognitionService? service}) {
    final target = service ?? _service;
    if (target == null) return;
    _noSpeechInputTimer?.cancel();
    _noSpeechInputTimer = Timer(const Duration(seconds: 30), () {
      unawaited(_handleTimeoutStop(target));
    });
  }

  Future<void> _handleTimeoutStop(SpeechRecognitionService service) async {
    if (!_isListening) return;
    _logger.info(
      'SpeechSessionManager: No valid speech input after 30 seconds, stopping actively',
    );
    try {
      await service.stopListening();
    } catch (e, stackTrace) {
      _logger.warning(
        'Error stopping speech service on timeout',
        e,
        stackTrace,
      );
    }
  }

  /// Stops the current session. [manual] distinguishes a user-initiated stop
  /// from an automatic stop (e.g. silence), which affects error handling.
  Future<void> stopListening({required bool manual}) async {
    _noSpeechInputTimer?.cancel();
    _noSpeechInputTimer = null;
    _isListening = false;
    await _service?.stopListening();
  }

  /// Cancels the no-input timeout timer (e.g. when the user types manually).
  void cancelNoInputTimer() {
    _noSpeechInputTimer?.cancel();
    _noSpeechInputTimer = null;
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
    _noSpeechInputTimer = null;
    _armNoInputTimer();
    onResult?.call(text);
  }

  void _handleStatus(String status) {
    _noSpeechInputTimer?.cancel();
    _isListening = status == 'listening';
    onStatus?.call(status);
  }

  void _handleError(String rawError) {
    _noSpeechInputTimer?.cancel();
    final errorType = SpeechErrorClassifier.classify(rawError);
    lastError = errorType;
    onError?.call(errorType);
  }
}
