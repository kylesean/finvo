import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/shared/widgets/app_card.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/utils/time_utils.dart';

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
                                style: AppTextStyles.listTitle(theme).copyWith(
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
                    style: AppTextStyles.listSubtitle(theme),
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
                        child: Text(t.sharedSpace.notificationCard.reject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FButton(
                        onPress: onAccept,
                        child: Text(t.sharedSpace.notificationCard.accept),
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
      case NotificationType.billComment:
        return FLucideIcons.messageSquareText;
      case NotificationType.settlementUpdate:
        return FLucideIcons.calculator;
      case NotificationType.memberJoined:
        return FLucideIcons.userCheck;
      case NotificationType.memberLeft:
        return FLucideIcons.userMinus;
      case NotificationType.other:
        return FLucideIcons.bell;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.spaceInvite:
        return Colors.blue;
      case NotificationType.newTransaction:
        return Colors.green;
      case NotificationType.billComment:
        return Colors.indigo;
      case NotificationType.settlementUpdate:
        return Colors.orange;
      case NotificationType.memberJoined:
        return Colors.teal;
      case NotificationType.memberLeft:
        return Colors.red;
      case NotificationType.other:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return t.sharedSpace.notificationCard.unknownTime;
    return relativeTime(dateTime);
  }
}
