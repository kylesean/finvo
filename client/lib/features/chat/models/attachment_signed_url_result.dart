import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_signed_url_result.freezed.dart';

/// Result of a batch signed-URL request.
///
/// JSON parsing stays custom (top-level [attachmentSignedUrlResultFromJson])
/// to keep the tolerant list handling (accepting both `Map<String, dynamic>`
/// and raw `Map` entries).
@freezed
abstract class AttachmentSignedUrlResult with _$AttachmentSignedUrlResult {
  const factory AttachmentSignedUrlResult({
    @Default(<AttachmentSignedUrlInfo>[])
    List<AttachmentSignedUrlInfo> successful,
    @Default(<AttachmentSignedUrlFailure>[])
    List<AttachmentSignedUrlFailure> failed,
  }) = _AttachmentSignedUrlResult;
}

extension AttachmentSignedUrlResultX on AttachmentSignedUrlResult {
  bool get hasSuccess => successful.isNotEmpty;

  bool get hasFailures => failed.isNotEmpty;
}

/// Empty result used as a safe default.
const AttachmentSignedUrlResult emptyAttachmentSignedUrlResult =
    AttachmentSignedUrlResult();

AttachmentSignedUrlResult attachmentSignedUrlResultFromJson(
  Map<String, dynamic> json,
) {
  final successfulList = json['successful'];
  final failedList = json['failed'];

  return AttachmentSignedUrlResult(
    successful: _parseInfoList(successfulList),
    failed: _parseFailureList(failedList),
  );
}

List<AttachmentSignedUrlInfo> _parseInfoList(dynamic value) {
  if (value is! List) return const [];

  final result = <AttachmentSignedUrlInfo>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      result.add(attachmentSignedUrlInfoFromJson(entry));
    } else if (entry is Map) {
      result.add(
        attachmentSignedUrlInfoFromJson(entry.cast<String, dynamic>()),
      );
    }
  }
  return result;
}

List<AttachmentSignedUrlFailure> _parseFailureList(dynamic value) {
  if (value is! List) return const [];

  final result = <AttachmentSignedUrlFailure>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      result.add(attachmentSignedUrlFailureFromJson(entry));
    } else if (entry is Map) {
      result.add(
        attachmentSignedUrlFailureFromJson(entry.cast<String, dynamic>()),
      );
    }
  }
  return result;
}

@freezed
abstract class AttachmentSignedUrlInfo with _$AttachmentSignedUrlInfo {
  const factory AttachmentSignedUrlInfo({
    required String id,
    required String filename,
    required String signedUrl,
    DateTime? expiresAt,
  }) = _AttachmentSignedUrlInfo;
}

extension AttachmentSignedUrlInfoX on AttachmentSignedUrlInfo {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'filename': filename,
      'signed_url': signedUrl,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

AttachmentSignedUrlInfo attachmentSignedUrlInfoFromJson(
  Map<String, dynamic> json,
) {
  return AttachmentSignedUrlInfo(
    id: _readRequiredString(json, 'id', 'attachment_id'),
    filename: _readRequiredString(json, 'filename', 'object_key'),
    signedUrl: _readRequiredString(json, 'signed_url', 'signedUrl'),
    expiresAt: _readOptionalDateTime(json, 'expires_at', 'expiresAt'),
  );
}

@freezed
abstract class AttachmentSignedUrlFailure with _$AttachmentSignedUrlFailure {
  const factory AttachmentSignedUrlFailure({
    String? id,
    String? filename,
    String? error,
    int? errorCode,
    String? message,
  }) = _AttachmentSignedUrlFailure;
}

extension AttachmentSignedUrlFailureX on AttachmentSignedUrlFailure {
  String? get displayMessage => error ?? message;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (filename != null) 'filename': filename,
      if (error != null) 'error': error,
      if (errorCode != null) 'error_code': errorCode,
      if (message != null) 'message': message,
    };
  }
}

AttachmentSignedUrlFailure attachmentSignedUrlFailureFromJson(
  Map<String, dynamic> json,
) {
  return AttachmentSignedUrlFailure(
    id: _readOptionalString(json, 'id', 'attachment_id'),
    filename: _readOptionalString(json, 'filename', 'object_key'),
    error: _readOptionalString(json, 'error', 'error'),
    errorCode: _readOptionalInt(json, 'error_code', 'errorCode'),
    message: _readOptionalString(json, 'message', 'message'),
  );
}

String _readRequiredString(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value == null) {
    throw FormatException('Missing required field `$primaryKey`');
  }
  final stringValue = value.toString();
  if (stringValue.isEmpty) {
    throw FormatException('Required field `$primaryKey` cannot be empty');
  }
  return stringValue;
}

String? _readOptionalString(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value == null) return null;
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}

int? _readOptionalInt(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value.toString());
  return parsed;
}

DateTime? _readOptionalDateTime(
  Map<String, dynamic> json,
  String primaryKey,
  String fallbackKey,
) {
  final value = json[primaryKey] ?? json[fallbackKey];
  if (value == null) return null;
  if (value is DateTime) return value;
  final stringValue = value.toString();
  if (stringValue.isEmpty) return null;
  return DateTime.tryParse(stringValue);
}
