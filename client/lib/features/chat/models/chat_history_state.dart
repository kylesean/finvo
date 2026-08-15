import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/chat/models/chat_message.dart';

part 'chat_history_state.freezed.dart';

@freezed
abstract class ChatHistoryState with _$ChatHistoryState {
  const factory ChatHistoryState({
    String? currentConversationId,
    String? currentConversationTitle,
    @Default(false) bool isLoadingHistory,
    @Default([]) List<ChatMessage> messages,
    String? historyError,
    @Default(false)
    bool isStreamingResponse, // Whether AI is currently streaming response
  }) = _ChatHistoryState;
}
