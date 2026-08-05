import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/services/server_config_service.dart'
    show sharedPreferencesProvider;
import 'package:finvo/app/theme/app_theme_palette.dart';

class ThemePaletteNotifier extends Notifier<AppThemePalette> {
  static const _storageKey = 'theme_palette';
  static final _logger = Logger('ThemePaletteNotifier');

  @override
  AppThemePalette build() {
    // Restore the user's saved palette on cold start instead of defaulting to
    // zinc every launch.
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      for (final palette in AppThemePalette.values) {
        if (palette.name == saved) {
          return palette;
        }
      }
    }
    return AppThemePalette.zinc;
  }

  void setPalette(AppThemePalette palette) {
    if (state == palette) {
      return;
    }
    state = palette;
    unawaited(_persist(palette));
  }

  Future<void> _persist(AppThemePalette palette) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_storageKey, palette.name);
    } catch (e) {
      // Persistence is best-effort; the in-memory palette is already applied.
      _logger.warning('Failed to persist theme palette: $e');
    }
  }
}

final themePaletteProvider =
    NotifierProvider<ThemePaletteNotifier, AppThemePalette>(
      ThemePaletteNotifier.new,
    );
