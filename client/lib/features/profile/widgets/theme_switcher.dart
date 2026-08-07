import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/theme_notifier.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/app/theme/theme_palette_provider.dart';
import 'package:finvo/app/theme/theme_provider.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/profile/widgets/theme_preview.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/profile/widgets/palette_option.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final selectedPalette = ref.watch(themePaletteProvider);
    final theme = context.theme;
    final colorScheme = theme.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: colorScheme.foreground,
                ),
                const SizedBox(width: 8),
                Text(t.appearance.title, style: theme.typography.body.lg),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ThemePreview(
                  isDark: false,
                  isSelected: currentTheme == ThemeMode.light,
                  title: t.appearance.light,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.light);
                  },
                ),
                const SizedBox(width: 8),
                ThemePreview(
                  isDark: true,
                  isSelected: currentTheme == ThemeMode.dark,
                  title: t.appearance.dark,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.dark);
                  },
                ),
                const SizedBox(width: 8),
                ThemePreview(
                  isDark:
                      MediaQuery.of(context).platformBrightness ==
                      Brightness.dark,
                  isSelected: currentTheme == ThemeMode.system,
                  title: t.appearance.system,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.system);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCurrentThemeIcon(currentTheme),
                    size: 16,
                    color: colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current Theme: ${_getCurrentThemeName(currentTheme)}',
                    style: theme.typography.body.sm.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.appearance.colorScheme,
              style: AppTextStyles.listTitle(theme),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Three per row, 8px spacing
                const spacing = 8.0;
                final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final palette in AppThemePalette.values)
                      PaletteOption(
                        palette: palette,
                        isSelected: palette == selectedPalette,
                        width: itemWidth,
                        onTap: () => ref
                            .read(themePaletteProvider.notifier)
                            .setPalette(palette),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCurrentThemeIcon(ThemeMode currentTheme) {
    switch (currentTheme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getCurrentThemeName(ThemeMode currentTheme) {
    switch (currentTheme) {
      case ThemeMode.light:
        return t.appearance.light;
      case ThemeMode.dark:
        return t.appearance.dark;
      case ThemeMode.system:
        return t.appearance.system;
    }
  }
}
