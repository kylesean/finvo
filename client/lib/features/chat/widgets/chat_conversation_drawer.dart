import 'dart:async';
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
import 'package:finvo/features/chat/widgets/chat_conversation_drawer_search_field.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/chat/widgets/conversation_item_skeleton.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

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
    final theme = context.theme;
    final paginatedState = ref.watch(paginatedConversationProvider);
    final currentConversationId = ref.watch(
      chatHistoryProvider.select((state) => state.currentConversationId),
    );
    final searchState = ref.watch(conversationSearchProvider);

    // If in fullscreen search mode, use TweenAnimationBuilder for smooth transition
    if (searchState.mode == SearchMode.fullscreenSearch) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: theme.colors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2 * value),
                  blurRadius: 10 * value,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: _buildFullscreenSearchMode(
                context,
                ref,
                theme,
                searchState,
                paginatedState,
                currentConversationId,
              ),
            ),
          );
        },
      );
    }

    return Drawer(
      backgroundColor: theme.colors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: searchState.mode == SearchMode.search
            ? _buildSearchMode(context, ref, theme)
            : _buildNormalMode(
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
    } catch (e) {
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

  // Search mode interface
  Widget _buildSearchMode(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
  ) {
    final searchState = ref.watch(conversationSearchProvider);
    final paginatedState = ref.watch(paginatedConversationProvider);
    final currentConversationId = ref.watch(
      chatHistoryProvider.select((state) => state.currentConversationId),
    );

    return Column(
      children: [
        // Top: Search box and cancel button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SearchTextField(
                  searchState: searchState,
                  onChanged: (value) {
                    ref
                        .read(conversationSearchProvider.notifier)
                        .updateQuery(value);
                  },
                  onClear: () {
                    ref.read(conversationSearchProvider.notifier).clearSearch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ref
                      .read(conversationSearchProvider.notifier)
                      .exitSearchMode();
                },
                child: Text(
                  t.common.cancel,
                  style: AppTextStyles.actionText(theme),
                ),
              ),
            ],
          ),
        ),

        // Content area: Display search results if there's a search query, otherwise show original conversation list
        Expanded(
          child: searchState.query.trim().isEmpty
              ? _buildPaginatedConversationList(
                  context,
                  ref,
                  theme,
                  paginatedState,
                  currentConversationId,
                )
              : _buildSearchResults(context, ref, theme, searchState),
        ),
      ],
    );
  }

  // Build search results
  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    ConversationSearchState searchState,
  ) {
    if (searchState.isLoading) {
      return _buildSkeletonList(context);
    }

    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemedIcon.large(
                icon: FLucideIcons.triangleAlert,
                backgroundColor: theme.colors.destructive.withValues(
                  alpha: 0.1,
                ),
                iconColor: theme.colors.destructive,
              ),
              const SizedBox(height: 16),
              Text(
                t.chat.searchFailed,
                style: AppTextStyles.destructiveText(theme),
              ),
              const SizedBox(height: 8),
              Text(
                searchState.error!,
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

    if (!searchState.hasSearched) {
      return const SizedBox.shrink(); // Don't show anything when not searching, as original list will be displayed
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemedIcon.large(
                icon: FLucideIcons.search,
                backgroundColor: theme.colors.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                t.chat.noRelatedFound,
                style: theme.typography.body.md.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.chat.tryOtherKeywords,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchState.results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = searchState.results[index];
        return _buildSearchResultItem(
          context,
          ref,
          theme,
          result,
          searchState.query,
        );
      },
    );
  }

  // Build search result item
  Widget _buildSearchResultItem(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    ConversationSearchResult result,
    String query,
  ) {
    return GestureDetector(
      onTap: () {
        // If there's a messageId, navigate to specific message, otherwise navigate to conversation
        if (result.messageId != null) {
          context.goNamed(
            AppRouteNames.conversation,
            pathParameters: {'conversationId': result.id},
            queryParameters: {'messageId': result.messageId},
          );
        } else {
          context.goNamed(
            AppRouteNames.conversation,
            pathParameters: {'conversationId': result.id},
          );
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      onLongPress: () {
        final currentConversationId = ref.read(
          chatHistoryProvider.select((state) => state.currentConversationId),
        );
        unawaited(
          _showDeleteConfirmation(
            context,
            ref,
            result.id,
            result.title,
            result.id == currentConversationId,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title (with highlight) - Limit 1 line
            if (result.title.isNotEmpty)
              _buildHighlightedText(
                result.title,
                query,
                result.highlights.where((h) => h.field == 'title').toList(),
                AppTextStyles.listTrailing(theme).copyWith(height: 1.3),
                theme.colors.secondary,
                maxLines: 1,
              ),
            if (result.title.isNotEmpty) const SizedBox(height: 6),
            // Content snippet (with highlight) - Limit 2 lines
            _buildHighlightedText(
              result.snippet,
              query,
              result.highlights.where((h) => h.field == 'snippet').toList(),
              theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.4,
              ),
              theme.colors.secondary,
              maxLines: 2,
            ),
            const SizedBox(height: 6),
            // Time — converged onto the shared relative-time formatter so all
            // locales (via `time_utils.relativeTime`) and the i18n prefix labels
            // are honored instead of hardcoded English.
            Text(
              result.updatedAt != null
                  ? t.chat.updatedAt(time: relativeTime(result.updatedAt!))
                  : result.createdAt != null
                  ? t.chat.createdAt(time: relativeTime(result.createdAt!))
                  : '',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build highlighted text
  Widget _buildHighlightedText(
    String text,
    String query,
    List<HighlightRange> highlights,
    TextStyle baseStyle,
    Color highlightColor, {
    int maxLines = 2,
  }) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (highlights.isEmpty || query.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final highlight in highlights) {
      // Add text before highlight
      if (currentIndex < highlight.start) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, highlight.start),
            style: baseStyle,
          ),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: text.substring(highlight.start, highlight.end),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      currentIndex = highlight.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Build fullscreen search mode
  Widget _buildFullscreenSearchMode(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    ConversationSearchState searchState,
    PaginatedConversationState paginatedState,
    String? currentConversationId,
  ) {
    return Column(
      children: [
        // Top search bar - Use Hero for smooth transition with drawer search box
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Search box - Use Hero to share animation with drawer mode
              Expanded(
                child: Hero(
                  tag: 'search_box',
                  child: Material(
                    color: Colors.transparent,
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
                          const Expanded(child: FullscreenSearchTextField()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Cancel button
              GestureDetector(
                onTap: () {
                  ref
                      .read(conversationSearchProvider.notifier)
                      .exitSearchMode();
                },
                child: Text(
                  t.common.cancel,
                  style: AppTextStyles.actionText(theme),
                ),
              ),
            ],
          ),
        ),

        // Search result content area - Use unified conversation list component for consistent skeleton screen and scroll loading
        Expanded(
          child: searchState.query.trim().isEmpty
              ? _buildPaginatedConversationList(
                  context,
                  ref,
                  theme,
                  paginatedState,
                  currentConversationId,
                )
              : _buildSearchResults(context, ref, theme, searchState),
        ),
      ],
    );
  }
}
