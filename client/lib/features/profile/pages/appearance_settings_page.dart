import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_theme_palette.dart';
import 'package:finvo/app/theme/theme_palette_provider.dart';
import 'package:finvo/app/theme/theme_provider.dart';
import 'package:finvo/app/theme/theme_notifier.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/features/profile/widgets/theme_preview.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/profile/widgets/palette_option.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final currentThemeMode = ref.watch(themeProvider);
    final selectedPalette = ref.watch(themePaletteProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FLucideIcons.chevronLeft, color: colors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.appearance.title,
          style: AppTextStyles.pageTitleLarge(theme),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.appearance.themeMode, style: AppTextStyles.listTitle(theme)),
            const SizedBox(height: 12),
            Row(
              children: [
                ThemePreview(
                  isDark: false,
                  isSelected: currentThemeMode == ThemeMode.light,
                  title: t.appearance.light,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.light);
                    ToastService.success(
                      description: Text(t.settings.appearanceUpdated),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ThemePreview(
                  isDark: true,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  title: t.appearance.dark,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.dark);
                    ToastService.success(
                      description: Text(t.settings.appearanceUpdated),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ThemePreview(
                  isDark:
                      MediaQuery.of(context).platformBrightness ==
                      Brightness.dark,
                  isSelected: currentThemeMode == ThemeMode.system,
                  title: t.appearance.system,
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(AppThemeMode.system);
                    ToastService.success(
                      description: Text(t.settings.appearanceUpdated),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                        onTap: () {
                          ref
                              .read(themePaletteProvider.notifier)
                              .setPalette(palette);
                          ToastService.success(
                            description: Text(t.settings.appearanceUpdated),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
