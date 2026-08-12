import 'dart:async';
import 'package:logging/logging.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/features/chat/providers/conversation_search_provider.dart';
import 'package:finvo/features/chat/providers/conversation_search_state.dart';
import 'package:finvo/features/chat/providers/paginated_conversation_provider.dart';
import 'package:finvo/features/chat/models/conversation_info.dart';
import 'package:finvo/features/chat/services/conversation_service.dart';
import 'package:finvo/features/chat/widgets/chat_conversation_search.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/chat/widgets/conversation_item_skeleton.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

final _logger = Logger('ChatConversationDrawer');

class ChatConversationDrawer extends ConsumerStatefulWidget {
  const ChatConversationDrawer({super.key});

  @override
  ConsumerState<ChatConversationDrawer> createState() =>
      _ChatConversationDrawerState();
}

class _ChatConversationDrawerState
    extends ConsumerState<ChatConversationDrawer> {
  @override
  void initState() {
    super.initState();
    // Ensure data is loaded immediately upon initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paginatedState = ref.read(paginatedConversationProvider);
      if (paginatedState.conversations.isEmpty && !paginatedState.isLoading) {
        unawaited(
          ref.read(paginatedConversationProvider.notifier).loadFirstPage(),
        );
      }
    });
  }

  // Build skeleton screen list
  Widget _buildSkeletonList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 8,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return const ConversationItemSkeleton();
      },
    );
  }

  // Build empty state
  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemedIcon.large(
              icon: FLucideIcons.messageCircle,
              backgroundColor: theme.colors.secondary,
            ),
            const SizedBox(height: 16),
            Text(t.chat.noHistory, style: AppTextStyles.listTitle(theme)),
            const SizedBox(height: 8),
            Text(
              t.chat.startNewChat,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build error state
  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemedIcon.large(
              icon: FLucideIcons.x,
              backgroundColor: theme.colors.destructive.withValues(alpha: 0.1),
              iconColor: theme.colors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              t.common.loadFailed,
              style: AppTextStyles.destructiveText(theme),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // The list (and its error state) is driven by
                    // paginatedConversationProvider, so retry must re-run its
                    // loader. Invalidating conversationListProvider here was a
                    // no-op: nothing on this page watches it.
                    unawaited(
                      ref
                          .read(paginatedConversationProvider.notifier)
                          .loadFirstPage(),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      t.common.retry,
                      style: AppTextStyles.listTrailing(theme),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = context.theme;
    final paginatedState = ref.watch(paginatedConversationProvider);
    final currentConversationId = ref.watch(
      chatHistoryProvider.select((state) => state.currentConversationId),
    );
    final searchState = ref.watch(conversationSearchProvider);

    // Search mode (drawer-inline or fullscreen) lives in its own panel widget.
    if (searchState.mode != SearchMode.normal) {
      return ChatConversationSearchPanel(
        buildFallbackList: (context, ref, theme) =>
            _buildPaginatedConversationList(
              context,
              ref,
              theme,
              paginatedState,
              currentConversationId,
            ),
        onDelete: _showDeleteConfirmation,
      );
    }

    return Drawer(
      backgroundColor: theme.colors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: _buildNormalMode(
          context,
          ref,
          theme,
          paginatedState,
          currentConversationId,
        ),
      ),
    );
  }

  // Normal mode interface
  Widget _buildNormalMode(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    PaginatedConversationState paginatedState,
    String? currentConversationId,
  ) {
    return Column(
      children: [
        // Top: Search box and new chat button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search box - Use Hero for smooth transition
              Hero(
                tag: 'search_box',
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(conversationSearchProvider.notifier)
                          .enterFullscreenSearchMode();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        border: Border.all(color: theme.colors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FLucideIcons.search,
                            size: 16,
                            color: theme.colors.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.chat.searchHint,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Middle: Conversation list
        Expanded(
          child: _buildPaginatedConversationList(
            context,
            ref,
            theme,
            paginatedState,
            currentConversationId,
          ),
        ),
        // Bottom: User info
        _buildUserInfo(context, ref, theme),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, WidgetRef ref, FThemeData theme) {
    final userState = ref.watch(userProfileProvider);
    final user = userState.user;

    return Container(
      decoration: const BoxDecoration(border: null),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.goNamed(AppRouteNames.profile);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                UserAvatar(
                  userId: user?.id ?? 'Finvo',
                  size: 32,
                  backgroundColor: theme.colors.secondary,
                  version: user?.updatedAt,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?.username ?? '...',
                    style: AppTextStyles.listTrailing(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build paginated conversation list
  Widget _buildPaginatedConversationList(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    PaginatedConversationState paginatedState,
    String? currentConversationId,
  ) {
    if (paginatedState.isLoading && paginatedState.conversations.isEmpty) {
      return _buildSkeletonList(context);
    }

    if (paginatedState.error != null && paginatedState.conversations.isEmpty) {
      return _buildErrorState(context, paginatedState.error!, ref);
    }

    if (paginatedState.conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Load more when scrolling to the bottom
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            paginatedState.hasMore &&
            !paginatedState.isLoadingMore) {
          unawaited(
            ref.read(paginatedConversationProvider.notifier).loadNextPage(),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(paginatedConversationProvider.notifier).refresh();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount:
              paginatedState.conversations.length +
              (paginatedState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // If it's the last item and there's more data, show loading indicator
            if (index == paginatedState.conversations.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: paginatedState.isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }

            final conversation = paginatedState.conversations[index];
            return _buildSingleConversationItem(
              context,
              conversation,
              currentConversationId,
              ref,
            );
          },
        ),
      ),
    );
  }

  // Build single conversation item
  Widget _buildSingleConversationItem(
    BuildContext context,
    ConversationInfo conversation,
    String? currentConversationId,
    WidgetRef ref,
  ) {
    final theme = context.theme;
    final isSelected = conversation.id == currentConversationId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.colors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: theme.colors.border) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              context.goNamed(
                AppRouteNames.conversation,
                pathParameters: {'conversationId': conversation.id},
              );
            }
            // Safely close Drawer to avoid errors when stack is empty
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          onLongPress: () => _showDeleteConfirmation(
            context,
            ref,
            conversation.id,
            conversation.title,
            isSelected,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Display text information only, no left message icon
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: AppTextStyles.listTrailing(theme).copyWith(
                          color: isSelected
                              ? theme.colors.primary
                              : theme.colors.foreground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'M/d HH:mm',
                          TranslationProvider.of(context).locale.languageCode,
                        ).format(conversation.updatedAt),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
    bool isSelected,
  ) async {
    // Haptic feedback on long press
    await HapticFeedback.mediumImpact();

    if (!context.mounted) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: t.chat.deleteConversation,
      message: t.chat.deleteConversationConfirm,
      cancelLabel: t.common.cancel,
      confirmVariant: FButtonVariant.destructive,
      confirmLabel: t.common.delete,
    );

    if (confirmed == true && context.mounted) {
      await _performDelete(context, ref, id, title, isSelected);
    }
  }

  /// Perform the actual delete operation
  Future<void> _performDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
    bool isSelected,
  ) async {
    final service = ref.read(conversationServiceProvider);
    bool success;
    try {
      await service.deleteConversation(id);
      success = true;
    } catch (e, st) {
      // Previously swallowed silently — deletion failures were impossible
      // to diagnose in production.
      _logger.warning(
        'ChatConversationDrawer: Failed to delete conversation $id',
        e,
        st,
      );
      success = false;
    }

    if (!context.mounted) return;

    if (success) {
      await HapticFeedback.lightImpact();
      if (!context.mounted) return;

      // Refresh the conversation list
      unawaited(ref.read(paginatedConversationProvider.notifier).refresh());

      // If we are in search mode, refresh search results as well
      final searchState = ref.read(conversationSearchProvider);
      if (searchState.mode != SearchMode.normal &&
          searchState.query.isNotEmpty) {
        ref
            .read(conversationSearchProvider.notifier)
            .updateQuery(searchState.query);
      }

      // If we deleted the current conversation, navigate to new chat and reset history
      if (isSelected) {
        // Reset chat history state
        unawaited(
          ref.read(chatHistoryProvider.notifier).createNewConversation(),
        );
        context.goNamed(AppRouteNames.ai);
      }

      // Show success toast
      ToastService.success(description: Text(t.chat.conversationDeleted));
    } else {
      await HapticFeedback.heavyImpact();
      if (!context.mounted) return;

      ToastService.showDestructive(
        description: Text(t.chat.deleteConversationFailed),
      );
    }
  }
}
