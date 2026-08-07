import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/core/services/server_config_service.dart'
    show sharedPreferencesProvider;

part 'theme_notifier.g.dart';

/// App theme mode enum
enum AppThemeMode { system, light, dark }

/// Theme mode state manager
///
/// Converts [AppThemeMode] to Flutter's [ThemeMode] and persists the user's
/// choice to SharedPreferences so it survives app restarts.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _storageKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_storageKey);
    return _modeFromName(saved) ?? ThemeMode.system;
  }

  void setTheme(AppThemeMode mode) {
    state = _themeModeOf(mode);
    unawaited(_persist(mode));
  }

  Future<void> _persist(AppThemeMode mode) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_storageKey, mode.name);
    } catch (e) {
      // Persistence is best-effort; the in-memory theme is already applied.
      Logger('ThemeNotifier').warning('Failed to persist theme mode: $e');
    }
  }

  /// Single source of truth for mapping [AppThemeMode] to Flutter's [ThemeMode].
  /// Used by both [setTheme] and [_modeFromName] so the conversion is never
  /// duplicated.
  static ThemeMode _themeModeOf(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }

  static ThemeMode? _modeFromName(String? name) {
    if (name == null) return null;
    for (final mode in AppThemeMode.values) {
      if (mode.name == name) {
        return _themeModeOf(mode);
      }
    }
    return null;
  }
}
