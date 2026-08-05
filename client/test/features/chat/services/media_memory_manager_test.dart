import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/models/media_file.dart';
import 'package:finvo/features/chat/services/media_memory_manager.dart';

void main() {
  final manager = MediaMemoryManager.instance;

  MediaFile mediaFile(String id, {int size = 10}) => MediaFile(
    id: id,
    name: '$id.png',
    path: '/tmp/$id.png',
    size: size,
    type: MediaType.image,
  );

  setUp(() {
    // Reset singleton state between tests.
    manager.clearAllMediaFiles();
  });

  tearDown(() {
    manager.clearAllMediaFiles();
  });

  group('MediaMemoryManager', () {
    test('registerMediaFile tracks a file and its memory', () {
      final bytes = Uint8List.fromList(List.filled(100, 1));
      manager.registerMediaFile(
        MediaFileWithBytes(mediaFile: mediaFile('a'), bytes: bytes),
      );

      expect(manager.getMediaFile('a'), isNotNull);
      expect(manager.getMemoryStats()['activeMediaFiles'], 1);
      expect(manager.getAllMediaFiles().length, 1);
    });

    test('re-registering the same id does not duplicate it', () {
      manager.registerActiveMedia(mediaFile('a'));
      manager.registerActiveMedia(mediaFile('a'));

      expect(manager.getAllMediaFiles().length, 1);
      expect(manager.getMemoryStats()['activeMediaFiles'], 1);
    });

    test('unregisterMediaFile removes the file and its memory', () {
      final bytes = Uint8List.fromList(List.filled(100, 1));
      manager.registerMediaFile(
        MediaFileWithBytes(mediaFile: mediaFile('a'), bytes: bytes),
      );
      manager.unregisterMediaFile('a');

      expect(manager.getMediaFile('a'), isNull);
      expect(manager.getAllMediaFiles().length, 0);
    });

    test('registerMediaFiles batch registers all files', () {
      manager.registerMediaFiles(
        List.generate(
          3,
          (i) => MediaFileWithBytes(mediaFile: mediaFile('f$i')),
        ),
      );

      expect(manager.getAllMediaFiles().length, 3);
      expect(manager.getMemoryStats()['activeMediaFiles'], 3);
    });

    test('clearAllMediaFiles empties the manager', () {
      manager.registerMediaFiles(
        List.generate(
          3,
          (i) => MediaFileWithBytes(mediaFile: mediaFile('f$i')),
        ),
      );
      manager.clearAllMediaFiles();

      expect(manager.getAllMediaFiles().length, 0);
      expect(manager.getMemoryStats()['activeMediaFiles'], 0);
    });

    test('unregistering an unknown id is a no-op', () {
      // Should not throw and should not corrupt state.
      manager.unregisterMediaFile('does-not-exist');
      expect(manager.getAllMediaFiles().length, 0);
    });
  });
}
