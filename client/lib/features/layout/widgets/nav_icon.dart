import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bottom navigation icon types matching the app's 5 tabs.
enum NavIconType { house, creditCard, botChat, chartPie, user }

/// A navigation icon that renders Tabler-style SVG paths inline via
/// [SvgPicture.string], with **two distinct path sets** per icon:
///
/// - **Outline** (inactive): stroke-based line drawing (`fill="none"`)
/// - **Filled** (active): solid geometry (`fill="currentColor"`, no stroke)
///
/// This mirrors the Tabler Icons design philosophy where filled variants are
/// NOT simply "outline + fill", but completely different path geometry designed
/// specifically for the solid state.
///
/// Zero new dependencies (reuses existing `flutter_svg`).
/// Zero asset files (SVG paths are Dart string constants).
/// Path data sourced from Tabler Icons (MIT License).
class NavIcon extends StatelessWidget {
  final NavIconType type;
  final bool active;
  final Color color;
  final double size;

  const NavIcon({
    super.key,
    required this.type,
    required this.active,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      active ? _filledSvg() : _outlineSvg(),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // ---------------------------------------------------------------------------
  // Outline SVGs (stroke-based, inactive state)
  // ---------------------------------------------------------------------------

  String _outlineSvg() {
    return '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
        'viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
        '$_outlineBody'
        '</svg>';
  }

  String get _outlineBody {
    switch (type) {
      case NavIconType.house:
        return '<path d="M5 12l-2 0l9 -9l9 9l-2 0"/>'
            '<path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-7"/>'
            '<path d="M9 21v-6a2 2 0 0 1 2 -2h2a2 2 0 0 1 2 2v6"/>';
      case NavIconType.creditCard:
        return '<path d="M3 8a3 3 0 0 1 3 -3h12a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-12a3 3 0 0 1 -3 -3l0 -8"/>'
            '<path d="M3 10l18 0"/>'
            '<path d="M7 15l.01 0"/>'
            '<path d="M11 15l2 0"/>';
      case NavIconType.botChat:
        return '<path d="M18 4a3 3 0 0 1 3 3v8a3 3 0 0 1 -3 3h-5l-5 3v-3h-2a3 3 0 0 1 -3 -3v-8a3 3 0 0 1 3 -3h12"/>'
            '<path d="M9.5 9h.01"/>'
            '<path d="M14.5 9h.01"/>'
            '<path d="M9.5 13a3.5 3.5 0 0 0 5 0"/>';
      case NavIconType.chartPie:
        return '<path d="M10 3.2a9 9 0 1 0 10.8 10.8a1 1 0 0 0 -1 -1h-6.8a2 2 0 0 1 -2 -2v-7a.9 .9 0 0 0 -1 -.8"/>'
            '<path d="M15 3.5a9 9 0 0 1 5.5 5.5h-4.5a1 1 0 0 1 -1 -1v-4.5"/>';
      case NavIconType.user:
        return '<path d="M8 7a4 4 0 1 0 8 0a4 4 0 0 0 -8 0"/>'
            '<path d="M6 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2"/>';
    }
  }

  // ---------------------------------------------------------------------------
  // Filled SVGs (solid geometry, active state)
  // Completely different path data from outline — NOT "outline + fill".
  // ---------------------------------------------------------------------------

  String _filledSvg() {
    return '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
        'viewBox="0 0 24 24" fill="currentColor">'
        '$_filledBody'
        '</svg>';
  }

  String get _filledBody {
    switch (type) {
      case NavIconType.house:
        return '<path d="M12.707 2.293l9 9c.63 .63 .184 1.707 -.707 1.707h-1v6a3 3 0 0 1 -3 3h-1v-7a3 3 0 0 0 -2.824 -2.995l-.176 -.005h-2a3 3 0 0 0 -3 3v7h-1a3 3 0 0 1 -3 -3v-6h-1c-.89 0 -1.337 -1.077 -.707 -1.707l9 -9a1 1 0 0 1 1.414 0m.293 11.707a1 1 0 0 1 1 1v7h-4v-7a1 1 0 0 1 .883 -.993l.117 -.007z"/>';
      case NavIconType.creditCard:
        return '<path d="M22 10v6a4 4 0 0 1 -4 4h-12a4 4 0 0 1 -4 -4v-6h20zm-14.99 4h-.01a1 1 0 1 0 .01 2a1 1 0 0 0 0 -2m5.99 0h-2a1 1 0 0 0 0 2h2a1 1 0 0 0 0 -2zm5 -10a4 4 0 0 1 4 4h-20a4 4 0 0 1 4 -4h12z"/>';
      case NavIconType.botChat:
        return '<path d="M18 3a4 4 0 0 1 4 4v8a4 4 0 0 1 -4 4h-4.724l-4.762 2.857a1 1 0 0 1 -1.508 -.743l-.006 -.114v-2h-1a4 4 0 0 1 -3.995 -3.8l-.005 -.2v-8a4 4 0 0 1 4 -4zm-2.8 9.286a1 1 0 0 0 -1.414 .014a2.5 2.5 0 0 1 -3.572 0a1 1 0 0 0 -1.428 1.4a4.5 4.5 0 0 0 6.428 0a1 1 0 0 0 -.014 -1.414m-5.69 -4.286h-.01a1 1 0 1 0 0 2h.01a1 1 0 0 0 0 -2m5 0h-.01a1 1 0 0 0 0 2h.01a1 1 0 0 0 0 -2"/>';
      case NavIconType.chartPie:
        return '<path d="M9.883 2.207a1.9 1.9 0 0 1 2.087 1.522l.025 .167l.005 .104v7a1 1 0 0 0 .883 .993l.117 .007h6.8a2 2 0 0 1 2 2a1 1 0 0 1 -.026 .226a10 10 0 1 1 -12.27 -11.933l.27 -.067l.11 -.02z"/>'
            '<path d="M14 3.5v5.5a1 1 0 0 0 1 1h5.5a1 1 0 0 0 .943 -1.332a10 10 0 0 0 -6.11 -6.111a1 1 0 0 0 -1.333 .943z"/>';
      case NavIconType.user:
        return '<path d="M12 2a5 5 0 1 1 -5 5l.005 -.217a5 5 0 0 1 4.995 -4.783z"/>'
            '<path d="M14 14a5 5 0 0 1 5 5v1a2 2 0 0 1 -2 2h-10a2 2 0 0 1 -2 -2v-1a5 5 0 0 1 5 -5h4z"/>';
    }
  }
}
