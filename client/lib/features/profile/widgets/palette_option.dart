import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A selectable palette preview tile.
///
/// Shared by [appearance_settings_page] and [theme_switcher] to avoid
/// duplicating the palette preview rendering logic.
class PaletteOption extends StatelessWidget {
  const PaletteOption({
    super.key,
    required this.palette,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final lightTheme = palette.resolveBaseTheme(Brightness.light);
    final darkTheme = palette.resolveBaseTheme(Brightness.dark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: palette.swatchColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    palette.label,
                    style: AppTextStyles.listTrailing(theme),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: colors.primary),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightTheme.colors.primary,
                      darkTheme.colors.primary,
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${t.appearance.light} / ${t.appearance.dark}',
              style: AppTextStyles.detailLabel(theme),
            ),
          ],
        ),
      ),
    );
  }
}
