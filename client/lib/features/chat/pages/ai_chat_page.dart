// features/chat/pages/ai_chat_page.dart
import 'package:logging/logging.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/chat/widgets/chat_input_field.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/chat/widgets/chat_message_widget.dart';
import 'package:finvo/features/chat/widgets/genui_error_widget.dart';
import 'package:finvo/features/chat/providers/chat_history_provider.dart';
import 'package:finvo/features/chat/providers/conversation_expense_provider.dart';
import 'package:finvo/features/chat/models/chat_message.dart' as app;
import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/features/chat/widgets/enhanced_user_message_bubble.dart';
import 'package:finvo/features/chat/widgets/chat_conversation_drawer.dart';
import 'package:finvo/features/chat/widgets/welcome/welcome_guide_widget.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/chat/utils/chat_message_copy_utils.dart';

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
    _logger.fine(
      'AIChatPage initState called. conversationId: ${widget.conversationId}',
    );
    // When the Widget is first inserted into the tree, load initial data based on the passed conversationId.
    // Use addPostFrameCallback to safely interact with Provider after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConversationData();
    });
  }

  @override
  void didUpdateWidget(AIChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When route parameter conversationId changes, re-initialize data
    if (oldWidget.conversationId != widget.conversationId) {
      _logger.fine(
        'AIChatPage didUpdateWidget: conversationId changed from ${oldWidget.conversationId} to ${widget.conversationId}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initConversationData();
      });
    }
  }

  /// Initialize conversation data
  void _initConversationData() {
    final notifier = ref.read(chatHistoryProvider.notifier);

    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
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
    _logger.fine('_showSidebar called, opening drawer');
    _scaffoldKey.currentState?.openDrawer();
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
            final copyResult = message.getCopyableContent(notifier.genUiHost);

            if (copyResult.content.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.chat.noContentToCopy),
                    behavior: SnackBarBehavior.fixed,
                    shape: const RoundedRectangleBorder(),
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
              SnackBar(
                content: Text(t.chat.shareComingSoon),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.fixed,
                shape: const RoundedRectangleBorder(),
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
    final messages = ref.watch(chatHistoryProvider.select((s) => s.messages));
    final isLoadingHistory = ref.watch(
      chatHistoryProvider.select((s) => s.isLoadingHistory),
    );
    final historyError = ref.watch(
      chatHistoryProvider.select((s) => s.historyError),
    );
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
                  style: AppTextStyles.pageTitleLarge(theme),
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
              context.goNamed(AppRouteNames.ai);
            },
            child: const Icon(FLucideIcons.plus),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !isLoadingHistory
                ? historyError != null
                      ? Center(
                          child: Text(
                            '${t.chat.loadingFailed}: $historyError',
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
                      // Keys are REQUIRED for reverse:true lists: appending a
                      // message shifts every existing index, and without keys
                      // Flutter reuses elements by index — every visible
                      // ChatMessageWidget then gets a different message and
                      // its memo cache is invalidated on every streamed chunk.
                      switch (message.sender) {
                        case app.MessageSender.user:
                          return UserMessageBubble(
                            key: message.id.isEmpty
                                ? ObjectKey(message)
                                : ValueKey('user_${message.id}'),
                            message: message,
                          );

                        case app.MessageSender.ai:
                        case app.MessageSender.assistant:
                        default:
                          // AI message with GenUI support
                          return KeyedSubtree(
                            key: message.id.isEmpty
                                ? ObjectKey(message)
                                : ValueKey('ai_${message.id}'),
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
