import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/services/notification_ws_service.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/core/constants/api_constants.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/home/providers/comment_providers.dart';
import 'package:finvo/features/notification/models/notification_item.dart';
import 'package:finvo/features/notification/repositories/notification_repository.dart';
import 'package:finvo/features/notification/utils/notification_crud_mixin.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'package:finvo/shared/utils/error_message.dart';

part 'notification_provider.freezed.dart';
part 'notification_provider.g.dart';

final _logger = Logger('NotificationNotifier');

/// State object for Notifications feature
@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<NotificationItem> items,
    @Default(0) int total,
    @Default(0) int unreadCount,
    @Default(1) int currentPage,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedMax,
    String? error,
  }) = _NotificationState;
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return NotificationRepository(networkClient);
}

/// Notification State Notifier Provider
@Riverpod(keepAlive: true)
class NotificationNotifier extends _$NotificationNotifier
    with NotificationCrudMixin<NotificationItem, NotificationState> {
  static const _pageSize = 20;

  @override
  NotificationState build() {
    // Automatically trigger initial load on provider creation
    unawaited(Future.microtask(() => refresh()));
    return const NotificationState(isLoading: true);
  }

  /// Reset to the pristine state on logout / session expiry so the next
  /// account never sees the previous one's notifications or unread badge.
  /// The keepAlive provider would otherwise hold the stale list forever.
  void resetState() {
    _loadGeneration++;
    state = const NotificationState();
  }

  /// Refresh notification list (resets to page 1)
  /// Monotonic epoch guarding refresh vs loadMore races: a loadMore response
  /// that returns after a refresh must not append its stale page onto the
  /// freshly reset list.
  int _loadGeneration = 0;

  Future<void> refresh() async {
    // Invalidate any in-flight loadMore so its response is discarded.
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final res = await repository
          .getNotifications(page: 1, limit: _pageSize)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Notification request timed out'),
          );
      if (generation != _loadGeneration) return;
      state = state.copyWith(
        items: res.items,
        total: res.total,
        unreadCount: res.unreadCount,
        currentPage: 1,
        isLoading: false,
        hasReachedMax: res.items.length < _pageSize,
      );
    } catch (e) {
      if (generation != _loadGeneration) return;
      _logger.severe('Failed to refresh notifications', e);
      state = state.copyWith(isLoading: false, error: safeErrorMessage(e));
    }
  }

  /// Load more notifications (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax || state.isLoading) return;

    final generation = _loadGeneration;
    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final res = await repository.getNotifications(
        page: nextPage,
        limit: _pageSize,
      );

      // A refresh started while this request was in flight supersedes it.
      // Reset the loading flag first: the superseding refresh() does not
      // touch isLoadingMore, so without this the infinite scroll would stay
      // disabled forever.
      if (generation != _loadGeneration) {
        state = state.copyWith(isLoadingMore: false);
        return;
      }
      state = state.copyWith(
        items: [...state.items, ...res.items],
        total: res.total,
        unreadCount: res.unreadCount,
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedMax: res.items.length < _pageSize,
      );
    } catch (e) {
      if (generation != _loadGeneration) {
        state = state.copyWith(isLoadingMore: false);
        return;
      }
      _logger.warning('Failed to load more notifications', e);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ============================================================
  // NotificationCrudMixin accessors
  // ============================================================

  @override
  NotificationState get notificationState => state;

  @override
  set notificationState(NotificationState value) => state = value;

  @override
  List<NotificationItem> get notificationItems => state.items;

  @override
  int get notificationUnreadCount => state.unreadCount;

  @override
  int? get notificationTotal => state.total;

  @override
  NotificationState updateNotificationState(
    List<NotificationItem> items, {
    int? unreadCount,
    int? total,
  }) => state.copyWith(
    items: items,
    unreadCount: unreadCount ?? state.unreadCount,
    total: total ?? state.total,
  );

  @override
  String notificationIdOf(NotificationItem item) => item.id;

  @override
  bool notificationIsReadOf(NotificationItem item) => item.isRead;

  @override
  NotificationItem notificationMarkRead(
    NotificationItem item, {
    required DateTime readAt,
  }) => item.copyWith(isRead: true, readAt: readAt);

  @override
  NotificationItem notificationMarkAllRead(NotificationItem item) =>
      // Preserve the original bulk-mark behavior: `readAt` is not stamped.
      item.copyWith(isRead: true);

  @override
  Future<bool> markNotificationReadRemote(String id) async =>
      ref.read(notificationRepositoryProvider).markAsRead(id);

  @override
  Future<bool> markAllNotificationsReadRemote() async =>
      ref.read(notificationRepositoryProvider).markAllAsRead();

  @override
  Future<bool> deleteNotificationRemote(String id) async =>
      ref.read(notificationRepositoryProvider).deleteNotification(id);

  int _realtimeNotificationSeq = 0;

  /// Add a real-time notification received via WebSocket.
  ///
  /// Deduplicates by ID: the same notification can arrive both via the
  /// WebSocket push and via the next list refresh — adding it twice would
  /// duplicate the row and double-count total/unread. Existing entries are
  /// replaced in place (so an unread WS entry is upgraded to the read state
  /// once a refresh reports it read).
  void addRealtimeNotification(NotificationItem item) {
    final existingIndex = state.items.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      final items = [...state.items];
      final wasRead = items[existingIndex].isRead;
      items[existingIndex] = item;
      // NTF-5: keep the badge in sync — a late unread push replacing a READ
      // entry is a newly-unread notification and must bump the count; the
      // old code replaced the row but left unreadCount stale.
      if (wasRead && !item.isRead) {
        state = state.copyWith(
          items: items,
          unreadCount: state.unreadCount + 1,
        );
      } else {
        state = state.copyWith(items: items);
      }
      return;
    }

    // A synthetic rt_ entry (WS payload without a server id) may later be
    // superseded by the server's real notification, which carries the real
    // id in data['id']. Replace it without double-counting.
    if (!item.id.startsWith('rt_')) {
      final staleRtIndex = state.items.indexWhere(
        (i) => i.id.startsWith('rt_') && i.data?['id']?.toString() == item.id,
      );
      if (staleRtIndex != -1) {
        final items = [...state.items];
        items[staleRtIndex] = item;
        state = state.copyWith(items: items);
        return;
      }
    }

    state = state.copyWith(
      items: [item, ...state.items],
      total: state.total + 1,
      unreadCount: state.unreadCount + 1,
    );
  }

  /// Construct and add a real-time notification from WebSocket payload.
  void addRealtimeNotificationFromPayload(
    Map<String, dynamic> payload,
    String type,
  ) {
    final serverId =
        payload['id']?.toString() ?? payload['data']?['id']?.toString();
    final item = NotificationItem(
      id: (serverId != null && serverId.isNotEmpty)
          ? serverId
          : 'rt_${DateTime.now().millisecondsSinceEpoch}_${_realtimeNotificationSeq++}',
      userId: '',
      type: type,
      title: payload['title']?.toString() ?? '',
      message: payload['message']?.toString() ?? '',
      data: payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : null,
      isRead: false,
      createdAt: DateTime.now(),
    );
    addRealtimeNotification(item);
  }
}

/// WebSocket service provider for real-time notifications.
///
/// Initializes connection on first read and wires incoming
/// notifications to the central NotificationNotifier.
///
/// Marked [keepAlive] so the long-lived WebSocket connection is not torn down
/// when the widget that reads it (MyApp) stops listening. A plain auto-dispose
/// provider would dispose the connection (and trigger `onDispose`) as soon as
/// the build frame that read it completes.
@Riverpod(keepAlive: true)
NotificationWsService notificationWs(Ref ref) {
  final wsService = NotificationWsService();
  final storageService = ref.read(secureStorageServiceProvider);

  // Watch the auth STATUS so the connection lifecycle tracks login state.
  //
  // `notificationWs` is keepAlive and typically first instantiated by MyApp
  // at startup — before login, when no token exists. Without listening to the
  // auth status here, the WS would silently skip connecting and never recover
  // after a successful login (it was only invalidated on server switch).
  // Watching `authStatusProvider` rebuilds this provider when the session
  // flips to/from authenticated, tearing down the old service (onDispose) and
  // re-running `connect()` with the freshly stored token.
  //
  // NOTE: we deliberately watch STATUS and not the token value (NTF-3): the
  // auth interceptor rotates the access token on every 401 refresh, and a
  // token watch would rebuild (tear down + reconnect) a perfectly healthy WS
  // connection each time — losing notifications in the reconnect window. The
  // WS authenticates once at handshake; a rotated token needs no reconnect.
  ref.watch(authStatusProvider);

  // Wire incoming notifications to the provider
  wsService.onNotification = (payload) {
    final type = payload['type']?.toString() ?? 'system';

    if (type == 'comment_updated' || type == 'bill_comment') {
      final dataMap = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : null;
      final transactionId =
          (dataMap?['transactionId'] ?? dataMap?['transaction_id'])?.toString();
      if (transactionId != null && transactionId.isNotEmpty) {
        ref.invalidate(transactionCommentsProvider(transactionId));
      }
      if (type == 'comment_updated') return;
    }

    // A member left / was removed from a space: refresh the space detail (its
    // member list) and the space list so open UIs drop the member immediately
    // instead of showing a stale member (M-23).
    if (type == 'member_left') {
      final dataMap = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : null;
      final spaceId = (dataMap?['space_id'] ?? dataMap?['spaceId'])?.toString();
      if (spaceId != null && spaceId.isNotEmpty) {
        ref.invalidate(spaceDetailProvider(spaceId));
        ref.invalidate(sharedSpaceProvider);
      }
    }

    ref
        .read(notificationProvider.notifier)
        .addRealtimeNotificationFromPayload(payload, type);
  };

  // Connect
  unawaited(
    wsService.connect(
      baseUrl: ref.read(apiBaseUrlProvider),
      storageService: storageService,
    ),
  );

  // Dispose on provider disposal
  ref.onDispose(() => wsService.dispose());

  return wsService;
}
