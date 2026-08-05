import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_model.freezed.dart';

/// A minimal conversation record.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({required String id, required String title}) =
      _Conversation;
}
