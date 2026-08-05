import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:finvo/app/assets/app_vectors.dart';

import 'package:finvo/app/router/app_router.dart';

import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/app/theme/theme_provider.dart';
import 'package:finvo/app/theme/app_theme_pair_provider.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/home/providers/home_providers.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/i18n/strings.g.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final themes = ref.watch(appThemePairProvider);

    // Hold the WebSocket notification service (keepAlive) so the long-lived
    // connection is not torn down after this frame completes.
    ref.watch(notificationWsProvider);

    // Keep the cross-feature transaction event subscription alive so the
    // home feature refreshes when other features (e.g. chat) create data.
    ref.watch(transactionEventSubscriberProvider);

    return MaterialApp.router(
      title: 'Finvo',
      theme: themes.materialLight,
      darkTheme: themes.materialDark,
      themeMode: appThemeMode,
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: [
        ...FLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocaleUtils.supportedLocales,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      builder: (materialContext, navigator) {
        final activeBrightness = Theme.of(materialContext).brightness;
        final activeForuiTheme = activeBrightness == Brightness.dark
            ? themes.foruiDark
            : themes.foruiLight;

        return FTheme(
          data: activeForuiTheme,
          child: _buildAppContent(ref, navigator!),
        );
      },
    );
  }

  Widget _buildAppContent(WidgetRef ref, Widget navigator) {
    final authState = ref.watch(authProvider);

    if (authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial) {
      return const _SplashScreen();
    }

    return navigator;
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash SVG illustration
            SizedBox(
              width: 300,
              height: 300,
              child: SvgPicture.asset(AppVectors.splash, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(
              t.app.splashTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: AppFontConfig.headingBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.app.splashSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
