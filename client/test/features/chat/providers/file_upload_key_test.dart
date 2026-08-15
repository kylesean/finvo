import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/features/chat/providers/chat_input_state.dart';

void main() {
  group('fileUploadKey (CHAT-02)', () {
    test('uses the real path when present (native platforms)', () {
      const path = '/tmp/a.png';
      final file = XFile(path);
      expect(fileUploadKey(file), path);
    });

    test('pathless web files get distinct, stable keys', () {
      final a = XFile.fromData(Uint8List.fromList([1, 2]), name: 'a.png');
      final b = XFile.fromData(Uint8List.fromList([3, 4]), name: 'b.png');
      final keyA1 = fileUploadKey(a);
      final keyA2 = fileUploadKey(a);
      final keyB = fileUploadKey(b);
      expect(keyA1, keyA2); // stable for the same instance
      expect(keyA1, isNot(keyB)); // distinct per instance
      expect(keyA1, isNot('')); // never the empty-string collision
      expect(keyB, isNot(''));
    });

    test('pathless and pathed files never collide', () {
      final web = XFile.fromData(Uint8List.fromList([9]), name: 'a.png');
      final native = XFile('different/real/path.png');
      expect(fileUploadKey(web), isNot(fileUploadKey(native)));
    });
  });
}
