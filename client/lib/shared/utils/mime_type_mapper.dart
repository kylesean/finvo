/// Maps file extensions to MIME types.
///
/// Centralized so the extension→MIME mapping is defined once instead of being
/// duplicated across file-upload and data-URI services (which previously had
/// drifted apart: data-URI knew about json/xml/7z while upload did not).
class MimeTypeMapper {
  MimeTypeMapper._();

  static const Map<String, String> _mimeByExtension = {
    // Image formats
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'svg': 'image/svg+xml',

    // Video formats
    'mp4': 'video/mp4',
    'avi': 'video/x-msvideo',
    'mov': 'video/quicktime',
    'wmv': 'video/x-ms-wmv',

    // Audio formats
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'm4a': 'audio/mp4',

    // Document formats
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'txt': 'text/plain',
    'json': 'application/json',
    'xml': 'application/xml',

    // Compressed files
    'zip': 'application/zip',
    'rar': 'application/vnd.rar',
    '7z': 'application/x-7z-compressed',
  };

  /// Returns the MIME type for [extension] (without a leading dot), or null if
  /// the extension is not recognized.
  static String? fromExtension(String extension) {
    return _mimeByExtension[extension.toLowerCase()];
  }

  /// Returns the MIME type for [fileName], or null if its extension is not
  /// recognized (callers that need auto-detection can pass null through).
  static String? fromFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return null;
    }
    return fromExtension(fileName.substring(dotIndex + 1));
  }

  /// Like [fromFileName] but returns [fallback] when the extension is unknown.
  static String fromFileNameOr(String fileName, String fallback) {
    return fromFileName(fileName) ?? fallback;
  }
}
