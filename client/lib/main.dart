import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:finvo/app/app.dart';
import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:finvo/i18n/strings.g.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/utils/logger_setup.dart';
import 'package:finvo/shared/services/locale_service.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/chat/services/sound_feedback_service.dart';

final _logger = Logger('Main');

void main() {
  // Wrap the entire app in a guarded zone so that uncaught async errors
  // (from Futures, timers, microtasks, isolate callbacks) are funneled to
  // the error handler instead of crashing the app silently. Combined with
  // [FlutterError.onError] (for framework/rendering errors) this provides
  // a complete global error net: no uncaught exception is silently dropped.
  //
  // runZonedGuarded returns Future<void>? because the body is async; we
  // never await it — the zone must stay active for the app's entire lifetime.
  unawaited(
    runZonedGuarded(
      () async {
        setupLogging();
        WidgetsFlutterBinding.ensureInitialized();

        // Catch Flutter framework errors (rendering, layout, assertions).
        // Without this override, unhandled framework errors render a red error
        // screen in debug and are silently dropped in release. We log every one
        // and still forward to presentError so debug-mode keeps its assertion UI.
        FlutterError.onError = (FlutterErrorDetails details) {
          _logger.severe(
            'Flutter framework error',
            details.exception,
            details.stack,
          );
          FlutterError.presentError(details);
        };

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

          // Initialize date formatting. In intl 0.20.x the locale parameter is
          // ignored — a single call loads symbols for ALL locales (zh, en, ja, ko,
          // zh_Hant) at once. The previous double call was redundant.
          await initializeDateFormatting();
          _logger.info('Date format initialization completed for all locales');

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
          // Never leave the user on a black screen: render a minimal fatal-error
          // screen with a retry entry point so the failure is visible and recoverable.
          runApp(FatalInitErrorApp(error: e, stackTrace: stackTrace));
          return;
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

        // Explicitly trigger auth state restoration after the first frame so
        // SecureStorage reads do not block the initial render. This replaces
        // the former side-effect inside Auth.build() with an explicit startup
        // step, keeping the provider build() pure and decoupled from the
        // widget build cycle.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          unawaited(container.read(authProvider.notifier).checkAuthStatus());
        });
      },
      (Object error, StackTrace stackTrace) {
        // Last-resort handler for async errors that escape all try/catch blocks
        // in the app (unawaited Futures, timer callbacks, stream error events
        // without listeners, microtasks). Without this they would crash the
        // process in release mode or print an unhelpful "Unhandled exception"
        // in debug mode.
        _logger.severe('Uncaught async error', error, stackTrace);
      },
    ),
  );
}

/// Minimal fallback UI shown when core initialization fails, so users are not
/// left on a black screen. Deliberately avoids Riverpod/i18n dependencies
/// (those may be exactly what failed to initialize).
class FatalInitErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const FatalInitErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Finvo failed to start',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initialization error: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      // Full app restart: re-run the whole initialization flow.
                      main();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(t.common.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
