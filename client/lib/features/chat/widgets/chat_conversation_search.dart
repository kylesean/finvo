// Conversation search UI for the chat drawer.
//
// Extracted from the 900+ line [ChatConversationDrawer] so the search mode
// (drawer inline + fullscreen), result list and highlight rendering can live
// and be tested independently of the drawer's conversation-list machinery.
// The panel is driven entirely by [conversationSearchProvider]; the parent
// injects the two integration points: the fallback list shown while the query
// is empty (the paginated conversation list) and the delete-confirmation flow.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/features/chat/providers/conversation_search_provider.dart';
import 'package:finvo/features/chat/providers/conversation_search_state.dart';
import 'package:finvo/features/chat/widgets/chat_conversation_drawer_search_field.dart';
import 'package:finvo/features/chat/widgets/conversation_item_skeleton.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/utils/time_utils.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// Callback for deleting a conversation from the search result list.
typedef SearchDeleteCallback =
    Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      String conversationId,
      String title,
      bool isCurrent,
    );

/// Callback building the fallback list shown while the query is empty.
typedef SearchFallbackListBuilder =
    Widget Function(BuildContext context, WidgetRef ref, FThemeData theme);

/// Search mode UI (drawer-inline and fullscreen) for the conversation drawer.
class ChatConversationSearchPanel extends ConsumerWidget {
  const ChatConversationSearchPanel({
    required this.buildFallbackList,
    required this.onDelete,
    super.key,
  });

  /// Paginated conversation list rendered while no query is active.
  final SearchFallbackListBuilder buildFallbackList;

  /// Long-press delete flow (confirm dialog + remote delete).
  final SearchDeleteCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final searchState = ref.watch(conversationSearchProvider);

    // Fullscreen mode replaces the whole drawer with an overlay.
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
              child: _buildFullscreenSearchMode(context, ref, theme),
            ),
          );
        },
      );
    }

    return _buildSearchMode(context, ref, theme);
  }

  // Build search mode
  Widget _buildSearchMode(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
  ) {
    final searchState = ref.watch(conversationSearchProvider);

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

        // Content area: Display search results if there's a search query,
        // otherwise show the original conversation list.
        Expanded(
          child: searchState.query.trim().isEmpty
              ? buildFallbackList(context, ref, theme)
              : _buildSearchResults(context, ref, theme, searchState),
        ),
      ],
    );
  }

  // Build fullscreen search mode
  Widget _buildFullscreenSearchMode(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
  ) {
    final searchState = ref.watch(conversationSearchProvider);

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

        // Search result content area - Use unified conversation list component
        // for consistent skeleton screen and scroll loading
        Expanded(
          child: searchState.query.trim().isEmpty
              ? buildFallbackList(context, ref, theme)
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
          onDelete(
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
      // Defensive clamp: highlight indexes are produced by the search service,
      // but a malformed/out-of-range range must never crash the build with a
      // RangeError (which would blank out the entire search results view).
      final start = highlight.start.clamp(0, text.length);
      final end = highlight.end.clamp(start, text.length);
      if (end <= start || start < currentIndex) {
        continue; // Skip empty, invalid, or overlapping ranges.
      }

      // Add text before highlight
      if (currentIndex < start) {
        spans.add(
          TextSpan(text: text.substring(currentIndex, start), style: baseStyle),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      currentIndex = end;
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

  // Build skeleton list
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
}
