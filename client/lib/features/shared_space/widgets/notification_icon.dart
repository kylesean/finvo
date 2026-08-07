import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/app/router/app_routes.dart';
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
          Icon(FLucideIcons.bell, color: colors.primaryForeground, size: 20),
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

  void _navigateToNotifications(BuildContext context) {
    unawaited(context.pushNamed(AppRouteNames.notifications));
  }
}
