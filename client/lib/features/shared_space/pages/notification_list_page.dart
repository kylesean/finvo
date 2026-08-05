import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/providers/notification_provider.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'package:finvo/features/shared_space/widgets/notification_card.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/shared/services/toast_service.dart';

class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(sharedSpaceNotificationProvider.notifier)
            .loadNotifications(refresh: true),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(
        ref.read(sharedSpaceNotificationProvider.notifier).loadNotifications(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(sharedSpaceNotificationProvider);

    ref.listen<String?>(
      sharedSpaceNotificationProvider.select((state) => state.error),
      (previous, error) {
        if (error != null) {
          ToastService.showDestructive(description: Text(error));
          ref.read(sharedSpaceNotificationProvider.notifier).clearError();
        }
      },
    );

    return FScaffold(
      header: FHeader(
        title: Text(
          t.sharedSpace.notifications.title,
          style: theme.typography.body.xl.copyWith(color: colors.foreground),
        ),
        suffixes: [
          if (state.unreadCount > 0)
            FHeaderAction(
              icon: const Icon(FLucideIcons.checkCheck),
              onPress: _markAllAsRead,
            ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(sharedSpaceNotificationProvider.notifier)
              .loadNotifications(refresh: true);
        },
        child: state.notifications.isEmpty && !state.isLoading
            ? _buildEmptyState(context)
            : _buildNotificationsList(context, state),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                FLucideIcons.bell,
                size: 40,
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.sharedSpace.notifications.empty,
              style: theme.typography.body.xl.copyWith(
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.sharedSpace.notifications.emptyHint,
              style: theme.typography.body.md.copyWith(
                color: colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    SharedSpaceNotificationState state,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          // Loading indicator
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = state.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onAccept: notification.type == NotificationType.spaceInvite
                ? () => _handleInviteResponse(notification, 'accept')
                : null,
            onReject: notification.type == NotificationType.spaceInvite
                ? () => _handleInviteResponse(notification, 'reject')
                : null,
            onDelete: () => _deleteNotification(notification.id),
          ),
        );
      },
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      unawaited(
        ref
            .read(sharedSpaceNotificationProvider.notifier)
            .markAsRead(notification.id),
      );
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.spaceInvite:
        // Invite notification, no extra navigation, user can act directly on card
        break;
      case NotificationType.newTransaction:
      case NotificationType.billComment:
        // Transaction/comment notification, navigate to transaction detail
        final transactionId =
            (notification.data?['transactionId'] ??
                    notification.data?['transaction_id'])
                as String?;
        final commentId =
            (notification.data?['commentId'] ??
                    notification.data?['comment_id'])
                as String?;
        if (transactionId != null) {
          final path = commentId != null && commentId.isNotEmpty
              ? '/home/transaction/$transactionId?commentId=$commentId'
              : '/home/transaction/$transactionId';
          unawaited(context.push(path));
        }
        break;
      case NotificationType.settlementUpdate:
        // Settlement update notification, navigate to space detail
        final spaceId = notification.data?['spaceId'] as String?;
        if (spaceId != null) {
          unawaited(context.push('/profile/shared-space/$spaceId'));
        }
        break;
      case NotificationType.memberJoined:
      case NotificationType.memberLeft:
        // Member change notification, navigate to space settings
        final spaceId = notification.data?['spaceId'] as String?;
        if (spaceId != null) {
          unawaited(context.push('/profile/shared-space/$spaceId/settings'));
        }
        break;
      case NotificationType.other:
        // Unknown notification type; no dedicated navigation.
        break;
    }
  }

  Future<void> _handleInviteResponse(
    NotificationModel notification,
    String action,
  ) async {
    final spaceId = notification.data?['spaceId'] as String?;
    if (spaceId == null) {
      ToastService.showDestructive(
        description: Text(t.sharedSpace.notifications.incompleteInfo),
      );
      return;
    }

    final success = await ref
        .read(sharedSpaceNotificationProvider.notifier)
        .respondToSpaceInvite(spaceId, action, notification.id);

    if (success) {
      if (action == 'accept') {
        ToastService.show(
          description: Text(t.sharedSpace.notifications.inviteAccepted),
        );

        // Refresh shared space list
        unawaited(
          ref.read(sharedSpaceProvider.notifier).loadSpaces(refresh: true),
        );

        // Navigate to space detail
        if (mounted) {
          unawaited(context.push('/profile/shared-space/$spaceId'));
        }
      } else {
        ToastService.show(
          description: Text(t.sharedSpace.notifications.inviteRejected),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    await ref
        .read(sharedSpaceNotificationProvider.notifier)
        .deleteNotification(notificationId);
  }

  Future<void> _markAllAsRead() async {
    await ref.read(sharedSpaceNotificationProvider.notifier).markAllAsRead();
    ToastService.show(
      description: Text(t.sharedSpace.notifications.allMarkedRead),
    );
  }
}
