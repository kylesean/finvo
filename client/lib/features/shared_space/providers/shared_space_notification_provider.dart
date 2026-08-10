import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/notification/repositories/notification_repository.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/features/notification/utils/notification_crud_mixin.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';

part 'shared_space_notification_provider.g.dart';

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
class SharedSpaceNotification extends _$SharedSpaceNotification
    with
        NotificationCrudMixin<NotificationModel, SharedSpaceNotificationState> {
  static const _pageSize = 20;

  // ============================================================
  // NotificationCrudMixin accessors
  // ============================================================

  @override
  SharedSpaceNotificationState get notificationState => state;

  @override
  set notificationState(SharedSpaceNotificationState value) => state = value;

  @override
  List<NotificationModel> get notificationItems => state.notifications;

  @override
  int get notificationUnreadCount => state.unreadCount;

  @override
  int? get notificationTotal => null;

  @override
  SharedSpaceNotificationState updateNotificationState(
    List<NotificationModel> items, {
    int? unreadCount,
    int? total,
  }) => state.copyWith(notifications: items, unreadCount: unreadCount);

  @override
  String notificationIdOf(NotificationModel item) => item.id;

  @override
  bool notificationIsReadOf(NotificationModel item) => item.isRead;

  @override
  NotificationModel notificationMarkRead(
    NotificationModel item, {
    required DateTime readAt,
  }) => item.isRead ? item : item.copyWith(isRead: true, readAt: readAt);

  @override
  Future<bool> markNotificationReadRemote(String id) async =>
      _repository.markAsRead(id);

  @override
  Future<bool> markAllNotificationsReadRemote() async =>
      _repository.markAllAsRead();

  @override
  Future<bool> deleteNotificationRemote(String id) async =>
      _repository.deleteNotification(id);

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

  /// Respond to a space invite (space-specific action)
  Future<bool> respondToSpaceInvite(
    String spaceId,
    String action,
    String notificationId,
  ) async {
    try {
      final networkClient = ref.read(networkClientProvider);
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
      _ => NotificationType.other,
    };
  }
}
