import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';
import 'package:finvo/shared/providers/paginated_list_mixin.dart';

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
class SharedSpaceNotifier extends _$SharedSpaceNotifier
    with PaginatedListMixin<SharedSpace, SharedSpaceState> {
  @override
  SharedSpaceState build() {
    return const SharedSpaceState();
  }

  Future<void> loadSpaces({bool refresh = false}) => loadPage(refresh: refresh);

  // ============================================================
  // PaginatedListMixin accessors
  // ============================================================

  @override
  bool get pageMounted => ref.mounted;

  @override
  SharedSpaceState get pageState => state;

  @override
  set pageState(SharedSpaceState value) => state = value;

  @override
  List<SharedSpace> get pageItems => state.spaces;

  @override
  bool get pageIsLoading => state.isLoading;

  @override
  bool get pageHasMore => state.hasMore;

  @override
  int get pageCurrentPage => state.currentPage;

  @override
  Future<PageResult<SharedSpace>> fetchPage(int page) async {
    final response = await ref
        .read(sharedSpaceServiceProvider)
        .getSharedSpaces(page: page);
    return PageResult(items: response.spaces, total: response.total);
  }

  @override
  SharedSpaceState updatePageState({
    required List<SharedSpace> items,
    required int currentPage,
    required bool isLoading,
    required bool hasMore,
    String? error,
    PageResult<SharedSpace>? result,
  }) => state.copyWith(
    spaces: items,
    currentPage: currentPage,
    isLoading: isLoading,
    hasMore: hasMore,
    error: error,
  );

  @override
  String pageErrorMessage(Object error) =>
      error is AppException ? error.message : 'Failed to load shared spaces';

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
class SpaceTransactionNotifier extends _$SpaceTransactionNotifier
    with PaginatedListMixin<SpaceTransaction, SpaceTransactionState> {
  static const _pageSize = 20;

  late String _spaceId;

  @override
  SpaceTransactionState build(String spaceId) {
    _spaceId = spaceId;
    return const SpaceTransactionState();
  }

  SharedSpaceService get _service => ref.read(sharedSpaceServiceProvider);

  /// Load transactions with pagination (delegated to [PaginatedListMixin]).
  ///
  /// [refresh] resets to page 1 (replaces the accumulated list); otherwise the
  /// next page is appended. Overlapping ids from a refresh racing an in-flight
  /// load are collapsed so the list can't contain duplicates.
  Future<void> loadTransactions({bool refresh = false}) =>
      loadPage(refresh: refresh);

  /// Load the next page (no-op when already loading or exhausted).
  Future<void> loadMore() => loadPage();

  void clearError() {
    state = state.copyWith(error: null);
  }

  // ============================================================
  // PaginatedListMixin accessors
  // ============================================================

  @override
  bool get pageMounted => ref.mounted;

  @override
  SpaceTransactionState get pageState => state;

  @override
  set pageState(SpaceTransactionState value) => state = value;

  @override
  List<SpaceTransaction> get pageItems => state.transactions;

  @override
  bool get pageIsLoading => state.isLoading;

  @override
  bool get pageHasMore => state.hasMore;

  @override
  int get pageCurrentPage => state.currentPage;

  @override
  Future<PageResult<SpaceTransaction>> fetchPage(int page) async {
    final res = await _service.getSpaceTransactions(
      _spaceId,
      page: page,
      limit: _pageSize,
    );
    return PageResult(items: res.transactions, total: res.total);
  }

  @override
  SpaceTransactionState updatePageState({
    required List<SpaceTransaction> items,
    required int currentPage,
    required bool isLoading,
    required bool hasMore,
    String? error,
    PageResult<SpaceTransaction>? result,
  }) => state.copyWith(
    transactions: items,
    currentPage: currentPage,
    isLoading: isLoading,
    hasMore: hasMore,
    error: error,
    total: result?.total ?? state.total,
  );

  @override
  String pageErrorMessage(Object error) => error is AppException
      ? error.message
      : 'Failed to load space transactions';

  @override
  List<SpaceTransaction> mergePageItems(
    List<SpaceTransaction> existing,
    List<SpaceTransaction> incoming,
  ) {
    // Overlapping ids from a refresh racing an in-flight load are collapsed
    // so the list can't contain duplicates.
    final existingIds = existing.map((t) => t.id).toSet();
    return [...existing, ...incoming.where((t) => !existingIds.contains(t.id))];
  }
}
