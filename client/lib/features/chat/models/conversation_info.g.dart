// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationInfo _$ConversationInfoFromJson(Map<String, dynamic> json) =>
    _ConversationInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: const LocalDateTimeConverter().fromJson(
        json['createdAt'] as String,
      ),
      updatedAt: const LocalDateTimeConverter().fromJson(
        json['updatedAt'] as String,
      ),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$ConversationInfoToJson(_ConversationInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': const LocalDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const LocalDateTimeConverter().toJson(instance.updatedAt),
      'token': instance.token,
    };
