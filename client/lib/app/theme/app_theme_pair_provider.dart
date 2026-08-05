import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/app/theme/forui_theme_config.dart';
import 'package:finvo/app/theme/theme_palette_provider.dart';

/// Resolved light/dark theme pair.
typedef AppThemePair = ({
  ThemeData materialLight,
  ThemeData materialDark,
  FThemeData foruiLight,
  FThemeData foruiDark,
});

/// Cached theme resolution. Recomputes only when the palette changes instead
/// of on every widget build.
final appThemePairProvider = Provider<AppThemePair>((ref) {
  final palette = ref.watch(themePaletteProvider);

  final foruiLightTheme = ForuiThemeConfig.resolve(
    palette: palette,
    brightness: Brightness.light,
  );
  final foruiDarkTheme = ForuiThemeConfig.resolve(
    palette: palette,
    brightness: Brightness.dark,
  );

  final materialLightTheme = foruiLightTheme
      .toApproximateMaterialTheme()
      .copyWith(
        textTheme: AppFontConfig.createGlobalTextTheme(
          ThemeData.light().textTheme,
        ),
        // Set SnackBar default style: fixed behavior (no rounded corners,
        // bottom display)
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.fixed,
        ),
      );
  final materialDarkTheme = foruiDarkTheme
      .toApproximateMaterialTheme()
      .copyWith(
        textTheme: AppFontConfig.createGlobalTextTheme(
          ThemeData.dark().textTheme,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.fixed,
        ),
      );

  return (
    materialLight: materialLightTheme,
    materialDark: materialDarkTheme,
    foruiLight: foruiLightTheme,
    foruiDark: foruiDarkTheme,
  );
});
