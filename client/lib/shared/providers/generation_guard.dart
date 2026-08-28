/// Monotonic request-generation guard for async notifier state.
///
/// Every new load bumps the counter and captures the returned value; a
/// response whose captured value no longer matches the current generation is
/// stale and must be discarded — otherwise a fast filter switch, session
/// switch, or provider invalidation lets a slow older response overwrite
/// newer state.
///
/// Route new code through this class — or [PaginatedListMixin] for full
/// pagination state machines — instead of re-rolling the pattern by hand.
class GenerationGuard {
  int _generation = 0;

  /// Bump to a new generation and return the captured value.
  int bump() => ++_generation;

  /// Capture the current generation without bumping (for load-more paths
  /// that must be invalidated by a concurrent refresh, but must not
  /// themselves invalidate anyone).
  int get current => _generation;

  /// Whether [generation] is still the latest one.
  bool isCurrent(int generation) => generation == _generation;
}
