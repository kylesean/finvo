// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genui_surface_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GenUiSurfaceInfo _$GenUiSurfaceInfoFromJson(Map<String, dynamic> json) =>
    _GenUiSurfaceInfo(
      surfaceId: json['surfaceId'] as String,
      messageId: json['messageId'] as String,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const LocalDateTimeConverter().fromJson,
      ),
      updatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['updatedAt'],
        const LocalDateTimeConverter().fromJson,
      ),
      status:
          $enumDecodeNullable(
            _$SurfaceStatusEnumMap,
            json['status'],
            unknownValue: SurfaceStatus.loading,
          ) ??
          SurfaceStatus.loading,
    );

Map<String, dynamic> _$GenUiSurfaceInfoToJson(_GenUiSurfaceInfo instance) =>
    <String, dynamic>{
      'surfaceId': instance.surfaceId,
      'messageId': instance.messageId,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const LocalDateTimeConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const LocalDateTimeConverter().toJson,
      ),
      'status': _$SurfaceStatusEnumMap[instance.status]!,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$SurfaceStatusEnumMap = {
  SurfaceStatus.loading: 'loading',
  SurfaceStatus.rendered: 'rendered',
  SurfaceStatus.updated: 'updated',
  SurfaceStatus.ready: 'ready',
  SurfaceStatus.error: 'error',
  SurfaceStatus.removed: 'removed',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
