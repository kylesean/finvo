import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';

part 'conversation_info.freezed.dart';
part 'conversation_info.g.dart';

@freezed
abstract class ConversationInfo with _$ConversationInfo {
  @JsonSerializable(
    explicitToJson: true,
    converters: [LocalDateTimeConverter()],
  )
  const factory ConversationInfo({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? token, // Add token field for storing session token
  }) = _ConversationInfo;

  factory ConversationInfo.fromJson(Map<String, dynamic> json) =>
      _$ConversationInfoFromJson(json);
}
