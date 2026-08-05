import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_attachment.freezed.dart';

enum AttachmentLoadStatus { initial, loading, loaded, failed }

/// A message attachment with its signed-URL load state.
///
/// JSON and `copyWith` are kept custom (not generated) to preserve the
/// tolerant fallback-key parsing and the `_unset` clear-to-null semantics.
@freezed
@Freezed(copyWith: false)
abstract class ChatMessageAttachment with _$ChatMessageAttachment {
  const factory ChatMessageAttachment({
    required String id,
    required String filename,

    /// Server-side storage key for this attachment. Distinct from [filename]
    /// (the display name); required to fetch a signed URL for the right object.
    String? objectKey,
    String? signedUrl,
    DateTime? expiresAt,
    @Default(AttachmentLoadStatus.initial) AttachmentLoadStatus status,
    String? errorMessage,
  }) = _ChatMessageAttachment;
}

extension ChatMessageAttachmentX on ChatMessageAttachment {
  /// Sentinel distinguishing "not provided" from "clear to null".
  static const _unset = Object();

  bool get hasSignedUrl => signedUrl != null && signedUrl!.isNotEmpty;

  String get fileExtension {
    final name = filename;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '';
    }
    return name.substring(dotIndex + 1).toLowerCase();
  }

  bool get isPreviewable {
    const imageExtensions = <String>{
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'svg',
    };
    return imageExtensions.contains(fileExtension);
  }

  ChatMessageAttachment copyWith({
    String? id,
    String? filename,
    Object? objectKey = _unset,
    Object? signedUrl = _unset,
    DateTime? expiresAt,
    AttachmentLoadStatus? status,
    Object? errorMessage = _unset,
  }) {
    return ChatMessageAttachment(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      objectKey: identical(objectKey, _unset)
          ? this.objectKey
          : objectKey as String?,
      signedUrl: identical(signedUrl, _unset)
          ? this.signedUrl
          : signedUrl as String?,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'filename': filename,
      if (objectKey != null) 'object_key': objectKey,
      if (signedUrl != null) 'signed_url': signedUrl,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

/// Tolerant JSON parsing (kept as a top-level function: extensions cannot
/// declare factory constructors).
ChatMessageAttachment chatMessageAttachmentFromJson(Map<String, dynamic> json) {
  return ChatMessageAttachment(
    id: _readRequiredString(json, 'id', 'attachmentId'),
    filename: _readRequiredString(json, 'filename', 'object_key'),
    objectKey: _readOptionalString(json, 'objectKey', 'object_key'),
    signedUrl: _readOptionalString(json, 'signedUrl', 'signed_url'),
    expiresAt: _readOptionalDateTime(json, 'expiresAt', 'expires_at'),
  );
}

String _readRequiredString(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  if (primaryKey == 'filename' && fallbackKey == 'object_key') {
    // object_key often contains (or equals) the filename
    return 'unknown_file';
  }
  throw FormatException(
    'Missing required field: $primaryKey (or $fallbackKey)',
  );
}

String? _readOptionalString(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value == null) return null;
  return value.toString();
}

DateTime? _readOptionalDateTime(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
