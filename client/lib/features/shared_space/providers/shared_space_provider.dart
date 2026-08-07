import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';

part 'shared_space_provider.g.dart';

class SharedSpaceState {
  final List<SharedSpace> spaces;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const SharedSpaceState({
    this.spaces = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  SharedSpaceState copyWith({
    List<SharedSpace>? spaces,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return SharedSpaceState(
      spaces: spaces ?? this.spaces,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class SharedSpaceNotifier extends _$SharedSpaceNotifier {
  @override
  SharedSpaceState build() {
    return const SharedSpaceState();
  }

  Future<void> loadSpaces({bool refresh = false}) async {
    final service = ref.read(sharedSpaceServiceProvider);
    if (refresh) {
      // Preserve the existing list while refreshing so a failed refresh does
      // not wipe the previously loaded spaces (M2 fix).
      state = state.copyWith(isLoading: true, error: null);
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final response = await service.getSharedSpaces(page: page);

      final newSpaces = refresh
          ? response.spaces
          : [...state.spaces, ...response.spaces];
      final hasMore = newSpaces.length < response.total;

      state = state.copyWith(
        spaces: newSpaces,
        isLoading: false,
        error: null,
        currentPage: page + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      String errorMessage = 'Failed to load shared spaces';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<SharedSpace?> createSpace({
    required String name,
    String? description,
  }) async {
    final service = ref.read(sharedSpaceServiceProvider);
    try {
      final newSpace = await service.createSharedSpace(
        name: name,
        description: description,
      );

      state = state.copyWith(spaces: [newSpace, ...state.spaces]);

      return newSpace;
    } catch (e) {
      String errorMessage = 'Failed to create space';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
      return null;
    }
  }

  Future<SharedSpace?> joinSpaceWithCode(String inviteCode) async {
    final service = ref.read(sharedSpaceServiceProvider);
    try {
      final space = await service.joinSpaceWithCode(inviteCode);

      final existingIndex = state.spaces.indexWhere((s) => s.id == space.id);
      if (existingIndex == -1) {
        state = state.copyWith(spaces: [space, ...state.spaces]);
      } else {
        final updatedSpaces = [...state.spaces];
        updatedSpaces[existingIndex] = space;
        state = state.copyWith(spaces: updatedSpaces);
      }

      return space;
    } catch (e) {
      String errorMessage = 'Failed to join space';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
      return null;
    }
  }

  Future<bool> leaveSpace(String spaceId) async {
    final service = ref.read(sharedSpaceServiceProvider);
    try {
      await service.leaveSpace(spaceId);

      state = state.copyWith(
        spaces: state.spaces.where((space) => space.id != spaceId).toList(),
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to leave space';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  Future<bool> deleteSpace(String spaceId) async {
    final service = ref.read(sharedSpaceServiceProvider);
    try {
      await service.deleteSpace(spaceId);

      state = state.copyWith(
        spaces: state.spaces.where((space) => space.id != spaceId).toList(),
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete space';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  Future<bool> updateSpace(
    String spaceId, {
    String? name,
    String? description,
  }) async {
    final service = ref.read(sharedSpaceServiceProvider);
    try {
      final updatedSpace = await service.updateSpace(
        spaceId,
        name: name,
        description: description,
      );

      final updatedSpaces = state.spaces.map((space) {
        return space.id == spaceId ? updatedSpace : space;
      }).toList();

      state = state.copyWith(spaces: updatedSpaces);
      return true;
    } catch (e) {
      String errorMessage = 'Failed to update space';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

@riverpod
Future<SharedSpace> spaceDetail(Ref ref, String spaceId) async {
  final service = ref.watch(sharedSpaceServiceProvider);
  return service.getSharedSpaceDetail(spaceId);
}

@riverpod
Future<Settlement> spaceSettlement(Ref ref, String spaceId) async {
  final service = ref.watch(sharedSpaceServiceProvider);
  return service.getSpaceSettlement(spaceId);
}

/// Paginated state for a single space's transaction list.
class SpaceTransactionState {
  final List<SpaceTransaction> transactions;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final int total;

  const SpaceTransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.total = 0,
  });

  SpaceTransactionState copyWith({
    List<SpaceTransaction>? transactions,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? total,
  }) {
    return SpaceTransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

/// Paginated transaction list for a shared space.
///
/// Keyed by [spaceId] so each space keeps an independent, accumulated list.
/// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
/// so the detail page can drive infinite-scroll through its scroll controller.
@riverpod
class SpaceTransactionNotifier extends _$SpaceTransactionNotifier {
  static const _pageSize = 20;

  @override
  SpaceTransactionState build(String spaceId) {
    return const SpaceTransactionState();
  }

  /// Generation token guarding against stale pagination responses.
  /// Incremented on every refresh; a response whose captured generation no
  /// longer matches is discarded, so a refresh racing an in-flight loadMore
  /// can't append an old page onto the freshly reset page-1 list.
  int _loadGeneration = 0;

  SharedSpaceService get _service => ref.read(sharedSpaceServiceProvider);

  /// Load transactions with pagination.
  ///
  /// [refresh] resets to page 1 (replaces the accumulated list); otherwise the
  /// next page is appended. Overlapping ids from a refresh racing an in-flight
  /// load are collapsed so the list can't contain duplicates.
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      // Invalidate any in-flight request so its response can't append stale
      // pages onto the refreshed list. Preserve the existing transactions so a
      // failed refresh doesn't clear what was already shown (M2 fix).
      ++_loadGeneration;
      state = state.copyWith(isLoading: true, error: null);
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final generation = _loadGeneration;
    try {
      final page = refresh ? 1 : state.currentPage;
      final res = await _service.getSpaceTransactions(
        spaceId,
        page: page,
        limit: _pageSize,
      );
      // Discard a stale response that raced a more recent refresh.
      if (generation != _loadGeneration) return;

      final newTransactions = refresh
          ? res.transactions
          : _appendUnique(state.transactions, res.transactions);
      final hasMore = newTransactions.length < res.total;

      state = state.copyWith(
        transactions: newTransactions,
        isLoading: false,
        error: null,
        currentPage: page + 1,
        hasMore: hasMore,
        total: res.total,
      );
    } catch (e) {
      if (generation != _loadGeneration) return;
      String errorMessage = 'Failed to load space transactions';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Load the next page (no-op when already loading or exhausted).
  Future<void> loadMore() => loadTransactions();

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Append [incoming] to [existing], skipping ids already present.
  List<SpaceTransaction> _appendUnique(
    List<SpaceTransaction> existing,
    List<SpaceTransaction> incoming,
  ) {
    final existingIds = existing.map((t) => t.id).toSet();
    return [...existing, ...incoming.where((t) => !existingIds.contains(t.id))];
  }
}
