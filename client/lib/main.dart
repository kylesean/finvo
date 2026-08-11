import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:forui/forui.dart';
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
import 'package:finvo/core/network/dio_provider.dart';
import 'package:finvo/shared/services/locale_service.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/features/profile/providers/speech_settings_provider.dart';

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
  // The bootstrap body lives in [_bootstrap] so the fatal-init retry screen
  // can re-run it inside this SAME zone instead of calling main() again
  // (which would nest a new guarded zone on every retry).
  unawaited(
    runZonedGuarded(_bootstrap, (Object error, StackTrace stackTrace) {
      // Last-resort handler for async errors that escape all try/catch blocks
      // in the app (unawaited Futures, timer callbacks, stream error events
      // without listeners, microtasks). Without this they would crash the
      // process in release mode or print an unhelpful "Unhandled exception"
      // in debug mode.
      _logger.severe('Uncaught async error', error, stackTrace);
    }),
  );
}

/// Full initialization + launch sequence. Re-entrant: the fatal-init error
/// screen re-invokes it to retry startup without nesting error zones.
Future<void> _bootstrap() async {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors (rendering, layout, assertions).
  // Without this override, unhandled framework errors render a red error
  // screen in debug and are silently dropped in release. We log the exception
  // with its stack trace and only surface the red error screen in debug:
  // in release builds the exception is captured by the log/error-reporting
  // pipeline instead of disturbing the user with a debug-only UI.
  FlutterError.onError = (FlutterErrorDetails details) {
    _logger.severe(
      'Flutter framework error: ${details.exception}',
      details.exception,
      details.stack,
    );
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Global fallback for widget build errors (rendering phase). When any
  // widget subtree throws during build/layout, Flutter replaces that subtree
  // with this fallback instead of the default grey ErrorWidget — so a single
  // bad GenUI surface can never blank out the whole conversation page.
  // [GenUiErrorBoundary] handles construction-time errors with graceful
  // degradation; this catches everything that escapes it (e.g. a widget's
  // build method throwing).
  ErrorWidget.builder = (FlutterErrorDetails details) {
    _logger.severe(
      'Widget build error: ${details.exception}',
      details.exception,
      details.stack,
    );
    return const _ErrorFallbackView();
  };

  final SharedPreferences prefs;

  try {
    // Initialize persistent storage
    prefs = await SharedPreferences.getInstance();
    _logger.info('SharedPreferences initialization completed');

    // Initialize slang language service
    // Try to restore language settings from storage, otherwise use device language
    // Note: await the startup locale so the first build frame and [syncIntlLocale]
    // observe the final locale — using unawaited() here would race the async
    // apply and briefly render/track the default locale.
    final savedLocale = prefs.getString('app_locale');
    if (savedLocale != null) {
      await LocaleSettings.setLocaleRaw(savedLocale);
      _logger.info('Language settings restored: $savedLocale');
    } else {
      await LocaleSettings.useDeviceLocale();
      _logger.info('Using device language');
    }
    // Keep Intl in sync so NumberFormat/DateFormat follow the app locale
    LocaleService.syncIntlLocale();

    // Initialize date formatting. In intl 0.20.x the locale parameter is
    // ignored — a single call loads symbols for ALL locales (zh, en, ja, ko,
    // zh_Hant) at once. The previous double call was redundant.
    await initializeDateFormatting();
    _logger.info('Date format initialization completed for all locales');

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
  late final ProviderContainer container;
  container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      // Wire the auth callbacks into the shared Dio pipeline at the
      // composition root, keeping core/network free of feature imports.
      dioAuthCallbacksProvider.overrideWithValue(
        _AppDioAuthCallbacks(() => container),
      ),
    ],
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
    // Pre-warm app-local speech settings (a SharedPreferences read, not a
    // network call) so the chat feature has them on first use. Triggered here
    // explicitly to keep the speech settings provider build() free of
    // side-effects.
    unawaited(container.read(speechSettingsProvider.notifier).loadSettings());
    // Warm notification WebSocket and transaction event subscriber for full app lifetime,
    // avoiding side-effects inside MyApp.build().
    container.read(notificationWsProvider);
    container.read(transactionEventSubscriberProvider);
  });
}

/// Minimal fallback UI shown when core initialization fails, so users are not
/// left on a black screen. Deliberately avoids Riverpod dependencies (those
/// may be exactly what failed to initialize). The global `t` is safe to use
/// here: slang falls back to the base locale when Intl initialization failed,
/// so the retry label always resolves instead of throwing.
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
                    FLucideIcons.circleAlert,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.app.fatalInitTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.app.fatalInitMessage(error: '$error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      // Re-run the bootstrap inside the SAME guarded zone.
                      // (Calling main() here would nest a fresh
                      // runZonedGuarded on every retry.)
                      unawaited(_bootstrap());
                    },
                    icon: const Icon(FLucideIcons.refreshCw),
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

/// Minimal fallback rendered by [ErrorWidget.builder] when a widget subtree
/// throws during build/layout. Deliberately uses only core Material widgets
/// so it cannot fail itself (no theme/GenUI dependencies).
class _ErrorFallbackView extends StatelessWidget {
  const _ErrorFallbackView();

  @override
  Widget build(BuildContext context) {
    // Directionality is required by Text and may be missing if the failing
    // subtree sits above MaterialApp — provide it explicitly so the fallback
    // cannot fail itself.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0x1A000000),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFB3261E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  t.error.genui.loadingFailed,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B8B8B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Composition-root implementation of [DioAuthCallbacks] that forwards to the
/// auth provider. Lives here (not in core/network) so the Dio pipeline stays
/// feature-independent; the container reference is resolved lazily to break
/// the construction cycle with [ProviderContainer].
class _AppDioAuthCallbacks implements DioAuthCallbacks {
  _AppDioAuthCallbacks(this._containerRef);

  final ProviderContainer Function() _containerRef;

  @override
  Future<void> onUnauthorized() async {
    await _containerRef().read(authProvider.notifier).handleSessionExpired();
  }

  @override
  Future<void> onTokenRefreshed(String accessToken, String refreshToken) async {
    // Keep the in-memory AuthState in sync after a silent token refresh so
    // derived providers (authToken → notificationWs) rebuild their long-lived
    // connections with the new token instead of the stale one.
    await _containerRef()
        .read(authProvider.notifier)
        .handleTokenRefreshed(accessToken);
  }
}
