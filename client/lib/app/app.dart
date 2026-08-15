import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:finvo/app/assets/app_vectors.dart';

import 'package:finvo/app/router/app_router.dart';

import 'package:finvo/app/theme/app_font_config.dart';
import 'package:finvo/app/theme/theme_notifier.dart';
import 'package:finvo/app/theme/app_theme_pair_provider.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/notification/providers/notification_provider.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/providers/exchange_rate_provider.dart';
import 'package:finvo/shared/providers/financial_settings_provider.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/i18n/strings.g.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final themes = ref.watch(appThemePairProvider);
    final currentLocale = ref.watch(localeProvider);

    // Once the user authenticates, warm the login-scoped data providers. We
    // react to the auth transition instead of firing network side-effects from
    // provider build(): financial settings (used across home/budget/report) and
    // the user profile are loaded once per login, keeping build() pure.
    ref.listen(authProvider, (prev, next) {
      if (prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        unawaited(
          ref.read(financialSettingsProvider.notifier).loadFinancialSettings(),
        );
        unawaited(ref.read(userProfileProvider.notifier).loadUser());
        // L-2: match the comment in FinancialAccountNotifier.build — the
        // login listener preloads accounts so the net-worth page (and any
        // future "watch-only" consumer) never sits in a permanent loading
        // state waiting for an external trigger.
        unawaited(
          ref.read(financialAccountProvider.notifier).loadFinancialAccounts(),
        );
      } else if (prev?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        // Logout / session expiry: tear down the login-scoped state so the
        // next account never renders the previous one's data (PII in profile
        // and financial settings, stale notification list and unread badge,
        // and a WebSocket that would keep pushing the old account's
        // notifications). KeepAlive providers would otherwise hold this state
        // forever.
        ref.invalidate(notificationWsProvider);
        ref.read(notificationProvider.notifier).resetState();
        ref.invalidate(userProfileProvider);
        ref.invalidate(financialSettingsProvider);
        ref.invalidate(financialAccountProvider);
        ref.invalidate(exchangeRateProvider);
      }
    });

    return MaterialApp.router(
      title: 'Finvo',
      theme: themes.materialLight,
      darkTheme: themes.materialDark,
      themeMode: appThemeMode,
      locale: currentLocale.flutterLocale,
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
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
