import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/services/server_config_service.dart';

/// Language management service
/// Responsible for persistent storage and management of language settings, integrated with slang
class LocaleService {
  static const String _localeKey = 'app_locale';

  /// Concrete [SharedPreferences] instance supplied via DI (the provider is
  /// overridden in main() with the already-initialized singleton), so reads and
  /// writes go through the same instance the rest of the app uses instead of
  /// calling [SharedPreferences.getInstance] each time.
  final SharedPreferences _prefs;

  LocaleService(this._prefs);

  /// Language display name mapping (use slang's t variable to get localized names)
  /// Language display name mapping
  static String getLocaleDisplayName(AppLocale locale) {
    switch (locale) {
      case AppLocale.zh:
        return t.locale.chinese;
      case AppLocale.en:
        return t.locale.english;
      case AppLocale.ja:
        return t.locale.japanese;
      case AppLocale.ko:
        return t.locale.korean;
      case AppLocale.zhHant:
        return t.locale.traditionalChinese;
    }
  }

  /// Get display name from locale code (for legacy or external use)
  static String getLocaleDisplayNameFromCode(String localeCode) {
    final locale = AppLocale.values.firstWhere(
      (l) => l.languageTag == localeCode || l.languageCode == localeCode,
      orElse: () => AppLocale.en,
    );
    return getLocaleDisplayName(locale);
  }

  /// Get currently saved language settings
  Future<String?> getSavedLocale() async {
    try {
      return _prefs.getString(_localeKey);
    } catch (e) {
      return null;
    }
  }

  /// Save language settings and apply
  Future<bool> saveLocale(AppLocale locale) async {
    try {
      final success = await _prefs.setString(_localeKey, locale.languageTag);

      if (success) {
        // Apply the new locale BEFORE syncing Intl: LocaleSettings.setLocale
        // is asynchronous, so syncIntlLocale() running in parallel would read
        // the still-active previous locale and Intl.defaultLocale would stay
        // stale until the next save.
        await LocaleSettings.setLocale(locale);
        syncIntlLocale();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Get supported language list
  static List<AppLocale> get supportedLocales => AppLocale.values;

  /// Get current language
  static AppLocale get currentLocale => LocaleSettings.currentLocale;

  /// Synchronize [Intl] with the active app locale so
  /// NumberFormat/DateFormat fall back to the selected language.
  static void syncIntlLocale() {
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;
  }

  /// Check if language code is supported
  static bool isSupportedLocale(String localeCode) {
    return AppLocale.values.any((l) => l.languageCode == localeCode);
  }
}

/// Provides the [LocaleService] wired to the shared [SharedPreferences] instance
/// (overridden in main() with the pre-initialized singleton), so all locale
/// persistence goes through the same DI-managed instance.
final localeServiceProvider = Provider<LocaleService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleService(prefs);
});
