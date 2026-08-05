import 'package:flutter/material.dart';
import 'dart:async';
import 'package:finvo/app/app.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'i18n/strings.g.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/utils/logger_setup.dart';
import 'shared/services/locale_service.dart';
import 'core/services/server_config_service.dart';
import 'features/chat/services/sound_feedback_service.dart';

final _logger = Logger('Main');

void main() async {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs;

  try {
    // Initialize persistent storage
    prefs = await SharedPreferences.getInstance();
    _logger.info('SharedPreferences initialization completed');

    // Initialize slang language service
    // Try to restore language settings from storage, otherwise use device language
    final savedLocale = prefs.getString('app_locale');
    if (savedLocale != null) {
      unawaited(LocaleSettings.setLocaleRaw(savedLocale));
      _logger.info('Language settings restored: $savedLocale');
    } else {
      unawaited(LocaleSettings.useDeviceLocale());
      _logger.info('Using device language');
    }
    // Keep Intl in sync so NumberFormat/DateFormat follow the app locale
    LocaleService.syncIntlLocale();

    // Register timeago message set once (was previously re-registered on every
    // build of the transaction detail / comment widgets).
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());

    // Initialize Chinese date format data
    await initializeDateFormatting('zh_CN', null);
    await initializeDateFormatting('en', null);
    _logger.info('Date format initialization completed');

    // Initialize sound feedback service (for self-hosted ASR)
    // Wrapped in try-catch to not block app launch if assets are missing
    try {
      await SoundFeedbackService.instance.initialize();
      _logger.info('Sound feedback service initialization completed');
    } catch (e) {
      _logger.warning('Sound feedback service initialization failed: $e');
    }

    // Pre-load Xiaomi MiSans font to bypass Skia fallback selecting NotoSansCJK
    try {
      await AppFontConfig.preloadMiSans();
      _logger.info(
        'MiSans preload result: loaded=${AppFontConfig.miSansLoaded}',
      );
    } catch (e) {
      _logger.warning('MiSans preload failed (will use fallback): $e');
    }

    _logger.info('Application initialization completed, launching app');
  } catch (e, stackTrace) {
    _logger.severe('Error during initialization', e, stackTrace);
    return; // Should not continue if core components fail to load
  }

  // Create ProviderContainer
  // Optimization: No longer synchronously warming up authProvider, allowing SecureStorage operations
  // to happen asynchronously after the Splash Screen renders to avoid blocking the main thread
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  _logger.info(
    'ProviderContainer created, authentication will initialize on first access',
  );

  runApp(
    TranslationProvider(
      child: UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    ),
  );
}
