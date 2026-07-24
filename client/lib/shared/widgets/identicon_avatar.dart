import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../utils/identicon.dart';

/// A deterministic GitHub-style identicon avatar.
///
/// Renders a symmetric 5×5 pixel pattern derived from [seed] (the user's
/// UUID), in the style of GitHub's identicons:
///
/// - SHA-256 of the seed picks a unique hue, so every user gets their own
///   base color.
/// - The following 15 bits fill the left three grid columns; the right two
///   columns mirror them for a symmetric, badge-like shape.
///
/// The bit layout and light-theme color formula are bit-compatible with the
/// server-side generator in `server/app/utils/identicon.py`, so the same
/// user renders an identical pattern on the server (PNG endpoint) and
/// on-device — including offline, since no network is needed.
///
/// The background uses the forui theme's muted color (a gray-white in light
/// themes), so the widget adapts to light/dark mode and the selected
/// palette; the foreground lightness is adjusted to keep contrast on dark
/// backgrounds.
class IdenticonAvatar extends StatelessWidget {
  /// The value to hash — a user's UUID string.
  final String seed;

  /// The square size in logical pixels.
  final double size;

  /// The background color. Defaults to [FColors.muted].
  final Color? backgroundColor;

  const IdenticonAvatar({
    required this.seed,
    this.size = 40,
    this.backgroundColor,
    super.key,
  });

  // Foreground saturation/value, matching the server generator for light
  // backgrounds; value is raised on dark backgrounds to keep contrast.
  static const double _saturation = 0.60;
  static const double _lightValue = 0.55;
  static const double _darkValue = 0.78;
  static const double _darkSaturation = 0.55;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? context.theme.colors.muted;
    final hue = identiconHue(seed);
    final matrix = identiconMatrix(seed);

    final onLightBackground = background.computeLuminance() > 0.5;
    final foreground = HSVColor.fromAHSV(
      1.0,
      hue,
      onLightBackground ? _saturation : _darkSaturation,
      onLightBackground ? _lightValue : _darkValue,
    ).toColor();

    return CustomPaint(
      size: Size.square(size),
      painter: _IdenticonPainter(matrix, foreground, background),
    );
  }
}

class _IdenticonPainter extends CustomPainter {
  final List<List<bool>> matrix;
  final Color foreground;
  final Color background;

  _IdenticonPainter(this.matrix, this.foreground, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / identiconGridSize;

    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final paint = Paint()..color = foreground;
    for (var row = 0; row < matrix.length; row++) {
      for (var col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col]) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_IdenticonPainter oldDelegate) =>
      !identical(oldDelegate.matrix, matrix) ||
      oldDelegate.foreground != foreground ||
      oldDelegate.background != background;
}
