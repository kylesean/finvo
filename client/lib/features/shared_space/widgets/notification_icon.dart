import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import '../../notification/providers/notification_provider.dart';
import 'dart:async';

class NotificationIcon extends ConsumerWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final unreadCount = ref.watch(notificationProvider).unreadCount;

    return FButton.icon(
      variant: .ghost,
      onPress: () => _navigateToNotifications(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(FLucideIcons.bell, color: colors.foreground, size: 20),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors.destructive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: theme.typography.body.xs.copyWith(
                      color: colors.destructiveForeground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    unawaited(context.push('/notifications'));
  }
}
