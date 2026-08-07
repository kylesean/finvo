import 'package:finvo/i18n/strings.g.dart';

/// Categories of GenUI / SSE streaming errors.
enum GenUiErrorType { busy, timeout, network, sessionExpired, generic }

/// Utility for classifying raw GenUI error strings into typed error cases
/// and mapping them to localized user messages.
class GenUiErrorTranslator {
  const GenUiErrorTranslator._();

  /// Classifies a raw error string into a structured [GenUiErrorType].
  static GenUiErrorType classify(String error) {
    if (error.contains('No generations') || error.contains('empty stream')) {
      return GenUiErrorType.busy;
    }
    // Dio reports "Exception: Connection timed out" / "The request timed out"
    // rather than "timeout", so match the participle form too.
    if (error.contains('timeout') ||
        error.contains('Timeout') ||
        error.contains('timed out')) {
      return GenUiErrorType.timeout;
    }
    if (error.contains('network') || error.contains('connection')) {
      return GenUiErrorType.network;
    }
    if (error.contains('Authentication') ||
        error.contains('token') ||
        error.contains('401') ||
        error.contains('403')) {
      return GenUiErrorType.sessionExpired;
    }
    return GenUiErrorType.generic;
  }

  /// Maps a [GenUiErrorType] to a user-facing localized string.
  static String toUserMessage(GenUiErrorType type) {
    switch (type) {
      case GenUiErrorType.busy:
        return t.genui.errorBusy;
      case GenUiErrorType.timeout:
        return t.genui.errorTimeout;
      case GenUiErrorType.network:
        return t.genui.errorNetwork;
      case GenUiErrorType.sessionExpired:
        return t.genui.errorSessionExpired;
      case GenUiErrorType.generic:
        return t.genui.errorGeneric;
    }
  }

  /// Convenience method that classifies and translates in one step.
  static String translate(String rawError) {
    final type = classify(rawError);
    return toUserMessage(type);
  }
}
