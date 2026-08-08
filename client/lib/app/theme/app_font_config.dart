import 'dart:io';
import 'dart:ui' show loadFontFromList;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

/// App-wide typography configuration designed for global users and open-source compliance.
///
/// This class provides a centralized way to manage fonts. The primary Latin font,
/// Inter, is bundled with the `forui` package (registered under the family name
/// "Inter"), and we layer robust system fallbacks for CJK and other scripts.
class AppFontConfig {
  AppFontConfig._();

  // ---------------------------------------------------------------------------
  // CJK font-weight compensation (fallback layer)
  // ---------------------------------------------------------------------------
  //
  // Primary fix: `chinese_font_library` injects the device-native CJK font
  // (e.g. MiSans on Xiaomi) with correct weight mappings via useSystemChineseFont().
  //
  // These constants serve as a SECONDARY fallback for:
  //   1. Forui typography (theme.typography.*) which bypasses Material TextTheme
  //   2. Devices where the plugin fails to locate the system CJK font file
  //
  // Background: Flutter 3.38+ (Skia commit a918c0e) restructured the Android
  // font-fallback logic. On devices like Xiaomi, CJK glyphs may resolve to
  // NotoSansCJK-Regular (heavier strokes) instead of MiSans-L3 (lighter).
  //
  // When the plugin fully covers all text paths, set
  // [cjkWeightCompensationEnabled] to false to remove the compensation.
  // ---------------------------------------------------------------------------

  /// Master switch for CJK weight compensation.
  /// Set to `false` once the underlying font-fallback discrepancy is resolved
  /// (e.g. by bundling a custom CJK font or a future Skia behaviour change).
  static const bool cjkWeightCompensationEnabled = true;

  /// Compensated weight for prominent headings (originally w700/bold).
  /// Renders as ~w600 visual weight under NotoSansCJK fallback.
  static const FontWeight headingBold = cjkWeightCompensationEnabled
      ? FontWeight.w600
      : FontWeight.w700;

  /// Compensated weight for section titles / emphasized labels (originally w600).
  /// Renders as ~w500 visual weight under NotoSansCJK fallback.
  static const FontWeight titleSemibold = cjkWeightCompensationEnabled
      ? FontWeight.w500
      : FontWeight.w600;

  /// Compensated weight for medium-emphasis text (originally w500).
  /// Renders as ~w400 visual weight under NotoSansCJK fallback.
  static const FontWeight bodyMedium = cjkWeightCompensationEnabled
      ? FontWeight.w400
      : FontWeight.w500;

  /// Non-compensated bold for numeric/amount display (digits use Inter, unaffected).
  static const FontWeight amountBold = FontWeight.w700;

  /// The primary font family for Latin characters.
  /// Inter is bundled with the `forui` package under this family name, so no
  /// runtime network fetch is needed.
  static const String primaryFontFamily = 'Inter';

  /// A comprehensive list of system font fallbacks to ensure correct rendering
  /// across iOS, Android, macOS, Windows, and Linux.
  ///
  /// Note: entries already covered by chinese_font_library's own fallback list
  /// (e.g. PingFang SC, Microsoft YaHei, sans-serif) are omitted here to avoid
  /// duplication. The plugin appends its list after ours at runtime.
  static List<String> getGlobalFontFallbacks() {
    return [
      'Inter', // Latin (via Google Fonts)
      _miSansFamily, // Xiaomi MiSans (directly loaded via preloadMiSans)
      'Hiragino Sans GB', // macOS Chinese (not in plugin list)
      'Noto Sans CJK SC', // Stock Android / Linux Chinese
      'Heiti SC', // Older iOS Chinese (not in plugin list)
    ];
  }

  /// Create a [TextStyle] that follows global typography best practices.
  static TextStyle createGlobalTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: getGlobalFontFallbacks());
  }

  /// Resolve a [TextTheme] that applies global typography to all Material text styles.
  ///
  /// Applies [primaryFontFamily] (Inter) for Latin characters, then delegates to
  /// `chinese_font_library` to inject the device-native CJK font (e.g. MiSans on
  /// Xiaomi) with correct multi-weight support, bypassing Skia's fallback selection.
  ///
  /// On web the plugin's system-font discovery is skipped: it probes filesystem
  /// fonts via `dart:io` (unsupported on web) and the browser already resolves
  /// Chinese text through the `fontFamilyFallback` list.
  static TextTheme createGlobalTextTheme(TextTheme baseTheme) {
    final theme = baseTheme.copyWith(
      displayLarge: _applyGlobalStyle(baseTheme.displayLarge),
      displayMedium: _applyGlobalStyle(baseTheme.displayMedium),
      displaySmall: _applyGlobalStyle(baseTheme.displaySmall),
      headlineLarge: _applyGlobalStyle(baseTheme.headlineLarge),
      headlineMedium: _applyGlobalStyle(baseTheme.headlineMedium),
      headlineSmall: _applyGlobalStyle(baseTheme.headlineSmall),
      titleLarge: _applyGlobalStyle(baseTheme.titleLarge),
      titleMedium: _applyGlobalStyle(baseTheme.titleMedium),
      titleSmall: _applyGlobalStyle(baseTheme.titleSmall),
      bodyLarge: _applyGlobalStyle(baseTheme.bodyLarge),
      bodyMedium: _applyGlobalStyle(baseTheme.bodyMedium),
      bodySmall: _applyGlobalStyle(baseTheme.bodySmall),
      labelLarge: _applyGlobalStyle(baseTheme.labelLarge),
      labelMedium: _applyGlobalStyle(baseTheme.labelMedium),
      labelSmall: _applyGlobalStyle(baseTheme.labelSmall),
    );
    if (kIsWeb) {
      // chinese_font_library's useSystemChineseFont() probes system font files
      // through dart:io, which throws on web. The browser fonts are already in
      // the fallback chain, so no device-native font injection is needed here.
      return theme;
    }
    // Inject device-native CJK font (MiSans/PingFang/etc.) with proper weight
    // mappings so Chinese text renders with the OEM-intended visual weight.
    // Uses the TextStyle extension (append semantics) to preserve our fallbacks.
    return TextTheme(
      displayLarge: theme.displayLarge?.useSystemChineseFont(),
      displayMedium: theme.displayMedium?.useSystemChineseFont(),
      displaySmall: theme.displaySmall?.useSystemChineseFont(),
      headlineLarge: theme.headlineLarge?.useSystemChineseFont(),
      headlineMedium: theme.headlineMedium?.useSystemChineseFont(),
      headlineSmall: theme.headlineSmall?.useSystemChineseFont(),
      titleLarge: theme.titleLarge?.useSystemChineseFont(),
      titleMedium: theme.titleMedium?.useSystemChineseFont(),
      titleSmall: theme.titleSmall?.useSystemChineseFont(),
      bodyLarge: theme.bodyLarge?.useSystemChineseFont(),
      bodyMedium: theme.bodyMedium?.useSystemChineseFont(),
      bodySmall: theme.bodySmall?.useSystemChineseFont(),
      labelLarge: theme.labelLarge?.useSystemChineseFont(),
      labelMedium: theme.labelMedium?.useSystemChineseFont(),
      labelSmall: theme.labelSmall?.useSystemChineseFont(),
    );
  }

  static TextStyle? _applyGlobalStyle(TextStyle? baseStyle) {
    if (baseStyle == null) return null;
    return baseStyle.copyWith(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: getGlobalFontFallbacks(),
    );
  }

  // ---------------------------------------------------------------------------
  // Xiaomi MiSans direct-load (fixes plugin's name-based lookup failure)
  // ---------------------------------------------------------------------------
  //
  // The plugin adds 'miui'/'mipro' as family names, but on newer HyperOS the
  // font may be registered under a different name in fonts.xml. We bypass this
  // by loading the font file directly, similar to how the plugin handles Vivo.
  // ---------------------------------------------------------------------------

  /// Family name we register for the directly-loaded MiSans font.
  static const String _miSansFamily = 'MiSans';

  /// Known paths for MiSans font files on Xiaomi devices (HyperOS/MIUI).
  /// MiSansVF.ttf is the variable font with wght axis (preferred).
  static const List<String> _miSansPaths = [
    '/system/fonts/MiSansVF.ttf', // Variable font (all weights via wght axis)
    '/product/fonts/MiSansC_3.005.ttf', // Product partition fallback
    '/system/fonts/MiSansL3.otf', // Static L3 (thin) as last resort
  ];

  /// Whether MiSans has been successfully loaded.
  static bool miSansLoaded = false;

  /// Attempt to load MiSans from the device filesystem.
  /// Call once at app startup (before first frame). Non-blocking on failure.
  ///
  /// Note: We skip [File.exists()] and directly attempt [File.readAsBytes()]
  /// because on some Android versions SELinux may deny stat() but allow read(),
  /// or the exists() check may return false for /system/fonts paths from the
  /// app sandbox. The actual read attempt gives us a concrete error message.
  static Future<void> preloadMiSans() async {
    if (miSansLoaded) return;
    // Platform.isAndroid would throw UnsupportedError on web.
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[AppFontConfig] preloadMiSans: skipped (not Android)');
      return;
    }
    for (final path in _miSansPaths) {
      debugPrint('[AppFontConfig] preloadMiSans: trying $path');
      try {
        final bytes = await File(path).readAsBytes();
        debugPrint(
          '[AppFontConfig] preloadMiSans: read ${bytes.length} bytes from $path',
        );
        await loadFontFromList(bytes, fontFamily: _miSansFamily);
        miSansLoaded = true;
        debugPrint(
          '[AppFontConfig] preloadMiSans: SUCCESS - registered as "$_miSansFamily"',
        );
        return;
      } catch (e) {
        debugPrint('[AppFontConfig] preloadMiSans: failed for $path → $e');
      }
    }
    debugPrint(
      '[AppFontConfig] preloadMiSans: all paths failed, will use system fallback',
    );
  }
}
