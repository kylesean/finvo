import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/features/chat/models/media_file.dart';
import 'package:finvo/features/chat/models/media_upload_exception.dart';
import 'package:finvo/shared/utils/format_file_size.dart' as file_size;

/// Media file validation service
/// Provides file size validation, format recognition, and utility methods
class MediaValidationService {
  /// Maximum file size limit: 10MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Supported image formats
  static const Set<String> supportedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  };

  /// Supported file formats (other files besides images)
  static const Set<String> supportedFileExtensions = {
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'zip',
    'rar',
    '7z',
    'mp3',
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
  };

  /// Validate if file meets requirements
  ///
  /// Checks if file size exceeds limit and if file format is supported
  /// Returns [ValidationResult] containing validation result and error information
  ///
  /// Throws: [MediaUploadException] when validation fails
  static ValidationResult validateFile(XFile file) {
    try {
      // Check file size
      _validateFileSizeThrows(file);

      // Check file format
      _validateFileFormatThrows(file);

      return const ValidationResult(isValid: true);
    } on MediaUploadException {
      rethrow;
    } catch (e) {
      throw MediaUploadException.validationError(
        fileName: file.name,
        reason: e.toString(),
      );
    }
  }

  /// Validate if file meets requirements (compatibility method)
  ///
  /// Checks if file size exceeds limit and if file format is supported
  /// Returns [ValidationResult] containing validation result and error information
  static ValidationResult validateFileCompat(XFile file) {
    try {
      validateFile(file);
      return const ValidationResult(isValid: true);
    } on MediaUploadException catch (e) {
      return ValidationResult(isValid: false, errorMessage: e.message);
    }
  }

  /// Validate file size (throw exception version)
  ///
  /// Throws: [MediaUploadException] when file size exceeds limit or read fails
  static void _validateFileSizeThrows(XFile file) {
    try {
      final fileSize = File(file.path).lengthSync();
      validateFileSizeBytesThrows(fileSize, file.name);
    } catch (e) {
      if (e is MediaUploadException) {
        rethrow;
      }
      throw MediaUploadException.fileReadError(
        fileName: file.name,
        originalError: e,
      );
    }
  }

  /// Validate file size by bytes (throw exception version)
  ///
  /// [fileSize] File size in bytes
  /// [fileName] File name (optional)
  ///
  /// Throws: [MediaUploadException] when file size exceeds limit
  static void validateFileSizeBytesThrows(int fileSize, [String? fileName]) {
    if (fileSize > maxFileSizeBytes) {
      throw MediaUploadException.fileSizeExceeded(
        actualSize: fileSize,
        maxSize: maxFileSizeBytes,
        fileName: fileName,
      );
    }
  }

  /// Validate file format (throw exception version)
  ///
  /// Throws: [MediaUploadException] when file format is not supported
  static void _validateFileFormatThrows(XFile file) {
    final extension = getFileExtension(file.name);
    validateFileFormatByExtensionThrows(extension, file.name);
  }

  /// Validate file format by extension (throw exception version)
  ///
  /// [extension] File extension
  /// [fileName] File name (optional)
  ///
  /// Throws: [MediaUploadException] when file format is not supported
  static void validateFileFormatByExtensionThrows(
    String? extension, [
    String? fileName,
  ]) {
    if (extension == null || extension.isEmpty) {
      throw MediaUploadException.validationError(
        fileName: fileName ?? 'Unknown file',
        reason: 'Unable to recognize file format',
      );
    }

    final isSupported =
        supportedImageExtensions.contains(extension) ||
        supportedFileExtensions.contains(extension);

    if (!isSupported) {
      throw MediaUploadException.unsupportedFormat(
        extension: extension,
        fileName: fileName,
        supportedFormats: getSupportedFormatsString(),
      );
    }
  }

  /// Determine if file is image format
  ///
  /// Determine if file is supported image format based on extension
  /// Returns true if image, false if not
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    if (extension == null) return false;

    return supportedImageExtensions.contains(extension);
  }

  /// Get file extension
  ///
  /// Extract extension from filename and convert to lowercase
  /// Returns extension string, or null if no extension
  static String? getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
      return null;
    }

    return fileName.substring(lastDotIndex + 1).toLowerCase();
  }

  /// Format file size as readable string
  ///
  /// Convert bytes to KB, MB, GB, etc.
  /// Returns formatted string, e.g. "1.5 MB"
  static String formatFileSize(int bytes) => file_size.formatFileSize(bytes);

  /// Determine media type based on file information
  ///
  /// Determine if file is image or regular file based on extension
  /// Returns corresponding [MediaType]
  static MediaType determineMediaType(String fileName) {
    return isImageFile(fileName) ? MediaType.image : MediaType.file;
  }

  /// Get list of all supported file formats
  ///
  /// Returns string containing all supported formats for error prompts
  static String getSupportedFormatsString() {
    final allFormats = <String>[
      ...supportedImageExtensions,
      ...supportedFileExtensions,
    ];

    allFormats.sort();
    return allFormats.map((ext) => '.$ext').join(', ');
  }
}
