import 'dart:async';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:genui/genui.dart' as genui;
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/chat/models/chat_history_state.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/chat/models/chat_message_attachment.dart';
import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/features/chat/models/tool_call_info.dart';

import 'package:finvo/features/chat/services/ai_service.dart';
import 'package:finvo/features/chat/services/genui_service.dart';

import 'package:finvo/shared/utils/error_message.dart';
import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/chat/services/conversation_service.dart';
import 'package:finvo/features/chat/services/file_attachment_service.dart';
import 'package:finvo/features/chat/providers/paginated_conversation_provider.dart';
import 'package:finvo/features/chat/providers/conversation_expense_provider.dart';
import 'package:finvo/features/chat/models/conversation_info.dart';
import 'package:finvo/core/events/domain_events.dart';

import 'package:finvo/features/chat/state_controllers/stream_state_controller.dart';
import 'package:finvo/features/chat/state_controllers/streaming_controller.dart';
import 'package:finvo/features/chat/state_controllers/stream_completion_policy.dart';
import 'package:finvo/features/chat/repositories/message_repository.dart';
import 'package:finvo/features/chat/services/historical_message_processor.dart';
import 'package:finvo/features/chat/services/attachment_manager.dart';
import 'package:finvo/features/chat/services/genui_lifecycle_manager.dart';
import 'package:finvo/features/chat/services/chat_interaction_manager.dart';
import 'package:finvo/features/chat/services/conversation_session_manager.dart';
import 'package:finvo/core/network/dio_provider.dart' show sseDioProvider;
import 'package:finvo/core/constants/api_constants.dart';

part 'chat_history_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatHistory extends _$ChatHistory {
  final _logger = Logger('ChatHistory');

  // GenUI service instance (delegate to manager)
  GenUiService? get _genUiService => _genUiLifecycleManager.service;

  // Stream state controller - centralized streaming state
  final StreamStateController _streamState = StreamStateController();

  // Streaming controller - manages SSE streaming lifecycle
  // NOTE: non-final so a keepAlive provider rebuild can safely re-assign them
  // (a `late final` field would throw LateInitializationError on re-init).
  late ChatInteractionManager _chatInteractionManager;
  late StreamingController _streamingController;

  // Message repository - manages message CRUD operations
  late MessageRepository _messageRepository;

  // Conversation session loading orchestration (fetch + switch-race guard
  // + resume probe); state application stays in this provider.
  late ConversationSessionManager _conversationSessionManager;

  // Attachment manager
  late AttachmentManager _attachmentManager;
  // GenUI Lifecycle Manager
  late GenUiLifecycleManager _genUiLifecycleManager;

  /// Whether the controllers have been created at least once, so a rebuild can
  /// dispose the previous disposable instances before re-creating them.
  bool _controllersInitialized = false;

  String get _currentStreamingAiMessageId =>
      _streamingController.currentMessageId;

  @override
  ChatHistoryState build() {
    // Initialize controllers
    _initializeControllers();

    ref.onDispose(() {
      _disposeControllersSync();
    });

    // Initialize GenUI
    unawaited(Future.microtask(() => _initializeGenUi()));

    return const ChatHistoryState();
  }

  /// Initialize extracted controllers
  void _initializeControllers() {
    if (_controllersInitialized) {
      _disposeControllersSync();
    }
    _createControllers();
    _controllersInitialized = true;
  }

  /// Synchronously initiate teardown of current disposable controllers.
  ///
  /// Order matters (dispose-order hazard): the lifecycle manager must be
  /// marked disposed FIRST so its `_isDisposed` guards drop any synchronous
  /// stream callbacks that the streaming controller's teardown `cancel()`
  /// fires (`CustomContentGenerator.cancel` → `onStreamComplete`). Disposing
  /// the streaming controller first lets that callback reach
  /// `_onGenUiStreamComplete` while the guard is still open — mutating
  /// provider state inside the Riverpod dispose lifecycle (debug assertion in
  /// tests, stale-state cross-talk in release rebuilds).
  void _disposeControllersSync() {
    if (!_controllersInitialized) return;
    unawaited(_genUiLifecycleManager.dispose());
    unawaited(_streamingController.dispose());
  }

  /// Create all extracted controllers that outlive a single build.
  void _createControllers() {
    // Initialize MessageRepository
    _messageRepository = MessageRepository(
      onMessagesChanged: (messages) {
        state = state.copyWith(messages: messages);
      },
      getCurrentMessages: () => state.messages,
    );

    // Initialize ConversationSessionManager (resolver-style service access so
    // a server switch is picked up on the next load)
    _conversationSessionManager = ConversationSessionManager(
      conversationService: () => ref.read(conversationServiceProvider),
      historicalProcessor: HistoricalMessageProcessor(),
    );

    // Initialize AttachmentManager
    _attachmentManager = AttachmentManager(
      fileAttachmentService: ref.read(fileAttachmentServiceProvider),
      messageRepository: _messageRepository,
    );

    // Initialize GenUiLifecycleManager
    _genUiLifecycleManager = GenUiLifecycleManager(
      secureStorageService: ref.read(secureStorageServiceProvider),
      messageRepository: _messageRepository,
      callbacks: _buildGenUiLifecycleCallbacks(),
    );

    // Initialize StreamingController
    _streamingController = _createStreamingController();

    // Initialize ChatInteractionManager
    _chatInteractionManager = _createChatInteractionManager();
  }

  /// Build the GenUI lifecycle callbacks that wire model events (session init,
  /// text deltas, tool calls, transaction creation, title updates) back into
  /// this provider.
  GenUiLifecycleCallbacks _buildGenUiLifecycleCallbacks() {
    return GenUiLifecycleCallbacks(
      getCurrentStreamingMessageId: () => _currentStreamingAiMessageId,
      onTransactionCreated: _handleTransactionCreated,
      onSessionInit: _handleSessionInit,
      onTextResponse: _handleTextResponse,
      onStreamComplete: _onGenUiStreamComplete,
      markFirstChunkReceived: _markFirstChunkReceived,
      onTitleUpdate: _handleTitleUpdate,
      onToolCallStart: _handleToolCallStart,
      onToolCallEnd: _handleToolCallEnd,
    );
  }

  /// Build the streaming controller that manages the SSE lifecycle, wiring
  /// per-message state updates back into the provider's message list.
  StreamingController _createStreamingController() {
    return StreamingController(
      streamState: _streamState,
      callbacks: StreamingCallbacks(
        onUpdateMessageState:
            ({
              required String id,
              String? content,
              bool? isTyping,
              StreamingStatus? streamingStatus,
            }) {
              _updateAiMessageState(
                id: id,
                content: content,
                isTyping: isTyping,
                streamingStatus: streamingStatus,
              );
            },
        getCurrentMessageContent: (messageId) {
          final message = state.messages.firstWhere(
            (m) => m.id == messageId,
            orElse: () => ChatMessage.empty(),
          );
          return message.content;
        },
        onInitialDelayExceeded: () {
          _updateAiMessageState(
            id: _currentStreamingAiMessageId,
            isTyping: true,
          );
        },
        onStreamComplete: (finalTextOverride) {
          _handleStreamComplete(finalTextOverride);
        },
        onStreamError: (error) {
          _handleStreamError(error);
        },
        onStreamCancelled: (hasContent) {
          // Cancel all pending/running tool calls to stop loading animations
          _messageRepository.cancelPendingToolCalls(
            _currentStreamingAiMessageId,
          );

          if (!hasContent) {
            _updateAiMessageState(
              id: _currentStreamingAiMessageId,
              content: t.chat.stoppedResponse,
              isTyping: false,
              streamingStatus: StreamingStatus.completed,
            );
          } else {
            _updateAiMessageState(
              id: _currentStreamingAiMessageId,
              isTyping: false,
              streamingStatus: StreamingStatus.completed,
            );
          }
          if (state.isStreamingResponse) {
            state = state.copyWith(isStreamingResponse: false);
          }
        },
      ),
    );
  }

  /// Build the interaction manager that orchestrates the send pipeline.
  ChatInteractionManager _createChatInteractionManager() {
    return ChatInteractionManager(
      messageRepository: _messageRepository,
      genUiLifecycleManager: _genUiLifecycleManager,
      streamingController: _streamingController,
      setStreamingStatus: (isStreaming) {
        state = state.copyWith(isStreamingResponse: isStreaming);
      },
      getCurrentConversationId: () => state.currentConversationId ?? '',
    );
  }

  /// Initialize GenUI service with catalog and lifecycle callbacks
  Future<void> _initializeGenUi() async {
    // Use SSE-dedicated Dio instance (no timeout)
    final dio = ref.read(sseDioProvider);
    await _genUiLifecycleManager.initialize(
      dio: dio,
      // Resolve the SSE base URL at request time so a server switch takes
      // effect immediately instead of streaming to the old server for the
      // whole keepAlive service lifetime.
      sseBaseUrlResolver: () => ref.read(sseBaseUrlProvider),
    );

    // Pass GenUI service reference to extracted controllers
    _streamingController.setGenUiService(_genUiLifecycleManager.service);

    // Wire up optimistic user message update
    _genUiLifecycleManager.setOnUserMessageSent((content) {
      _handleOptimisticUserMessage(content);
    });
  }

  /// Handle session initialization
  void _handleSessionInit(String sessionId, String? messageId) {
    final isNewSession =
        state.currentConversationId == null ||
        state.currentConversationId!.isEmpty;

    if (isNewSession) {
      state = state.copyWith(currentConversationId: sessionId);
      final newTitle = state.currentConversationTitle ?? t.chat.newChat;
      ref
          .read(paginatedConversationProvider.notifier)
          .addNewSession(
            ConversationInfo(
              id: sessionId,
              title: newTitle,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
    } else {
      if (state.currentConversationId != sessionId) {
        _logger.info(
          'ChatHistory: Session ID mismatch. State: ${state.currentConversationId}, Received: $sessionId',
        );
      }
    }

    if (messageId != null && _currentStreamingAiMessageId.isNotEmpty) {
      _updateMessageIdLocally(_currentStreamingAiMessageId, messageId);
      // Keep streaming controller in sync so subsequent text/tool-call events
      // (which carry the server-assigned ID) still find the message.
      // Previously the controller kept the temporary optimistic UUID, causing
      // first-chunk content to be silently dropped on new conversations.
      _streamingController.updateCurrentMessageId(messageId);
    }
  }

  /// Handle stream completion (GenUI onStreamComplete callback).
  ///
  /// The stream can be driven to completion through two callbacks: the GenUI
  /// `onStreamComplete` (this method) and the SSE layer's `onStreamComplete`
  /// (which calls `_handleStreamComplete`). Both must converge on the single
  /// `_handleStreamComplete` path, which itself guards against running twice.
  void _onGenUiStreamComplete() {
    if (_streamingController.isMessageCompleted) {
      if (state.isStreamingResponse) {
        state = state.copyWith(isStreamingResponse: false);
      }
      return;
    }
    if (_streamingController.isUserCancelled) {
      _handleStreamComplete(null);
    } else if (!_streamingController.isFirstChunkReceived) {
      final currentMessage = state.messages.firstWhere(
        (m) => m.id == _currentStreamingAiMessageId,
        orElse: () => ChatMessage.empty(),
      );
      if (currentMessage.surfaceIds.isNotEmpty) {
        _handleStreamComplete(null);
      } else {
        _handleStreamComplete(t.chat.errorRecover);
      }
    } else {
      _handleStreamComplete(null);
    }
  }

  /// Handle title update
  void _handleTitleUpdate(String title) {
    state = state.copyWith(currentConversationTitle: title);
    if (state.currentConversationId != null) {
      ref
          .read(paginatedConversationProvider.notifier)
          .updateSessionTitle(state.currentConversationId!, title);
    }
  }

  /// Handle tool call start event (Claude Code style visualization)
  void _handleToolCallStart(ToolCallInfo toolCall) {
    if (_currentStreamingAiMessageId.isEmpty) {
      _logger.warning('ChatHistory: Tool call start but no streaming message');
      return;
    }
    _logger.info(
      'ChatHistory: Tool call start - ${toolCall.name} (${toolCall.id})',
    );
    _messageRepository.addOrUpdateToolCall(
      _currentStreamingAiMessageId,
      toolCall,
    );
  }

  /// Handle tool call end event (Claude Code style visualization)
  void _handleToolCallEnd(ToolCallInfo toolCall) {
    if (_currentStreamingAiMessageId.isEmpty) {
      _logger.warning('ChatHistory: Tool call end but no streaming message');
      return;
    }
    _logger.info(
      'ChatHistory: Tool call end - ${toolCall.name} (${toolCall.id}) '
      'status=${toolCall.status}, duration=${toolCall.durationMs}ms',
    );
    _messageRepository.addOrUpdateToolCall(
      _currentStreamingAiMessageId,
      toolCall,
    );
  }

  /// Handle transaction created event
  ///
  /// Publishes a domain event instead of invalidating home providers
  /// directly: the home feature subscribes to the event bus and refreshes
  /// its own data, keeping feature boundaries intact.
  void _handleTransactionCreated(
    double amount,
    String transactionType,
    String currency,
  ) {
    ref
        .read(transactionCreatedEventsProvider)
        .add(
          TransactionCreatedEvent(
            amount: amount,
            transactionType: transactionType,
            currency: currency,
            occurredAt: DateTime.now(),
          ),
        );
  }

  /// Handle text response from GenUI
  void _handleTextResponse(String text) {
    if (_streamingController.handleTextChunk(text)) {
      _updateAiMessageState(id: _currentStreamingAiMessageId, isTyping: false);
    }

    if (text.isEmpty) return;
    if (_currentStreamingAiMessageId.isEmpty) return;

    // CHAT-01: drop deltas that arrive after the stream reached a terminal
    // state. The repository releases the incremental buffer on completion, so
    // a late delta would rebuild an empty buffer via putIfAbsent and truncate
    // (content) or duplicate (fullContent) the already-preserved body.
    if (_streamingController.isMessageCompleted) return;

    _updateAiMessageState(
      id: _currentStreamingAiMessageId,
      contentDelta: text,
      timestamp: DateTime.now(),
    );
  }

  void _markFirstChunkReceived() {
    _streamingController.markFirstChunkReceived();
  }

  void _handleOptimisticUserMessage(String content) {
    unawaited(_chatInteractionManager.handleOptimisticUserMessage(content));
  }

  // Load first page of history messages
  Future<void> loadConversation(String conversationId) async {
    if (conversationId == state.currentConversationId &&
        !state.isLoadingHistory) {
      return;
    }
    await _streamingController.cancelStreamAndTimers();
    // H-4: clear the GenUI surface registry (and its message→surface index)
    // when switching sessions. The lifecycle manager is keepAlive for the
    // whole app lifetime, so without this every session switch leaks surface
    // entries — unbounded growth plus stale getSurfaceInfo() results.
    _genUiLifecycleManager.clearSession();
    _messageRepository.clearAllContentBuffers();

    state = state.copyWith(
      currentConversationId: conversationId,
      messages: [],
      isLoadingHistory: true,
      historyError: null,
      currentConversationTitle: t.common.loading,
      isStreamingResponse: false,
    );

    ref
        .read(conversationExpenseProvider.notifier)
        .switchConversation(conversationId);
    // Fetch + process + apply through the session manager, which owns the
    // network call and the switch-race guard; state application stays here.
    final loaded = await _conversationSessionManager.loadConversationDetail(
      conversationId,
      isCurrent: () => conversationId == state.currentConversationId,
      onLoaded: (result) {
        state = state.copyWith(
          messages: result.messages,
          currentConversationTitle: result.title,
          isLoadingHistory: false,
        );
        if (_genUiService != null && _genUiService!.isInitialized) {
          _genUiService!.conversation.setSessionId(conversationId);
        }
      },
      onError: (e) {
        // Only surface errors for the conversation that is still current.
        state = state.copyWith(
          isLoadingHistory: false,
          historyError: safeErrorMessage(e),
          currentConversationTitle: t.common.loadFailed,
        );
      },
    );

    // L-1: probing resume state for a conversation that failed to load (or
    // was switched away) is a pointless network call — skip it unless the
    // detail actually loaded and is still current.
    if (loaded) {
      await _conversationSessionManager.checkAndResumeIfNeeded(conversationId);
    }
  }

  Future<void> createNewConversation() async {
    await _streamingController.cancelStreamAndTimers();
    // H-4: same as loadConversation — reset the keepAlive surface registry so
    // the new conversation starts with a clean surface state.
    _genUiLifecycleManager.clearSession();
    _messageRepository.clearAllContentBuffers();
    if (_genUiService != null && _genUiService!.isInitialized) {
      _genUiService!.conversation.clearSession();
    }
    state = ChatHistoryState(currentConversationTitle: t.chat.newChat);
    ref.read(conversationExpenseProvider.notifier).switchConversation(null);
  }

  Future<void> addUserMessageAndGetResponse(
    String text, {
    List<PendingMessageAttachment>? attachments,
  }) async {
    await _chatInteractionManager.addUserMessageAndGetResponse(
      text,
      attachments: attachments,
    );
  }

  void _updateAiMessageState({
    required String id,
    String? content,
    String? contentDelta,
    bool? isTyping,
    StreamingStatus? streamingStatus,
    DateTime? timestamp,
  }) {
    _messageRepository.updateAiMessageState(
      id: id,
      content: content,
      contentDelta: contentDelta,
      isTyping: isTyping,
      streamingStatus: streamingStatus,
      timestamp: timestamp,
    );
  }

  void _updateMessageIdLocally(String oldId, String newId) {
    _messageRepository.updateMessageId(oldId, newId);
  }

  void _handleStreamError(Object error) {
    final errorMessageText = safeErrorMessage(error);
    final displayError = t.chat.aiCommunicationError(error: errorMessageText);

    final currentText = state.messages
        .firstWhere(
          (m) => m.id == _currentStreamingAiMessageId,
          orElse: () => ChatMessage.empty(),
        )
        .content;

    _updateAiMessageState(
      id: _currentStreamingAiMessageId,
      content: currentText.isEmpty
          ? displayError
          : '$currentText\n\n$displayError',
      isTyping: false,
      streamingStatus: StreamingStatus.error,
    );

    state = state.copyWith(isStreamingResponse: false);
  }

  void _handleStreamComplete(String? finalTextOverride) {
    // Guard against double-completion (see [resolveStreamCompletionAction]):
    // both the GenUI onStreamComplete and the SSE layer's onStreamComplete can
    // reach here, and in some interleavings BOTH fire for the same message. The
    // first pass already clears the incremental content buffer (see
    // MessageRepository), so a second pass would read an empty buffer and
    // inadvertently blank the message content. Keeping the terminal bookkeeping
    // on a single guarded path also avoids redundant message-list rebuilds and
    // tool-call sweeps. CHAT-1: a terminal error state must never be
    // overwritten with `completed` — the user must see the error state, not a
    // "completed" message with an error footnote.
    final messageIndex = state.messages.indexWhere(
      (m) => m.id == _currentStreamingAiMessageId,
    );
    final messageInErrorState =
        messageIndex != -1 &&
        state.messages[messageIndex].streamingStatus == StreamingStatus.error;

    switch (resolveStreamCompletionAction(
      isMessageCompleted: _streamingController.isMessageCompleted,
      isMessageInErrorState: messageInErrorState,
    )) {
      case StreamCompletionAction.skipAlreadyCompleted:
        if (state.isStreamingResponse) {
          state = state.copyWith(isStreamingResponse: false);
        }
      case StreamCompletionAction.preserveError:
        // Drive the stream phase to error so a trailing completion callback
        // also short-circuits via the guard above.
        _streamingController.markStreamEnded(isError: true);
        state = state.copyWith(isStreamingResponse: false);
      case StreamCompletionAction.finalize:
        _streamingController.markMessageCompleted();

        // Clean up any tool calls still in pending/running state. Handles the
        // case where the server emitted tool_call_start but never sent the
        // corresponding tool_call_end (e.g. internal skill file reads that
        // bypass the standard tools node). Mark as success since the stream
        // completed normally.
        _messageRepository.completePendingToolCalls(
          _currentStreamingAiMessageId,
        );

        if (finalTextOverride != null) {
          _updateAiMessageState(
            id: _currentStreamingAiMessageId,
            content: finalTextOverride,
            isTyping: false,
            streamingStatus: StreamingStatus.completed,
          );
        } else {
          _updateAiMessageState(
            id: _currentStreamingAiMessageId,
            isTyping: false,
            streamingStatus: StreamingStatus.completed,
          );
        }

        state = state.copyWith(isStreamingResponse: false);
    }
  }

  void cancelPendingOperation() {
    if (state.isStreamingResponse) {
      state = state.copyWith(isStreamingResponse: false);
    }

    unawaited(
      _streamingController.cancelPendingOperation(
        cancelLastTurn: (sessionId) =>
            ref.read(aiServiceProvider).cancelLastTurn(sessionId),
        sessionId: state.currentConversationId,
      ),
    );
  }

  Future<void> ensureAttachmentsSignedUrls(
    String messageId, {
    List<String>? attachmentIds,
    bool forceRetry = false,
  }) async {
    final messageIndex = state.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final currentMessage = state.messages[messageIndex];
    var targetAttachments = currentMessage.attachments;
    if (attachmentIds != null) {
      final idSet = attachmentIds.toSet();
      targetAttachments = targetAttachments
          .where((a) => idSet.contains(a.id))
          .toList();
    }

    if (!forceRetry) {
      targetAttachments = targetAttachments
          .where((a) => a.status != AttachmentLoadStatus.failed)
          .toList();
    }

    if (targetAttachments.isEmpty) return;

    await _attachmentManager.fetchSignedUrlsForMessage(
      messageId,
      targetAttachments,
      forceFetch: forceRetry,
    );
  }

  void updateAIFeedback(String messageId, AIFeedbackStatus newFeedbackStatus) {
    _messageRepository.updateFeedbackStatus(messageId, newFeedbackStatus);
  }

  genui.SurfaceHost? get genUiHost {
    try {
      return _genUiService?.host;
    } catch (e) {
      _logger.info('ChatHistory: Failed to get GenUI host: $e');
      return null;
    }
  }
}
