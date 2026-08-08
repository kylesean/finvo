import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finvo/features/chat/models/media_upload_exception.dart';

/// Media picker service
/// Uses built-in permission handling of image_picker and file_picker
class MediaPickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Take photo with camera
  static Future<XFile> takePhoto() async {
    try {
      // Linux/Windows desktop platforms do not have native camera picker support in image_picker.
      // Fallback gracefully to picking an image file via FilePicker instead of throwing an UnimplementedError.
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result == null ||
            result.files.isEmpty ||
            result.files.first.path == null) {
          throw MediaUploadException.noFilesSelected();
        }
        return XFile(result.files.first.path!);
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        throw MediaUploadException.noFilesSelected();
      }

      return image;
    } catch (e) {
      if (e is MediaUploadException) {
        rethrow;
      }
      throw MediaUploadException.unknownError(originalError: e);
    }
  }

  /// Select photos from gallery
  static Future<List<XFile>> pickGalleryPhotos({int maxImages = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Limit selection quantity
      if (images.length > maxImages) {
        return images.take(maxImages).toList();
      }

      return images;
    } catch (e) {
      throw MediaUploadException.unknownError(originalError: e);
    }
  }

  /// Select files
  static Future<List<XFile>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      // Convert to XFile list
      final List<XFile> files = [];
      for (final platformFile in result.files) {
        final path = platformFile.path;
        if (path != null && path.isNotEmpty) {
          files.add(XFile(path));
        } else if (platformFile.bytes != null) {
          // Web: PlatformFile.path is null; the bytes live in `bytes`.
          // Without this branch, every selected file was silently dropped
          // on web platforms.
          files.add(
            XFile.fromData(
              platformFile.bytes!,
              name: platformFile.name,
              mimeType: platformFile.extension != null
                  ? 'application/${platformFile.extension}'
                  : null,
            ),
          );
        } else {
          debugPrint(
            'MediaPickerService: skipping file "${platformFile.name}" '
            '(no path and no bytes)',
          );
        }
      }

      return files;
    } catch (e) {
      throw MediaUploadException.unknownError(originalError: e);
    }
  }
}
