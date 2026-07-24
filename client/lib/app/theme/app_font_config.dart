import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide typography configuration designed for global users and open-source compliance.
///
/// This class provides a centralized way to manage fonts, integrating [GoogleFonts]
/// for high-quality Latin typography and robust system fallbacks for CJK and other scripts.
class AppFontConfig {
  AppFontConfig._();

  // ---------------------------------------------------------------------------
  // CJK font-weight compensation
  // ---------------------------------------------------------------------------
  //
  // Background: Flutter 3.38+ (Skia commit a918c0e) restructured the Android
  // font-fallback logic. On devices like Xiaomi, CJK glyphs now resolve to
  // NotoSansCJK-Regular (heavier strokes) instead of the previous MiSans-L3
  // (lighter). This is *correct* engine behaviour, not a bug, but it makes
  // Chinese text appear visually bolder at the same FontWeight value.
  //
  // Strategy: reduce the requested weight by one step for non-numeric display
  // text so that the *rendered* weight matches the original design intent.
  // Amount/numeric text keeps its original weight because digits are rendered
  // by Inter (Latin font) and are unaffected by CJK fallback.
  //
  // When a future Flutter/Skia release or a bundled CJK font eliminates this
  // discrepancy, simply set [cjkWeightCompensationEnabled] to false.
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
  /// Using 'Inter' as it's a modern, open-source standard for UI design.
  static final String primaryFontFamily = GoogleFonts.inter().fontFamily!;

  /// A comprehensive list of system font fallbacks to ensure correct rendering
  /// across iOS, Android, macOS, Windows, and Linux.
  static List<String> getGlobalFontFallbacks() {
    return [
      'Inter', // Latin (via Google Fonts)
      '.AppleSystemUIFont', // iOS/macOS San Francisco
      'PingFang SC', // iOS/macOS Simplified Chinese
      'Hiragino Sans GB', // macOS Chinese
      'Noto Sans CJK SC', // Android/Linux Chinese
      'Microsoft YaHei', // Windows Chinese
      'Heiti SC', // Older iOS Chinese
      'sans-serif', // General fallback
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
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: getGlobalFontFallbacks());
  }

  /// Resolve a [TextTheme] that applies global typography to all Material text styles.
  static TextTheme createGlobalTextTheme(TextTheme baseTheme) {
    return baseTheme.copyWith(
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
  }

  static TextStyle? _applyGlobalStyle(TextStyle? baseStyle) {
    if (baseStyle == null) return null;
    return baseStyle.copyWith(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: getGlobalFontFallbacks(),
    );
  }
}
