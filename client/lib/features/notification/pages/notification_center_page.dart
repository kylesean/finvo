import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:augo/i18n/strings.g.dart';
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notification.title),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(t.notification.markAllRead),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('${t.notification.loadFailed}: ${state.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => notifier.refresh(),
              child: Text(t.notification.retry),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  t.notification.empty,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            unawaited(notifier.deleteNotification(item.id));
          },
          child: _NotificationTile(
            item: item,
            onTap: () {
              if (!item.isRead) {
                unawaited(notifier.markAsRead(item.id));
              }
              _handleNavigation(context, item);
            },
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, NotificationItem item) {
    final data = item.data;
    if (data != null && data.containsKey('target_path')) {
      final targetPath = data['target_path'] as String;
      // If project uses go_router or navigator
      debugPrint('Navigate to notification target path: $targetPath');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !item.isRead;

    return ListTile(
      onTap: onTap,
      tileColor: isUnread
          ? theme.colorScheme.primary.withValues(alpha: 0.05)
          : null,
      leading: CircleAvatar(
        backgroundColor: _getTypeColor(item.type).withValues(alpha: 0.1),
        child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            _formatTime(item.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          item.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey[700]),
        ),
      ),
      trailing: isUnread
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'space_invite':
        return Icons.group_add;
      case 'bill_comment':
        return Icons.comment;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'space_invite':
        return Colors.blue;
      case 'bill_comment':
        return Colors.orange;
      case 'system':
      default:
        return Colors.teal;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return t.notification.justNow;
    } else if (difference.inHours < 1) {
      return t.notification.minutesAgo(minutes: difference.inMinutes);
    } else if (difference.inDays < 1) {
      return t.notification.hoursAgo(hours: difference.inHours);
    } else if (difference.inDays < 7) {
      return t.notification.daysAgo(days: difference.inDays);
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }
}
