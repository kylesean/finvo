import 'dart:async';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:genui/genui.dart' as genui;
import '../models/chat_history_state.dart';
import '../models/chat_message.dart';
import '../models/chat_message_attachment.dart';
import '../models/message_attachments.dart';
import '../models/tool_call_info.dart';

import '../services/ai_service.dart';
import '../services/data_uri_service.dart';
import '../services/genui_service.dart';

import '../../../core/network/exceptions/app_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../services/conversation_service.dart';
import '../services/file_attachment_service.dart';
import '../providers/paginated_conversation_provider.dart';
import '../providers/conversation_expense_provider.dart';
import '../models/conversation_info.dart';
import '../../home/providers/home_providers.dart';

import '../state_controllers/stream_state_controller.dart';
import '../state_controllers/streaming_controller.dart';
import '../repositories/message_repository.dart';
import '../services/historical_message_processor.dart';
import '../services/conversation_manager.dart';
import '../services/attachment_manager.dart';
import '../services/genui_lifecycle_manager.dart';
import '../services/chat_interaction_manager.dart';
import '../../../core/network/dio_provider.dart' show sseDioProvider;
import '../../../core/constants/api_constants.dart';

part 'chat_history_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatHistory extends _$ChatHistory {
  final _logger = Logger('ChatHistory');

  // GenUI service instance (delegate to manager)
  GenUiService? get _genUiService => _genUiLifecycleManager.service;

  // Stream state controller - centralized streaming state
  final StreamStateController _streamState = StreamStateController();

  // Streaming controller - manages SSE streaming lifecycle
  late final ChatInteractionManager _chatInteractionManager;
  late final StreamingController _streamingController;

  // Message repository - manages message CRUD operations
  late final MessageRepository _messageRepository;

  // Historical message processor
  final HistoricalMessageProcessor _historicalProcessor =
      HistoricalMessageProcessor();

  // Conversation manager - works through callback pattern
  // ignore: unused_field
  late final ConversationManager _conversationManager;

  // Attachment manager
  late final AttachmentManager _attachmentManager;

  // GenUI Lifecycle Manager
  late final GenUiLifecycleManager _genUiLifecycleManager;

  String get _currentStreamingAiMessageId =>
      _streamingController.currentMessageId;

  @override
  ChatHistoryState build() {
    // Initialize controllers
    _initializeControllers();

    ref.onDispose(() {
      unawaited(_streamingController.cancelStreamAndTimers());
      _streamingController.dispose();
      _genUiLifecycleManager.dispose();
    });

    // Initialize GenUI
    unawaited(Future.microtask(() => _initializeGenUi()));

    return const ChatHistoryState();
  }

  /// Initialize extracted controllers
  void _initializeControllers() {
    // Initialize MessageRepository
    _messageRepository = MessageRepository(
      onMessagesChanged: (messages) {
        state = state.copyWith(messages: messages);
      },
      getCurrentMessages: () => state.messages,
    );

    // Initialize ConversationManager
    _conversationManager = ConversationManager(
      onStateChanged: (update) {
        state = state.copyWith(
          currentConversationId:
              update.conversationId ?? state.currentConversationId,
          currentConversationTitle:
              update.title ?? state.currentConversationTitle,
          isLoadingHistory: update.isLoading ?? state.isLoadingHistory,
          isStreamingResponse: update.isStreaming ?? state.isStreamingResponse,
          historyError: update.error,
        );
      },
      onSessionAdded: (session) {
        ref.read(paginatedConversationProvider.notifier).addNewSession(session);
      },
      onTitleUpdated: (conversationId, title) {
        ref
            .read(paginatedConversationProvider.notifier)
            .updateSessionTitle(conversationId, title);
      },
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

    // Initialize StreamingController
    _streamingController = StreamingController(
      streamState: _streamState,
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
        _updateAiMessageState(id: _currentStreamingAiMessageId, isTyping: true);
      },
      onStreamComplete: (finalTextOverride) {
        _handleStreamComplete(finalTextOverride);
      },
      onStreamError: (error) {
        _handleStreamError(error);
      },
      onStreamCancelled: (hasContent) {
        // Cancel all pending/running tool calls to stop loading animations
        _messageRepository.cancelPendingToolCalls(_currentStreamingAiMessageId);

        if (!hasContent) {
          _updateAiMessageState(
            id: _currentStreamingAiMessageId,
            content: '你已让系统停止这条回答',
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
    );

    // Initialize ChatInteractionManager
    _chatInteractionManager = ChatInteractionManager(
      messageRepository: _messageRepository,
      genUiLifecycleManager: _genUiLifecycleManager,
      streamingController: _streamingController,
      dataUriService: DataUriService(),
      setStreamingStatus: (isStreaming) {
        state = state.copyWith(isStreamingResponse: isStreaming);
      },
      getCurrentConversationId: () => state.currentConversationId ?? '',
      getCurrentConversationTitle: () => state.currentConversationTitle ?? '',
    );
  }

  /// Initialize GenUI service with catalog and lifecycle callbacks
  Future<void> _initializeGenUi() async {
    // 使用 SSE 专用 Dio 实例（无超时限制）
    final dio = ref.read(sseDioProvider);
    final apiConstants = ref.read(apiConstantsProvider);
    await _genUiLifecycleManager.initialize(
      dio: dio,
      sseBaseUrl: apiConstants.sseBaseUrl,
    );

    // Pass GenUI service reference to extracted controllers
    _streamingController.setGenUiService(_genUiLifecycleManager.service);

    // Wire up optimistic user message update
    _genUiLifecycleManager.setOnUserMessageSent((content) {
      _handleOptimisticUserMessage(content);
    });
  }

  /// 处理会话初始化
  void _handleSessionInit(String sessionId, String? messageId) {
    final isNewSession =
        state.currentConversationId == null ||
        state.currentConversationId!.isEmpty;

    if (isNewSession) {
      state = state.copyWith(currentConversationId: sessionId);
      final newTitle = state.currentConversationTitle ?? 'New Chat';
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
    }
  }

  /// 处理流完成
  void _onGenUiStreamComplete() {
    if (!_streamingController.isMessageCompleted) {
      if (_streamingController.isUserCancelled) {
        _streamingController.markMessageCompleted();
        _handleStreamComplete(null);
      } else if (!_streamingController.isFirstChunkReceived) {
        _streamingController.markMessageCompleted();
        final currentMessage = state.messages.firstWhere(
          (m) => m.id == _currentStreamingAiMessageId,
          orElse: () => ChatMessage.empty(),
        );

        if (currentMessage.surfaceIds.isNotEmpty) {
          _handleStreamComplete(null);
        } else {
          _handleStreamComplete(
            'Sorry, I encountered an issue, please try again 🙏',
          );
        }
      } else {
        _streamingController.markMessageCompleted();
        _handleStreamComplete(null);
      }
    } else {
      if (state.isStreamingResponse) {
        state = state.copyWith(isStreamingResponse: false);
      }
    }
  }

  /// 处理标题更新
  void _handleTitleUpdate(String title) {
    state = state.copyWith(currentConversationTitle: title);
    if (state.currentConversationId != null) {
      ref
          .read(paginatedConversationProvider.notifier)
          .updateSessionTitle(state.currentConversationId!, title);
    }
  }

  /// 处理工具调用开始事件 (Claude Code 风格可视化)
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

  /// 处理工具调用结束事件 (Claude Code 风格可视化)
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

  /// 处理交易创建事件
  void _handleTransactionCreated(
    double amount,
    String transactionType,
    String currency,
  ) {
    ref
        .read(conversationExpenseProvider.notifier)
        .addExpense(amount, transactionType: transactionType);
    unawaited(ref.read(transactionFeedProvider.notifier).refreshFeed());
    ref.invalidate(totalExpenseProvider);
    final currentMonth = ref.read(currentDisplayMonthProvider);
    ref.invalidate(calendarMonthDataProvider(currentMonth));
    final selectedDate = ref.read(selectedDateProvider);
    if (selectedDate != null) {
      ref.invalidate(transactionsForSelectedDateProvider(selectedDate));
    }
  }

  /// Handle text response from GenUI
  void _handleTextResponse(String text) {
    if (_streamingController.handleTextChunk(text)) {
      _updateAiMessageState(id: _currentStreamingAiMessageId, isTyping: false);
    }

    if (text.isEmpty) return;
    if (_currentStreamingAiMessageId.isEmpty) return;

    final currentMessage = state.messages.firstWhere(
      (m) => m.id == _currentStreamingAiMessageId,
      orElse: () => ChatMessage.empty(),
    );

    _updateAiMessageState(
      id: _currentStreamingAiMessageId,
      content: currentMessage.content + text,
      timestamp: DateTime.now(),
    );
  }

  void _markFirstChunkReceived() {
    _streamingController.markFirstChunkReceived();
  }

  void _handleOptimisticUserMessage(String content) {
    unawaited(_chatInteractionManager.handleOptimisticUserMessage(content));
  }

  // 加载第一页历史消息
  Future<void> loadConversation(String conversationId) async {
    if (conversationId == state.currentConversationId &&
        !state.isLoadingHistory) {
      return;
    }
    await _streamingController.cancelStreamAndTimers();

    state = state.copyWith(
      currentConversationId: conversationId,
      messages: [],
      isLoadingHistory: true,
      historyError: null,
      currentConversationTitle: "加载中...",
      isStreamingResponse: false,
    );

    ref
        .read(conversationExpenseProvider.notifier)
        .switchConversation(conversationId);
    try {
      final conversationService = ref.read(conversationServiceProvider);
      final conversationDetail = await conversationService
          .getConversationDetail(conversationId);

      final processedMessages = _processHistoricalMessages(
        conversationDetail.messages,
      );

      state = state.copyWith(
        messages: processedMessages,
        currentConversationTitle: conversationDetail.title,
        isLoadingHistory: false,
        historyCurrentPage: 1,
        historyHasMore: false,
      );

      if (_genUiService != null && _genUiService!.isInitialized) {
        _genUiService!.conversation.setSessionId(conversationId);
      }

      await _checkAndResumeIfNeeded(conversationId);
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: e.toString(),
        currentConversationTitle: "加载失败",
      );
    }
  }

  Future<void> _checkAndResumeIfNeeded(String conversationId) async {
    try {
      final conversationService = ref.read(conversationServiceProvider);
      final resumeStatus = await conversationService.getResumeStatus(
        conversationId,
      );
      if (resumeStatus.canResume) {
        _logger.info(
          'ChatHistory: Detected resumable state for $conversationId, nextNodes: ${resumeStatus.nextNodes}',
        );
      }
    } catch (e) {
      _logger.info(
        'ChatHistory: Resume status check failed (non-critical): $e',
      );
    }
  }

  Future<void> loadMoreMessages() async {
    return;
  }

  Future<void> createNewConversation() async {
    await _streamingController.cancelStreamAndTimers();
    if (_genUiService != null && _genUiService!.isInitialized) {
      _genUiService!.conversation.clearSession();
    }
    state = const ChatHistoryState(currentConversationTitle: 'New Chat');
    ref.read(conversationExpenseProvider.notifier).reset();
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
    bool? isTyping,
    StreamingStatus? streamingStatus,
    DateTime? timestamp,
  }) {
    _messageRepository.updateAiMessageState(
      id: id,
      content: content,
      isTyping: isTyping,
      streamingStatus: streamingStatus,
      timestamp: timestamp,
    );
  }

  void _updateMessageIdLocally(String oldId, String newId) {
    _messageRepository.updateMessageId(oldId, newId);
  }

  void _handleStreamError(dynamic error) {
    final errorMessageText = error is AppException
        ? error.message
        : "发生未知错误: ${error.toString()}";
    final displayError = "抱歉，AI助手通讯发生错误: $errorMessageText";

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
          : "$currentText\n\n$displayError",
      isTyping: false,
      streamingStatus: StreamingStatus.error,
    );

    state = state.copyWith(isStreamingResponse: false);
  }

  void _handleStreamComplete(String? finalTextOverride) {
    final messageIndex = state.messages.indexWhere(
      (m) => m.id == _currentStreamingAiMessageId,
    );
    if (messageIndex == -1) return;

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

  List<ChatMessage> _processHistoricalMessages(List<ChatMessage> rawMessages) {
    return _historicalProcessor.processHistoricalMessages(rawMessages);
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
