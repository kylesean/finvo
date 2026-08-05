/// SSE event model definitions
///
/// Contains data type definitions for SSE events, used by
/// CustomContentGenerator.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sse_event_models.freezed.dart';

/// Tool call start event
@freezed
abstract class ToolCallStartEvent with _$ToolCallStartEvent {
  const factory ToolCallStartEvent({
    @Default('') String id,
    @Default('unknown') String name,
    @Default(<String, dynamic>{}) Map<String, dynamic> args,
    String? timestamp,
  }) = _ToolCallStartEvent;
}

/// Tolerant parsing (top-level: extensions cannot declare constructors).
ToolCallStartEvent toolCallStartEventFromJson(Map<String, dynamic> json) {
  return ToolCallStartEvent(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'unknown',
    args: json['args'] as Map<String, dynamic>? ?? {},
    timestamp: json['timestamp'] as String?,
  );
}

/// Tool call end event
@freezed
abstract class ToolCallEndEvent with _$ToolCallEndEvent {
  const factory ToolCallEndEvent({
    @Default('') String id,
    @Default('unknown') String name,
    @Default('success') String status,
    int? durationMs,
    String? resultPreview,
    String? error,
  }) = _ToolCallEndEvent;
}

/// Tolerant parsing (top-level: extensions cannot declare constructors).
ToolCallEndEvent toolCallEndEventFromJson(Map<String, dynamic> json) {
  return ToolCallEndEvent(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'unknown',
    status: json['status'] as String? ?? 'success',
    durationMs: json['duration_ms'] as int?,
    resultPreview: json['result'] as String?,
    error: json['error'] as String?,
  );
}

/// Tool info
@freezed
abstract class ToolInfo with _$ToolInfo {
  const factory ToolInfo({
    @Default('unknown') String name,
    @Default('') String displayName,
    @Default('readonly') String toolType,
    @Default(true) bool cancellable,
    String? warningOnCancel,
    String? surfaceId,
  }) = _ToolInfo;
}

extension ToolInfoX on ToolInfo {
  bool get isWriteOperation => toolType == 'write';
  bool get isReadonly => toolType == 'readonly';
  bool get isHitl => toolType == 'hitl';
}

/// Tolerant parsing (top-level: extensions cannot declare constructors).
ToolInfo toolInfoFromJson(Map<String, dynamic> json) {
  return ToolInfo(
    name: json['name'] as String? ?? 'unknown',
    displayName: json['display_name'] as String? ?? '',
    toolType: json['tool_type'] as String? ?? 'readonly',
    cancellable: json['cancellable'] as bool? ?? true,
    warningOnCancel: json['warning_on_cancel'] as String?,
    surfaceId: json['surface_id'] as String?,
  );
}

/// SSE event callback collection
@freezed
abstract class SseEventCallbacks with _$SseEventCallbacks {
  const factory SseEventCallbacks({
    void Function(String sessionId, String? messageId)? onSessionInit,
    void Function(String text)? onTextChunk,
    void Function()? onStreamComplete,
    void Function(String title)? onTitleUpdate,
    void Function(String error)? onError,
    void Function(String localId, String serverId)? onMessageIdUpdate,
    void Function(String surfaceId)? onSurfaceCreated,
    void Function(ToolCallStartEvent event)? onToolCallStart,
    void Function(ToolCallEndEvent event)? onToolCallEnd,
    void Function(double amount, String type, String currency)?
    onTransactionCreated,
  }) = _SseEventCallbacks;
}
