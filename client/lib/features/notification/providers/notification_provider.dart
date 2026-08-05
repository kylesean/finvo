import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import '../../../core/network/network_client.dart';
import '../../../core/services/notification_ws_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/providers/comment_providers.dart';
import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';

part 'notification_provider.g.dart';

final _logger = Logger('NotificationNotifier');

/// State object for Notifications feature
class NotificationState {
  final List<NotificationItem> items;
  final int total;
  final int unreadCount;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? error;

  const NotificationState({
    this.items = const [],
    this.total = 0,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationItem>? items,
    int? total,
    int? unreadCount,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
  }) {
    return NotificationState(
      items: items ?? this.items,
      total: total ?? this.total,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error,
    );
  }
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return NotificationRepository(networkClient);
}

/// Notification State Notifier Provider
@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  static const _pageSize = 20;

  @override
  NotificationState build() {
    // Trigger initial load asynchronously
    unawaited(Future<void>.microtask(() => unawaited(refresh())));
    return const NotificationState();
  }

  /// Refresh notification list (resets to page 1)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final res = await repository.getNotifications(page: 1, limit: _pageSize);
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
      state = state.copyWith(isLoading: false, error: e.toString());
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
    if (success) {
      final updatedItems = state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true, readAt: DateTime.now());
        }
        return item;
      }).toList();

      final newUnreadCount = (state.unreadCount - 1).clamp(0, 999);
      state = state.copyWith(items: updatedItems, unreadCount: newUnreadCount);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.markAllAsRead();
    if (success) {
      final updatedItems = state.items
          .map((item) => item.copyWith(isRead: true))
          .toList();
      state = state.copyWith(items: updatedItems, unreadCount: 0);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    // Safe lookup - return early if item not found
    final itemToDelete = state.items.where((item) => item.id == id).firstOrNull;
    if (itemToDelete == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.deleteNotification(id);
    if (success) {
      final updatedItems = state.items.where((item) => item.id != id).toList();
      final newUnreadCount = !itemToDelete.isRead
          ? (state.unreadCount - 1).clamp(0, 999)
          : state.unreadCount;
      state = state.copyWith(
        items: updatedItems,
        total: (state.total - 1).clamp(0, 9999),
        unreadCount: newUnreadCount,
      );
    }
  }

  /// Add a real-time notification received via WebSocket.
  void addRealtimeNotification(NotificationItem item) {
    state = state.copyWith(
      items: [item, ...state.items],
      total: state.total + 1,
      unreadCount: state.unreadCount + 1,
    );
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
  final apiConstants = ref.read(apiConstantsProvider);
  final storageService = ref.read(secureStorageServiceProvider);

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

    final item = NotificationItem(
      id: 'rt_${DateTime.now().millisecondsSinceEpoch}',
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
    ref.read(notificationProvider.notifier).addRealtimeNotification(item);
  };

  // Connect
  unawaited(
    wsService.connect(
      baseUrl: apiConstants.baseUrl,
      storageService: storageService,
    ),
  );

  // Dispose on provider disposal
  ref.onDispose(() => wsService.dispose());

  return wsService;
}
