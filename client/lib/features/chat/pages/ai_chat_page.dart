// features/chat/pages/ai_chat_page.dart
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../widgets/chat_input_field.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/genui_error_widget.dart';
import '../providers/chat_history_provider.dart';
import '../providers/conversation_expense_provider.dart';
import '../models/chat_message.dart' as app;
import '../models/message_attachments.dart';
import '../widgets/enhanced_user_message_bubble.dart';
import '../widgets/chat_conversation_drawer.dart';
import '../widgets/welcome/welcome_guide_widget.dart';
import 'package:augo/i18n/strings.g.dart';

class AIChatPage extends ConsumerStatefulWidget {
  final String? conversationId; // From GoRouter
  const AIChatPage({super.key, this.conversationId});

  @override
  ConsumerState<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends ConsumerState<AIChatPage> {
  final _logger = Logger('AIChatPage');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _logger.info(
      "DEBUG: AIChatPage initState called. conversationId: ${widget.conversationId}",
    );
    // When the Widget is first inserted into the tree, load initial data based on the passed conversationId.
    // Use addPostFrameCallback to safely interact with Provider after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logger.info(
        "AIChatPage(initState): Initializing with conversationId: ${widget.conversationId}",
      );
      _loadDataForCurrentRoute();
    });
  }

  @override
  void didUpdateWidget(covariant AIChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logger.info(
      "DEBUG: AIChatPage didUpdateWidget called. oldConversationId: ${oldWidget.conversationId}, newConversationId: ${widget.conversationId}",
    );
    // Called when GoRouter changes route causing this Widget's parameters to change.
    // We compare old and new conversationId.
    // When route change causes Widget update (e.g. navigating from /ai/123 to /ai/456)
    // reload data
    if (widget.conversationId != oldWidget.conversationId) {
      _logger.info(
        "AIChatPage(didUpdateWidget): conversationId changed from ${oldWidget.conversationId} to ${widget.conversationId}. Reloading data.",
      );
      _loadDataForCurrentRoute();
    }
  }

  void _loadDataForCurrentRoute() {
    _logger.info(
      "DEBUG: _loadDataForCurrentRoute called. Current widget.conversationId: ${widget.conversationId}",
    );
    final notifier = ref.read(chatHistoryProvider.notifier);
    // If the route provides a conversationId, load it.
    // Add a check to avoid redundant loading when ID is the same.
    if (widget.conversationId != null) {
      // If ID exists, load the corresponding conversation
      unawaited(notifier.loadConversation(widget.conversationId!));
    } else {
      // If no ID, check whether the current Notifier has a conversation; create new if not
      // If route is /ai (conversationId is null),
      // check if Notifier already has a conversation. If not, create a new one.
      // This handles "new chat" and app first launch entering /ai.
      final currentConvId = ref.read(chatHistoryProvider).currentConversationId;
      if (currentConvId == null) {
        unawaited(notifier.createNewConversation());
      }
    }
  }

  // Show native Drawer sidebar
  void _showSidebar() {
    _logger.info("DEBUG: _showSidebar called, opening drawer");
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Get copyable content from a message
  /// Returns CopyResult containing copy content and toast message
  ({String content, String message}) _getCopyableContent(
    app.ChatMessage message,
    ChatHistory notifier,
  ) {
    // 1. If plain text content exists, return directly
    if (message.content.trim().isNotEmpty) {
      return (content: message.content, message: 'Content copied');
    }

    // 2. If GenUI component data exists (history messages), copy JSON data
    if (message.uiComponents.isNotEmpty) {
      try {
        // Merge all UI component data into JSON
        final componentsData = message.uiComponents
            .map(
              (comp) => {
                'componentType': comp.componentType,
                'surfaceId': comp.surfaceId,
                'data': comp.data,
                if (comp.userSelection != null)
                  'userSelection': comp.userSelection,
              },
            )
            .toList();

        final jsonString = const JsonEncoder.withIndent('  ').convert(
          componentsData.length == 1 ? componentsData.first : componentsData,
        );
        return (content: jsonString, message: 'JSON data copied');
      } catch (e) {
        _logger.info('Failed to serialize UI components: $e');
      }
    }

    // 3. If surfaceIds exist (real-time messages), get data from GenUI Host
    if (message.surfaceIds.isNotEmpty) {
      try {
        final genUiHost = notifier.genUiHost;
        if (genUiHost != null) {
          final surfaceDataList = <Map<String, dynamic>>[];

          for (final surfaceId in message.surfaceIds) {
            // Try to get SurfaceDefinition from GenUI Host
            final surfaceDefinition = genUiHost
                .contextFor(surfaceId)
                .definition
                .value;

            if (surfaceDefinition != null) {
              // Extract component data
              final components = surfaceDefinition.components;
              if (components.isNotEmpty) {
                for (final entry in components.entries) {
                  surfaceDataList.add({
                    'surfaceId': surfaceId,
                    'componentId': entry.key,
                    'componentType': entry.value.type,
                    'componentProperties': entry.value.properties,
                  });
                }
              }
            }
          }

          if (surfaceDataList.isNotEmpty) {
            final jsonString = const JsonEncoder.withIndent('  ').convert(
              surfaceDataList.length == 1
                  ? surfaceDataList.first
                  : surfaceDataList,
            );
            return (content: jsonString, message: 'JSON data copied');
          }
        }
      } catch (e) {
        _logger.info('Failed to get surface data from GenUI Host: $e');
      }
    }

    // 4. No copyable content
    return (content: '', message: '');
  }

  /// Build AI message with GenUI support
  Widget _buildAiMessageWithGenUi(
    BuildContext context,
    app.ChatMessage message,
    ChatHistory notifier,
  ) {
    final theme = context.theme;
    final genUiHost = notifier.genUiHost;

    // If GenUI is not available, show error
    if (genUiHost == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GenUiCompactErrorWidget(
              errorMessage: 'GenUI service not initialized',
            ),
            const SizedBox(height: 8),
            if (message.content.isNotEmpty)
              Text(message.content, style: theme.typography.body.md),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message content with GenUI surfaces
        ChatMessageWidget(message: message, genUiHost: genUiHost),

        // Action buttons for completed messages
        if (message.streamingStatus == app.StreamingStatus.completed ||
            message.streamingStatus == app.StreamingStatus.error)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: _buildActionButtons(context, message, notifier),
          ),
      ],
    );
  }

  /// Build action buttons for AI messages - minimal design, no background
  Widget _buildActionButtons(
    BuildContext context,
    app.ChatMessage message,
    ChatHistory notifier,
  ) {
    final theme = context.theme;
    final colors = theme.colors;

    // Build individual action icon button - no background
    Widget buildIconButton({
      required IconData icon,
      required VoidCallback? onTap,
      Color? color,
      bool isFirst = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(
            left: isFirst ? 0 : 20, // Increased spacing
            right: 0,
            top: 4,
            bottom: 4,
          ),
          child: Icon(icon, color: color ?? colors.mutedForeground, size: 16),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy button - first, no left padding
        buildIconButton(
          icon: FLucideIcons.copy,
          isFirst: true,
          onTap: () async {
            // Smart copy logic:
            // 1. Plain text -> copy content
            // 2. GenUI components -> copy JSON data
            // 3. No content -> show hint
            final copyResult = _getCopyableContent(message, notifier);

            if (copyResult.content.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No content to copy'),
                    behavior: SnackBarBehavior.fixed,
                    shape: RoundedRectangleBorder(),
                  ),
                );
              }
              return;
            }

            await Clipboard.setData(ClipboardData(text: copyResult.content));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(copyResult.message),
                  behavior: SnackBarBehavior.fixed,
                  shape: const RoundedRectangleBorder(),
                ),
              );
            }
          },
        ),
        // Like button
        buildIconButton(
          icon: FLucideIcons.thumbsUp,
          onTap: () =>
              notifier.updateAIFeedback(message.id, app.AIFeedbackStatus.liked),
          color: message.feedbackStatus == app.AIFeedbackStatus.liked
              ? colors.primary
              : colors.mutedForeground,
        ),
        // Dislike button
        buildIconButton(
          icon: FLucideIcons.thumbsDown,
          onTap: () => notifier.updateAIFeedback(
            message.id,
            app.AIFeedbackStatus.disliked,
          ),
          color: message.feedbackStatus == app.AIFeedbackStatus.disliked
              ? colors.primary
              : colors.mutedForeground,
        ),
        // Share button
        buildIconButton(
          icon: FLucideIcons.share2,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon...'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.fixed,
                shape: RoundedRectangleBorder(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final chatHistoryState = ref.watch(chatHistoryProvider);
    final messages = chatHistoryState.messages;
    final chatHistoryNotifier = ref.read(chatHistoryProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const ChatConversationDrawer(),
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        leading: FButton.icon(
          variant: .ghost,
          onPress: _showSidebar,
          child: const Icon(FLucideIcons.menu),
        ),
        // [REFACTORED] Use today's expense summary instead of dynamic conversation title
        // Finance Agent doesn't need chatbot-style title
        title: GestureDetector(
          onTap: _showSidebar,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  ref.watch(conversationExpenseTitleProvider),
                  style: theme.typography.body.xl.copyWith(
                    // Since 3.44, Skia fallback selects NotoSansCJK (heavier strokes), reduce font weight by one level.
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          FButton.icon(
            variant: .ghost,
            onPress: () {
              unawaited(
                ref.read(chatHistoryProvider.notifier).createNewConversation(),
              );
              context.go('/ai');
            },
            child: const Icon(FLucideIcons.plus),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !chatHistoryState.isLoadingHistory
                ? chatHistoryState.historyError != null
                      ? Center(
                          child: Text(
                            '${t.chat.loadingFailed}: ${chatHistoryState.historyError}',
                            style: theme.typography.body.md,
                          ),
                        )
                      : WelcomeGuideWidget(
                          onSuggestionTap: (prompt) {
                            unawaited(
                              chatHistoryNotifier.addUserMessageAndGetResponse(
                                prompt,
                              ),
                            );
                          },
                        )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];

                      // Select appropriate message bubble based on sender and type
                      switch (message.sender) {
                        case app.MessageSender.user:
                          return UserMessageBubble(message: message);

                        case app.MessageSender.ai:
                        case app.MessageSender.assistant:
                        default:
                          // AI message with GenUI support
                          // CRITICAL: KeyedSubtree is required to force widget rebuild when message state changes
                          // The key must include ALL fields that affect rendering to ensure proper streaming updates
                          // Without this, Flutter may batch updates and only render final state
                          return KeyedSubtree(
                            key: ValueKey(
                              '${message.id}_${message.fullContent.length}',
                            ),
                            child: _buildAiMessageWithGenUi(
                              context,
                              message,
                              chatHistoryNotifier,
                            ),
                          );
                      }
                    },
                  ),
          ),
        ],
      ),
      // Same approach as transaction detail page
      bottomNavigationBar: ChatInputField(
        onSendMessage:
            (String text, {List<PendingMessageAttachment>? attachments}) {
              return chatHistoryNotifier.addUserMessageAndGetResponse(
                text,
                attachments: attachments,
              );
            },
      ),
    );
  }
}
