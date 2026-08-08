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
import 'package:finvo/features/notification/utils/notification_list_mutations.dart';
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
class NotificationNotifier extends _$NotificationNotifier {
  static const _pageSize = 20;

  @override
  NotificationState build() {
    // Automatically trigger initial load on provider creation
    unawaited(Future.microtask(() => refresh()));
    return const NotificationState(isLoading: true);
  }

  /// Refresh notification list (resets to page 1)
  Future<void> refresh() async {
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
      state = state.copyWith(
        items: res.items,
        total: res.total,
        unreadCount: res.unreadCount,
        currentPage: 1,
        isLoading: false,
        hasReachedMax: res.items.length < _pageSize,
      );
    } catch (e) {
      _logger.severe('Failed to refresh notifications', e);
      state = state.copyWith(isLoading: false, error: safeErrorMessage(e));
    }
  }

  /// Load more notifications (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final res = await repository.getNotifications(
        page: nextPage,
        limit: _pageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...res.items],
        total: res.total,
        unreadCount: res.unreadCount,
        currentPage: nextPage,
        isLoadingMore: false,
        hasReachedMax: res.items.length < _pageSize,
      );
    } catch (e) {
      _logger.warning('Failed to load more notifications', e);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.markAsRead(id);
    if (!success) {
      // Failure is deliberately silent at the UI level (the item just stays
      // unread), but log it so repeat failures are diagnosable.
      _logger.warning('markAsRead failed for notification $id');
      return;
    }
    final result = NotificationListMutations.markAsRead(
      items: state.items,
      unreadCount: state.unreadCount,
      id: id,
      idOf: (item) => item.id,
      isReadOf: (item) => item.isRead,
      withReadAt: (item) => item.copyWith(isRead: true, readAt: DateTime.now()),
    );
    state = state.copyWith(
      items: result.items,
      unreadCount: result.unreadCount,
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.markAllAsRead();
    if (!success) {
      _logger.warning('markAllAsRead failed');
      return;
    }
    final result = NotificationListMutations.markAllAsRead(
      items: state.items,
      withRead: (item) => item.copyWith(isRead: true),
    );
    state = state.copyWith(
      items: result.items,
      unreadCount: result.unreadCount,
    );
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    // Safe lookup - return early if item not found
    final itemToDelete = state.items.where((item) => item.id == id).firstOrNull;
    if (itemToDelete == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.deleteNotification(id);
    if (!success) {
      _logger.warning('deleteNotification failed for notification $id');
      return;
    }
    final result = NotificationListMutations.delete(
      items: state.items,
      unreadCount: state.unreadCount,
      id: id,
      idOf: (item) => item.id,
      isReadOf: (item) => item.isRead,
    );
    state = state.copyWith(
      items: result.items,
      total: (state.total - 1).clamp(0, 9999),
      unreadCount: result.unreadCount,
    );
  }

  int _realtimeNotificationSeq = 0;

  /// Add a real-time notification received via WebSocket.
  void addRealtimeNotification(NotificationItem item) {
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
    final item = NotificationItem(
      id: 'rt_${DateTime.now().millisecondsSinceEpoch}_${_realtimeNotificationSeq++}',
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

  // Watch the auth token so the connection lifecycle tracks login state.
  //
  // `notificationWs` is keepAlive and typically first instantiated by MyApp
  // at startup — before login, when no token exists. Without listening to the
  // token here, the WS would silently skip connecting and never recover after
  // a successful login (it was only invalidated on server switch). Watching
  // `authTokenProvider` rebuilds this provider when the token flips to/from
  // null, tearing down the old service (onDispose) and re-running `connect()`
  // with the freshly stored token.
  ref.watch(authTokenProvider);

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
