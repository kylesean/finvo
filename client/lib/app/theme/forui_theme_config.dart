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
      // forui >=0.17 changed the default text leading distribution from
      // proportional to even (see forui CHANGELOG). The font-weight values
      // are unchanged, but the two distributions place glyphs at different
      // vertical offsets within their line boxes. For bold CJK text (thick
      // strokes) that offset changes how strokes align with the pixel grid,
      // so headings render visibly heavier and sit at a different vertical
      // rhythm than before the upgrade. Restore the pre-upgrade proportional
      // distribution to keep the original look.
      TextStyle restyle(TextStyle style) => style.copyWith(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
        leadingDistribution: TextLeadingDistribution.proportional,
      );

      return FTypeface(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbacks,
        xs3: restyle(base.xs3),
        xs2: restyle(base.xs2),
        xs: restyle(base.xs),
        sm: restyle(base.sm),
        md: restyle(base.md),
        lg: restyle(base.lg),
        xl: restyle(base.xl),
        xl2: restyle(base.xl2),
        xl3: restyle(base.xl3),
        xl4: restyle(base.xl4),
        xl5: restyle(base.xl5),
        xl6: restyle(base.xl6),
        xl7: restyle(base.xl7),
        xl8: restyle(base.xl8),
      );
    }

    return baseTypography.copyWith(
      display: overrideTypeface(baseTypography.display),
      body: overrideTypeface(baseTypography.body),
    );
  }
}
