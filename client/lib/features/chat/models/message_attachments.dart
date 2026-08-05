import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'message_attachments.freezed.dart';

/// Metadata for a successfully uploaded attachment (UI-layer DTO, not JSON).
@freezed
abstract class UploadedAttachmentInfo with _$UploadedAttachmentInfo {
  const factory UploadedAttachmentInfo({
    required String id, // attachmentId
    required String attachmentId, // Explicit attachmentId field
    required String originalName,
    required String objectKey,
    required String uri, // File access URI
    required String mimeType,
    required double size,
    String? hash, // File hash value
  }) = _UploadedAttachmentInfo;
}

extension UploadedAttachmentInfoX on UploadedAttachmentInfo {
  int get sizeBytes => size % 1 == 0 ? size.toInt() : (size * 1024).round();

  /// Convert to AI attachment format (simplified version, only includes id and type)
  Map<String, dynamic> toAIAttachment() {
    // Determine attachment type based on mimeType
    String attachmentType = 'other';
    if (mimeType.startsWith('image/')) {
      attachmentType = 'image';
    } else if (mimeType.startsWith('text/')) {
      attachmentType = 'text';
    } else if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('word') ||
        mimeType.contains('excel') ||
        mimeType.contains('powerpoint')) {
      attachmentType = 'document';
    }

    return {'id': attachmentId, 'type': attachmentType};
  }
}

/// An attachment queued for sending with the next message (UI-layer DTO).
@freezed
abstract class PendingMessageAttachment with _$PendingMessageAttachment {
  const factory PendingMessageAttachment({
    required XFile file,
    required UploadedAttachmentInfo uploadInfo,
  }) = _PendingMessageAttachment;
}
