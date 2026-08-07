import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/features/notification/models/notification_item.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState
    extends ConsumerState<NotificationCenterPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(ref.read(notificationProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(t.notification.title, style: theme.typography.body.xl),
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: true,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            FButton.icon(
              variant: .ghost,
              onPress: () => notifier.markAllAsRead(),
              child: const Icon(FLucideIcons.checkCheck, size: 20),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: _buildBody(context, theme, colors, state, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FThemeData theme,
    FColors colors,
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
            Icon(
              FLucideIcons.circleAlert,
              size: 48,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              '${t.notification.loadFailed}: ${state.error}',
              style: AppTextStyles.listSubtitle(theme),
            ),
            const SizedBox(height: 16),
            FButton(
              variant: .outline,
              onPress: () => notifier.refresh(),
              child: Text(t.notification.retry),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        controller: _scrollController,
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(
                  FLucideIcons.bellOff,
                  size: 56,
                  color: colors.mutedForeground.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  t.notification.empty,
                  style: AppTextStyles.listSubtitle(theme),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final item = state.items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colors.destructive,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              FLucideIcons.trash2,
              color: colors.destructiveForeground,
              size: 20,
            ),
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
    var targetPath = item.data?['target_path'] as String?;
    if (targetPath == null || targetPath.isEmpty) {
      // The id may arrive as a String or an int depending on the FE, so
      // normalise with toString() instead of a strict `as String?` cast,
      // which would throw a TypeError and crash the tap when the id is an int.
      final rawTxnId =
          item.data?['transactionId'] ?? item.data?['transaction_id'];
      final transactionId = rawTxnId?.toString();
      final rawCommentId = item.data?['commentId'] ?? item.data?['comment_id'];
      final commentId = rawCommentId?.toString();
      if (transactionId != null && transactionId.isNotEmpty) {
        if (commentId != null && commentId.isNotEmpty) {
          targetPath = '/home/transaction/$transactionId?commentId=$commentId';
        } else {
          targetPath = '/home/transaction/$transactionId';
        }
      }
    }
    if (targetPath != null && targetPath.isNotEmpty) {
      unawaited(context.push(targetPath));
    }
  }
}

// =============================================================================
// Notification Tile
// =============================================================================

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final isUnread = !item.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isUnread ? colors.primary.withValues(alpha: 0.04) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(colors).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(),
                size: 20,
                color: _getTypeColor(colors),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _buildSemanticTitle(),
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: colors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.createdAt),
                        style: AppTextStyles.detailLabel(theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSemanticContent(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: isUnread
                          ? colors.foreground.withValues(alpha: 0.8)
                          : colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            // Unread dot
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Semantic content builders (localized from structured data)
  // ===========================================================================

  String _buildSemanticTitle() {
    final data = item.data;
    final username =
        (data?['joined_username'] ?? data?['added_by_username'] ?? '')
            .toString();
    final spaceName = (data?['space_name'] ?? '').toString();

    return switch (item.type) {
      'member_joined' =>
        username.isNotEmpty
            ? t.notification.semantic.memberJoined(name: username)
            : item.title,
      'space_activity' =>
        spaceName.isNotEmpty
            ? t.notification.semantic.welcome(space: spaceName)
            : item.title,
      'transaction' =>
        username.isNotEmpty
            ? t.notification.semantic.newTransaction(name: username)
            : item.title,
      'member_left' =>
        username.isNotEmpty
            ? t.notification.semantic.memberLeft(name: username)
            : item.title,
      'recurring_pending' => t.notification.semantic.recurringPending,
      _ => item.title,
    };
  }

  String _buildSemanticContent() {
    final data = item.data;
    final spaceName = (data?['space_name'] ?? '').toString();
    final rawAmount = (data?['amount'] ?? '').toString();
    final currency = (data?['currency'] ?? '').toString();
    final description = (data?['description'] ?? '').toString();
    // Format amount to 2 decimal places for display
    final amount = double.tryParse(rawAmount)?.toStringAsFixed(2) ?? rawAmount;

    return switch (item.type) {
      'member_joined' =>
        spaceName.isNotEmpty
            ? t.notification.semantic.memberJoinedDetail(space: spaceName)
            : item.message,
      'transaction' =>
        amount.isNotEmpty
            ? t.notification.semantic.newTransactionDetail(
                amount: '$currency $amount',
                space: spaceName,
              )
            : item.message,
      'recurring_pending' => t.notification.semantic.recurringPendingDetail(
        description: description.isNotEmpty
            ? description
            : TransactionCategory.fromKey(
                data?['category_key'] as String?,
              ).displayText,
        amount: '$currency $amount',
      ),
      _ => item.message,
    };
  }

  // ===========================================================================
  // Type icon & color
  // ===========================================================================

  IconData _getTypeIcon() {
    return switch (item.type) {
      'space_invite' => FLucideIcons.userPlus,
      'member_joined' || 'space_activity' => FLucideIcons.userPlus,
      'member_left' => FLucideIcons.userMinus,
      'bill_comment' => FLucideIcons.messageSquare,
      'budget_alert' => FLucideIcons.alertTriangle,
      'transaction' => FLucideIcons.receipt,
      'recurring_pending' => FLucideIcons.clock,
      _ => FLucideIcons.bell,
    };
  }

  Color _getTypeColor(FColors colors) {
    return switch (item.type) {
      'space_invite' => colors.primary,
      'member_joined' || 'space_activity' => colors.primary,
      'member_left' => colors.mutedForeground,
      'bill_comment' => colors.primary,
      'budget_alert' => colors.destructive,
      'transaction' => colors.primary,
      'recurring_pending' => colors.primary,
      _ => colors.mutedForeground,
    };
  }

  String _formatTime(DateTime dateTime) {
    return relativeTime(dateTime);
  }
}
