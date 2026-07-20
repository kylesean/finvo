import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'app_theme_palette.dart';
import 'app_font_config.dart';
import 'app_semantic_colors.dart';

/// Forui theme configuration helpers with global typography adjustments.
class ForuiThemeConfig {
  /// Resolve an [FThemeData] for the given palette and brightness.
  static FThemeData resolve({
    required AppThemePalette palette,
    required Brightness brightness,
  }) {
    final baseTheme = palette.resolveBaseTheme(brightness);
    final typography = _createGlobalTypography(
      baseTypography: baseTheme.typography,
    );

    return FThemeData(
      colors: baseTheme.colors,
      touch: false,
      typography: typography,
      extensions: [
        brightness == Brightness.dark
            ? AppSemanticColors.dark
            : AppSemanticColors.light,
      ],
    );
  }

  static FTypography _createGlobalTypography({
    required FTypography baseTypography,
  }) {
    final fontFamily = AppFontConfig.primaryFontFamily;
    final fallbacks = AppFontConfig.getGlobalFontFallbacks();

    FTypeface overrideTypeface(FTypeface base) {
      return FTypeface(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
        xs3: base.xs3.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xs2: base.xs2.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xs: base.xs.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        sm: base.sm.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        md: base.md.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        lg: base.lg.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl: base.xl.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl2: base.xl2.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl3: base.xl3.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl4: base.xl4.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl5: base.xl5.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl6: base.xl6.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl7: base.xl7.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
        xl8: base.xl8.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbacks,
        ),
      );
    }

    return baseTypography.copyWith(
      display: overrideTypeface(baseTypography.display),
      body: overrideTypeface(baseTypography.body),
    );
  }
}
