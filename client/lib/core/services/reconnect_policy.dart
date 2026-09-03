import 'dart:async';
import 'dart:math';

/// Bounded reconnect budget with exponential backoff.
///
/// Shared by the notification and speech WebSocket services so their retry
/// behavior stays identical. Guards (mid-session, manual stop, missing
/// config) stay in the services; only counting, delay math, and the timer
/// live here.
class ReconnectPolicy {
  ReconnectPolicy({
    required this.maxAttempts,
    this.maxDelay = const Duration(seconds: 30),
    this.jitterFraction = 0.25,
    Random? random,
  }) : _random = random ?? Random();

  final int maxAttempts;
  final Duration maxDelay;

  /// 0 disables jitter (tests use this for exact fake_async elapses).
  double jitterFraction;

  final Random _random;
  int attempts = 0;
  Timer? _timer;
  bool _disposed = false;

  bool get exhausted => attempts >= maxAttempts;

  void markSucceeded() {
    attempts = 0;
    _timer?.cancel();
    _timer = null;
  }

  /// Arms a backoff retry. Returns false (and does nothing) when the budget
  /// is spent or the policy is disposed.
  bool schedule(void Function() retry) {
    if (_disposed || exhausted) return false;
    _timer?.cancel();
    _timer = Timer(_nextDelay(), () {
      if (_disposed) return;
      retry();
    });
    return true;
  }

  Duration _nextDelay() {
    final capped = Duration(
      seconds: min(pow(2, attempts).toInt(), maxDelay.inSeconds),
    );
    attempts++;
    if (jitterFraction <= 0) return capped;
    final jitterMs = (capped.inMilliseconds * jitterFraction).round();
    return capped +
        Duration(milliseconds: _random.nextInt(jitterMs * 2 + 1) - jitterMs);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _disposed = true;
    cancel();
  }
}
