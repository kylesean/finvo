import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/shared_space_models.dart';
import '../../../shared/widgets/app_card.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon, title and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      size: 20,
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.typography.body.md.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: notification.isRead
                                      ? colors.mutedForeground
                                      : colors.foreground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: theme.typography.body.sm.copyWith(
                            color: notification.isRead
                                ? colors.mutedForeground
                                : colors.foreground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  if (onDelete != null)
                    FButton(
                      variant: .ghost,
                      onPress: onDelete,
                      child: Icon(
                        FLucideIcons.x,
                        size: 16,
                        color: colors.mutedForeground,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Time
              Row(
                children: [
                  Icon(
                    FLucideIcons.clock,
                    size: 14,
                    color: colors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: theme.typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),

              // Invite action buttons
              if (notification.type == NotificationType.spaceInvite &&
                  onAccept != null &&
                  onReject != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: .outline,
                        onPress: onReject,
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FButton(
                        onPress: onAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.spaceInvite:
        return FLucideIcons.userPlus;
      case NotificationType.newTransaction:
        return FLucideIcons.receipt;
      case NotificationType.settlementUpdate:
        return FLucideIcons.calculator;
      case NotificationType.memberJoined:
        return FLucideIcons.userCheck;
      case NotificationType.memberLeft:
        return FLucideIcons.userMinus;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.spaceInvite:
        return Colors.blue;
      case NotificationType.newTransaction:
        return Colors.green;
      case NotificationType.settlementUpdate:
        return Colors.orange;
      case NotificationType.memberJoined:
        return Colors.teal;
      case NotificationType.memberLeft:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown time';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
