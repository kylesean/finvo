// features/chat/models/speech_error_type.dart

/// Strongly-typed classification of speech recognition errors.
///
/// Replaces magic strings across SpeechRecognitionService implementations,
/// SpeechSessionManager, and UI notification layers.
enum SpeechErrorType {
  /// System voice recognition service restricted or unavailable on device (Android/iOS)
  systemRestricted,

  /// iOS dictation is turned off in device settings
  dictationDisabled,

  /// Microphone or speech permission was denied by the user
  permissionDenied,

  /// Speech service is not configured (e.g. missing server settings)
  notConfigured,

  /// Failed to establish a WebSocket or network connection to the speech server
  connectionFailed,

  /// Listening timed out with no speech recognized
  noSpeechRecognized,

  /// Generic/unclassified speech error
  unknown;

  /// Classifies a raw error string (from native speech_to_text or network)
  /// into a stable, strongly-typed [SpeechErrorType].
  static SpeechErrorType classify(String rawError) {
    if (rawError == 'system_speech_restricted') {
      return SpeechErrorType.systemRestricted;
    }
    if (rawError == 'dictation_disabled') {
      return SpeechErrorType.dictationDisabled;
    }
    if (rawError == 'permission_denied') {
      return SpeechErrorType.permissionDenied;
    }
    if (rawError == 'speech_not_configured') {
      return SpeechErrorType.notConfigured;
    }
    if (rawError == 'speech_connection_failed') {
      return SpeechErrorType.connectionFailed;
    }
    if (rawError == 'no_speech_recognized') {
      return SpeechErrorType.noSpeechRecognized;
    }

    final lower = rawError.toLowerCase();
    if (lower.contains('permission') || lower.contains('denied')) {
      return SpeechErrorType.permissionDenied;
    }
    if (lower.contains('dictation')) {
      return SpeechErrorType.dictationDisabled;
    }
    if (lower.contains('restricted') ||
        lower.contains('securityexception') ||
        lower.contains('bindservice')) {
      return SpeechErrorType.systemRestricted;
    }
    if (lower.contains('connection') ||
        lower.contains('connect') ||
        lower.contains('refused') ||
        lower.contains('socket')) {
      return SpeechErrorType.connectionFailed;
    }
    if (lower.contains('timeout')) {
      return SpeechErrorType.noSpeechRecognized;
    }

    return SpeechErrorType.unknown;
  }
}
