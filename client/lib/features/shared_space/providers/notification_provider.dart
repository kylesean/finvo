import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/exceptions/app_exception.dart';
import '../../notification/repositories/notification_repository.dart';
import '../../notification/providers/notification_provider.dart';
import '../models/shared_space_models.dart';

part 'notification_provider.g.dart';

final _logger = Logger('SharedSpaceNotification');

/// Shared-space notification state (uses NotificationModel for space-specific UI)
class SharedSpaceNotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;

  const SharedSpaceNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = true,
  });

  SharedSpaceNotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
  }) {
    return SharedSpaceNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Shared-space notification provider.
///
/// Delegates generic notification CRUD to the central NotificationRepository.
/// Only adds space-specific logic (respondToSpaceInvite).
@riverpod
class SharedSpaceNotification extends _$SharedSpaceNotification {
  static const _pageSize = 20;

  @override
  SharedSpaceNotificationState build() {
    return const SharedSpaceNotificationState();
  }

  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  /// Load notifications with pagination
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = const SharedSpaceNotificationState(isLoading: true);
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final res = await _repository.getNotifications(
        page: page,
        limit: _pageSize,
      );

      // Map central NotificationItem -> shared_space NotificationModel
      final mapped = res.items
          .map(
            (item) => NotificationModel(
              id: item.id,
              userId: item.userId,
              type: _mapNotificationType(item.type),
              title: item.title,
              message: item.message,
              data: item.data,
              isRead: item.isRead,
              createdAt: item.createdAt,
              readAt: item.readAt,
            ),
          )
          .toList();

      final newNotifications = refresh
          ? mapped
          : [...state.notifications, ...mapped];
      final hasMore = res.items.length >= _pageSize;

      state = state.copyWith(
        notifications: newNotifications,
        isLoading: false,
        error: null,
        unreadCount: res.unreadCount,
        currentPage: page + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      _logger.severe('Failed to load notifications', e);
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : 'Failed to load notifications',
      );
    }
  }

  /// Load unread count (syncs with central provider)
  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      _logger.warning('Failed to load unread count', e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      final updated = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;
      state = state.copyWith(
        notifications: updated,
        unreadCount: newUnreadCount,
      );
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final success = await _repository.markAllAsRead();
    if (success) {
      final updated = state.notifications
          .map(
            (n) =>
                n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()),
          )
          .toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final item = state.notifications
        .where((n) => n.id == notificationId)
        .firstOrNull;
    if (item == null) return;

    final success = await _repository.deleteNotification(notificationId);
    if (success) {
      final updated = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      final newUnreadCount = !item.isRead && state.unreadCount > 0
          ? state.unreadCount - 1
          : state.unreadCount;
      state = state.copyWith(
        notifications: updated,
        unreadCount: newUnreadCount,
      );
    }
  }

  /// Respond to a space invite (space-specific action)
  Future<bool> respondToSpaceInvite(
    String spaceId,
    String action,
    String notificationId,
  ) async {
    try {
      final dio = ref.read(dioProvider);
      final networkClient = NetworkClient(dio);
      await networkClient.request<void>(
        '/shared-spaces/$spaceId/invites/respond',
        method: HttpMethod.put,
        data: {'action': action},
      );

      if (action == 'reject') {
        await deleteNotification(notificationId);
      } else {
        await markAsRead(notificationId);
      }
      return true;
    } catch (e) {
      _logger.severe('Failed to respond to invite', e);
      state = state.copyWith(
        error: e is AppException ? e.message : 'Failed to respond to invite',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Map string type to shared_space NotificationType enum
  NotificationType _mapNotificationType(String type) {
    return switch (type) {
      'space_invite' => NotificationType.spaceInvite,
      'new_transaction' || 'transaction' => NotificationType.newTransaction,
      'bill_comment' => NotificationType.billComment,
      'settlement_update' => NotificationType.settlementUpdate,
      'member_joined' || 'space_activity' => NotificationType.memberJoined,
      'member_left' => NotificationType.memberLeft,
      _ => NotificationType.spaceInvite,
    };
  }
}

/// Unread count derived from central notification provider
@riverpod
int sharedSpaceUnreadCount(Ref ref) {
  return ref.watch(notificationProvider).unreadCount;
}
