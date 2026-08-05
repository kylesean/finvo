import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/models/media_file.dart';
import 'package:finvo/features/chat/services/media_thumbnail_service.dart';

void main() {
  setUp(() {
    MediaThumbnailService.clearCache();
  });

  tearDown(() {
    MediaThumbnailService.clearCache();
  });

  group('MediaThumbnailService', () {
    test('generateThumbnail returns null for non-image files', () async {
      const file = MediaFile(
        id: 'doc-1',
        name: 'a.pdf',
        path: '/tmp/a.pdf',
        size: 100,
        type: MediaType.file,
      );

      final thumbnail = await MediaThumbnailService.generateThumbnail(file);
      expect(thumbnail, isNull);
    });

    test('generateThumbnails skips non-image files', () async {
      final files = [
        const MediaFile(
          id: 'img-1',
          name: 'a.png',
          path: '/tmp/a.png',
          size: 100,
          type: MediaType.image,
        ),
        const MediaFile(
          id: 'doc-1',
          name: 'a.pdf',
          path: '/tmp/a.pdf',
          size: 100,
          type: MediaType.file,
        ),
      ];

      final successIds = await MediaThumbnailService.generateThumbnails(files);
      // The image file has no real file on disk, so only non-failures accepted.
      expect(successIds, everyElement(isNot('doc-1')));
    });

    test(
      'compressImage falls back to original bytes on decode failure',
      () async {
        final garbage = Uint8List.fromList(List.filled(64, 0x00));
        final result = await MediaThumbnailService.compressImage(
          garbage,
          maxWidth: 320,
          maxHeight: 240,
        );
        // Decoding garbage fails, so the original bytes are returned unchanged.
        expect(result, equals(garbage));
      },
    );

    test('cache stats reflect empty cache after clear', () {
      final stats = MediaThumbnailService.getCacheStats();
      expect(stats['count'], 0);
      expect(stats['size'], 0);
    });

    test('removeCacheForFile on empty cache is a no-op', () {
      MediaThumbnailService.removeCacheForFile('missing');
      expect(MediaThumbnailService.getCacheCount(), 0);
    });
  });
}
