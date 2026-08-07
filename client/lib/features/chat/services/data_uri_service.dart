// features/chat/services/data_uri_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

import 'package:finvo/features/chat/models/message_attachments.dart';
import 'package:finvo/shared/utils/mime_type_mapper.dart';
import 'package:finvo/shared/utils/format_file_size.dart' as file_size;

final _logger = Logger('DataUriService');

/// DataUri format media file wrapper
class DataUriFile {
  final String dataUri;
  final String originalName;
  final String mimeType;
  final int size;
  final String? objectKey;
  final String? attachmentId; // Attachment ID returned by backend
  final String? uri; // File access URI returned by backend
  final String? hash; // File hash value

  const DataUriFile({
    required this.dataUri,
    required this.originalName,
    required this.mimeType,
    required this.size,
    this.objectKey,
    this.attachmentId,
    this.uri,
    this.hash,
  });

  DataUriFile copyWith({
    String? dataUri,
    String? originalName,
    String? mimeType,
    int? size,
    String? objectKey,
    String? attachmentId,
    String? uri,
    String? hash,
  }) {
    return DataUriFile(
      dataUri: dataUri ?? this.dataUri,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      objectKey: objectKey ?? this.objectKey,
      attachmentId: attachmentId ?? this.attachmentId,
      uri: uri ?? this.uri,
      hash: hash ?? this.hash,
    );
  }

  factory DataUriFile.fromJson(Map<String, dynamic> json) {
    return DataUriFile(
      dataUri: json['dataUri'] as String,
      originalName: json['originalName'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      objectKey: json['objectKey'] as String?,
      attachmentId: json['attachmentId'] as String?,
      uri: json['uri'] as String?,
      hash: json['hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataUri': dataUri,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      if (objectKey != null) 'objectKey': objectKey,
      if (attachmentId != null) 'attachmentId': attachmentId,
      if (uri != null) 'uri': uri,
      if (hash != null) 'hash': hash,
    };
  }
}

/// DataUri conversion utility class
/// Responsible for converting local files to dataUri format
class DataUriService {
  /// Convert XFile list to DataUri format
  static Future<List<DataUriFile>> convertFilesToDataUri(
    List<XFile> files, {
    List<UploadedAttachmentInfo?>? uploadedInfos,
  }) async {
    final List<DataUriFile> dataUriFiles = [];

    for (final entry in files.asMap().entries) {
      final index = entry.key;
      final file = entry.value;
      try {
        final uploadInfo = uploadedInfos != null && index < uploadedInfos.length
            ? uploadedInfos[index]
            : null;
        final dataUriFile = await _convertSingleFileToDataUri(file, uploadInfo);
        dataUriFiles.add(dataUriFile);
        _logger.info('Successfully converted file to DataUri: ${file.name}');
      } catch (e) {
        _logger.warning(
          'Failed to convert file to DataUri: ${file.name}, reason: $e',
        );
        // Single file failure does not affect other files
      }
    }

    return dataUriFiles;
  }

  /// Convert single file to DataUri format
  static Future<DataUriFile> _convertSingleFileToDataUri(
    XFile file,
    UploadedAttachmentInfo? uploadedInfo,
  ) async {
    // Read file byte data
    final Uint8List bytes = await file.readAsBytes();

    // Get MIME type
    final String mimeType =
        uploadedInfo?.mimeType ??
        MimeTypeMapper.fromFileNameOr(file.name, 'application/octet-stream');

    // Convert to base64
    final String base64String = base64Encode(bytes);

    // Build dataUri format: data:[<mediatype>][;base64],<data>
    final String dataUri = 'data:$mimeType;base64,$base64String';

    final int size = uploadedInfo?.sizeBytes ?? bytes.length;

    return DataUriFile(
      dataUri: dataUri,
      originalName: file.name,
      mimeType: mimeType,
      size: size,
      objectKey: uploadedInfo?.objectKey,
      attachmentId: uploadedInfo?.attachmentId,
      uri: uploadedInfo?.uri,
      hash: uploadedInfo?.hash,
    );
  }

  /// Determine if file is image type
  static bool isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'svg',
    ].contains(extension);
  }

  /// Determine if file is document type
  static bool isDocumentFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'json',
      'xml',
    ].contains(extension);
  }

  /// Determine if file is video type
  static bool isVideoFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['mp4', 'avi', 'mov', 'wmv'].contains(extension);
  }

  /// Determine if file is audio type
  static bool isAudioFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['mp3', 'wav', 'm4a'].contains(extension);
  }

  /// Get file category label
  static String getFileCategory(String fileName) {
    if (isImageFile(fileName)) return 'image';
    if (isDocumentFile(fileName)) return 'document';
    if (isVideoFile(fileName)) return 'video';
    if (isAudioFile(fileName)) return 'audio';
    return 'other';
  }

  /// Format file size as readable string
  static String formatFileSize(int bytes) => file_size.formatFileSize(bytes);
}
