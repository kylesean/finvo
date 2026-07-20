import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:augo/i18n/strings.g.dart';

/// All supported Forui color palettes for the application theme.
enum AppThemePalette {
  zinc,
  slate,
  red,
  rose,
  orange,
  green,
  blue,
  yellow,
  violet,
}

extension AppThemePaletteX on AppThemePalette {
  /// Machine-friendly identifier.
  String get key => name;

  /// Localized-friendly display label.
  String get label {
    // Dynamic mapping via slang generated t object
    return switch (this) {
      AppThemePalette.zinc => t.appearance.palettes.zinc,
      AppThemePalette.slate => t.appearance.palettes.slate,
      AppThemePalette.red => t.appearance.palettes.red,
      AppThemePalette.rose => t.appearance.palettes.rose,
      AppThemePalette.orange => t.appearance.palettes.orange,
      AppThemePalette.green => t.appearance.palettes.green,
      AppThemePalette.blue => t.appearance.palettes.blue,
      AppThemePalette.yellow => t.appearance.palettes.yellow,
      AppThemePalette.violet => t.appearance.palettes.violet,
    };
  }

  /// Base Forui theme for the requested brightness.
  FThemeData resolveBaseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = _resolveColors(isDark);
    return FThemeData(colors: colors, touch: false);
  }

  FColors _resolveColors(bool isDark) {
    final base = isDark ? FColors.neutralDark : FColors.neutralLight;
    return switch (this) {
      AppThemePalette.zinc => base,
      AppThemePalette.slate => base.copyWith(
        primary: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        primaryForeground: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
      ),
      AppThemePalette.red => base.copyWith(
        primary: isDark ? const Color(0xFFFECACA) : const Color(0xFFDC2626),
        primaryForeground: isDark
            ? const Color(0xFF7F1D1D)
            : const Color(0xFFFEF2F2),
      ),
      AppThemePalette.rose => base.copyWith(
        primary: isDark ? const Color(0xFFFECDD3) : const Color(0xFFE11D48),
        primaryForeground: isDark
            ? const Color(0xFF881337)
            : const Color(0xFFFFF1F2),
      ),
      AppThemePalette.orange => base.copyWith(
        primary: isDark ? const Color(0xFFFED7AA) : const Color(0xFFEA580C),
        primaryForeground: isDark
            ? const Color(0xFF7C2D12)
            : const Color(0xFFFFF7ED),
      ),
      AppThemePalette.green => base.copyWith(
        primary: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF16A34A),
        primaryForeground: isDark
            ? const Color(0xFF14532D)
            : const Color(0xFFF0FDF4),
      ),
      AppThemePalette.blue => base.copyWith(
        primary: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF2563EB),
        primaryForeground: isDark
            ? const Color(0xFF1E3A5F)
            : const Color(0xFFEFF6FF),
      ),
      AppThemePalette.yellow => base.copyWith(
        primary: isDark ? const Color(0xFFFEF08A) : const Color(0xFFCA8A04),
        primaryForeground: isDark
            ? const Color(0xFF713F12)
            : const Color(0xFFFEFCE8),
      ),
      AppThemePalette.violet => base.copyWith(
        primary: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF7C3AED),
        primaryForeground: isDark
            ? const Color(0xFF4C1D95)
            : const Color(0xFFF5F3FF),
      ),
    };
  }

  /// Representative primary color for preview chips.
  Color get swatchColor => resolveBaseTheme(Brightness.light).colors.primary;
}
