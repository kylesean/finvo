/// Pure identicon generation, bit-compatible with the server-side generator
/// in `server/app/utils/identicon.py`.
///
/// SHA-256 of the seed (a user's UUID) drives everything:
/// - byte 0 selects the hue (0–360°), giving each user a unique base color;
/// - the next 15 bits fill the left three columns of a 5×5 grid; the right
///   two columns mirror them for a symmetric shape.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

const int identiconGridSize = 5;
const int identiconMirrorCols = 3;

/// The SHA-256 digest bytes of the seed.
List<int> identiconDigest(String seed) =>
    sha256.convert(utf8.encode(seed)).bytes;

/// The hue (0–360°) assigned to the seed.
double identiconHue(String seed) => identiconDigest(seed)[0] / 255.0 * 360.0;

/// The mirrored 5×5 pixel matrix (true = filled) for the seed.
List<List<bool>> identiconMatrix(String seed) {
  final digest = identiconDigest(seed);
  return List.generate(identiconGridSize, (row) {
    final line = List<bool>.filled(identiconGridSize, false);
    for (var col = 0; col < identiconMirrorCols; col++) {
      final index = row * identiconMirrorCols + col;
      final filled = (digest[1 + index ~/ 8] >> (index % 8)) & 1 == 1;
      line[col] = filled;
      line[identiconGridSize - 1 - col] = filled;
    }
    return line;
  });
}
