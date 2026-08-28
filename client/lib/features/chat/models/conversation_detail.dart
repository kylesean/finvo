import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';

part 'conversation_detail.freezed.dart';

part 'conversation_detail.g.dart';

@freezed
abstract class ConversationDetail with _$ConversationDetail {
  const factory ConversationDetail({
    required String id,
    required String title,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime updatedAt,
    // Directly include message list, no longer using pagination structure
    @Default([]) List<ChatMessage> messages,
  }) = _ConversationDetail;

  factory ConversationDetail.fromJson(Map<String, dynamic> json) =>
      _$ConversationDetailFromJson(json);
}

// Custom deserializer for DateTime
// Tolerant parse — malformed timestamps fall back to now instead of
// crashing the conversation-list parse.
DateTime _dateTimeFromJson(dynamic json) =>
    tryParseDateTime(json) ?? DateTime.now();

// Custom serializer for DateTime
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();
