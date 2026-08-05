// features/chat/services/retry_policy.dart
import 'dart:async';

import 'package:logging/logging.dart';

/// Retry logic with exponential backoff.
///
/// Extracted from [ErrorRecoveryStrategy] so that retry mechanics are a
/// separate, testable concern from the error-rendering widgets.
class RetryPolicy {
  final _logger = Logger('RetryPolicy');

  /// Maximum number of retry attempts for network operations.
  static const int defaultMaxRetries = 3;

  /// Initial delay for exponential backoff.
  static const Duration defaultInitialDelay = Duration(seconds: 1);

  Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxAttempts = defaultMaxRetries,
    Duration initialDelay = defaultInitialDelay,
    void Function(int attempt, Duration nextDelay)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    Object? lastError;
    StackTrace? lastStackTrace;

    while (attempt < maxAttempts) {
      try {
        _logger.info(
          'Attempting operation (attempt ${attempt + 1}/$maxAttempts)',
        );
        return await operation();
      } catch (e, stackTrace) {
        lastError = e;
        lastStackTrace = stackTrace;
        attempt++;

        _logger.warning(
          'Operation failed (attempt $attempt/$maxAttempts)',
          e,
          stackTrace,
        );

        if (attempt >= maxAttempts) {
          _logger.severe('All retry attempts exhausted', lastError);
          rethrow;
        }

        if (onRetry != null) {
          onRetry(attempt, delay);
        }

        _logger.info('Retrying after ${delay.inSeconds}s delay');
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    // Fallback for the edge case where the loop never runs (maxAttempts <= 0).
    // Preserve the original error type and stack instead of wrapping it.
    if (lastError != null) {
      Error.throwWithStackTrace(
        lastError,
        lastStackTrace ?? StackTrace.current,
      );
    }
    throw StateError(
      'retryWithBackoff: no attempts made (maxAttempts=$maxAttempts)',
    );
  }
}
