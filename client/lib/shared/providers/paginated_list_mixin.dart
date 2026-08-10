/// Shared infinite-scroll pagination state machine.
library;

import 'package:finvo/core/network/exceptions/app_exception.dart';

/// Result of a single page fetch.
class PageResult<TItem> {
  const PageResult({required this.items, required this.total});

  /// Items of the fetched page.
  final List<TItem> items;

  /// Server-reported total item count (drives the `hasMore` decision).
  final int total;
}

/// Shared "refresh / load-more" pagination flow with stale-response guard.
///
/// [SharedSpaceNotifier] and [SpaceTransactionNotifier] previously duplicated
/// this exact state machine (generation counter, loading gating, append vs
/// replace, `hasMore` derivation, error mapping). The mixin owns the flow;
/// hosts implement the small accessor surface below and call [loadPage].
///
/// Semantics preserved from the original implementations:
/// - `refresh` keeps the currently visible items while loading (a failed
///   refresh must not wipe what is already shown) and invalidates any
///   in-flight load-more so its response cannot append onto the new list.
/// - `loadMore` is a no-op while loading or when the list is exhausted.
/// - A stale response (older epoch) is discarded.
///
/// Deliberately does not constrain `on Notifier<...>` (Riverpod codegen bases
/// classes on the internal `$Notifier` type); it talks to the host through
/// [pageState] + the accessor methods.
mixin PaginatedListMixin<TItem, TState> {
  /// Monotonic epoch. Incremented on every refresh; a response whose captured
  /// epoch no longer matches is discarded.
  int _pageGeneration = 0;

  /// Whether the host provider is still mounted (mirrors `ref.mounted`).
  bool get pageMounted;

  /// Host state (read/write — replaced after each mutation).
  TState get pageState;
  set pageState(TState value);

  /// Currently visible items.
  List<TItem> get pageItems;
  bool get pageIsLoading;
  bool get pageHasMore;
  int get pageCurrentPage;

  /// Fetch one page. [page] is 1-based.
  Future<PageResult<TItem>> fetchPage(int page);

  /// Rebuild host state with the mutated pagination fields.
  /// [result] carries the fetched page (may be used for extra state fields
  /// such as a server-reported total).
  TState updatePageState({
    required List<TItem> items,
    required int currentPage,
    required bool isLoading,
    required bool hasMore,
    String? error,
    PageResult<TItem>? result,
  });

  /// Map a fetch error to a user-facing message (defaults to the raw message
  /// of [AppException]s; override for host-specific labels).
  String pageErrorMessage(Object error) =>
      error is AppException ? error.message : 'Failed to load';

  /// Combine the existing list with an incoming page for load-more.
  /// Override to deduplicate overlapping ids.
  List<TItem> mergePageItems(List<TItem> existing, List<TItem> incoming) => [
    ...existing,
    ...incoming,
  ];

  /// Refresh (reset to page 1, replacing the list) or append the next page.
  Future<void> loadPage({bool refresh = false}) async {
    if (refresh) {
      // Invalidate any in-flight request so its response can't append stale
      // pages onto the refreshed list. Preserve existing items so a failed
      // refresh doesn't clear what was already shown.
      ++_pageGeneration;
      pageState = updatePageState(
        items: pageItems,
        currentPage: pageCurrentPage,
        isLoading: true,
        hasMore: pageHasMore,
      );
    } else if (pageIsLoading || !pageHasMore) {
      return;
    } else {
      pageState = updatePageState(
        items: pageItems,
        currentPage: pageCurrentPage,
        isLoading: true,
        hasMore: pageHasMore,
      );
    }

    final generation = _pageGeneration;
    try {
      final page = refresh ? 1 : pageCurrentPage;
      final result = await fetchPage(page);
      // Discard a stale response that raced a more recent refresh.
      if (!pageMounted || generation != _pageGeneration) return;

      final items = refresh
          ? mergePageItems(const [], result.items)
          : mergePageItems(pageItems, result.items);
      pageState = updatePageState(
        items: items,
        currentPage: page + 1,
        isLoading: false,
        hasMore: items.length < result.total,
        error: null,
        result: result,
      );
    } catch (e) {
      if (!pageMounted || generation != _pageGeneration) return;
      pageState = updatePageState(
        items: pageItems,
        currentPage: pageCurrentPage,
        isLoading: false,
        hasMore: pageHasMore,
        error: pageErrorMessage(e),
      );
    }
  }
}
