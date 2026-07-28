import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import '../providers/notification_provider.dart';

/// Unified notification bell icon with unread count badge.
///
/// Uses Forui theme system. Badge shows unread count (smaller style).
class NotificationBadgeIcon extends ConsumerWidget {
  final double iconSize;

  const NotificationBadgeIcon({super.key, this.iconSize = 20.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;

    return FButton.icon(
      variant: .ghost,
      onPress: () => unawaited(context.push('/notifications')),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(FLucideIcons.bell, color: colors.foreground, size: iconSize),
          if (unreadCount > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 14),
                height: 14,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: colors.destructive,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
