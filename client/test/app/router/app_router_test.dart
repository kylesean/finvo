// Router redirect matrix (H13). The redirect logic is unit tested via the
// pure `appRedirect` function (extracted from appRouterProvider) using
// lightweight GoRouterState instances — no widget tree or network needed.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/app/router/app_router.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/auth/providers/auth_state.dart';

GoRouterState _state(String uriString) {
  final uri = Uri.parse(uriString);
  // A minimal but real RouteConfiguration is required by the state ctor; the
  // router itself is never run, only the redirect decision is exercised.
  final config = RouteConfiguration(
    ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),
    ),
    navigatorKey: GlobalKey<NavigatorState>(),
  );
  return GoRouterState(
    config,
    uri: uri,
    matchedLocation: uri.path,
    fullPath: uri.path,
    pathParameters: const {},
    pageKey: const ValueKey<String>('test'),
  );
}

/// Returns the redirect target for [location] under the given auth/server
/// configuration (null = no redirect, stay put).
String? _redirect(
  String location, {
  bool isServerConfigured = true,
  required AuthStatus authStatus,
}) => appRedirect(
  _state(location),
  isServerConfigured: isServerConfigured,
  authStatus: authStatus,
);

void main() {
  group('appRedirect', () {
    test('unconfigured server: everything lands on server setup', () {
      for (final location in [
        AppRoutePaths.home,
        AppRoutePaths.login,
        AppRoutePaths.serverSetup,
      ]) {
        expect(
          _redirect(
            location,
            isServerConfigured: false,
            authStatus: AuthStatus.authenticated,
          ),
          location == AppRoutePaths.serverSetup
              ? null
              : AppRoutePaths.serverSetup,
        );
      }
    });

    test('public routes stay public for guests', () {
      const guest = AuthStatus.unauthenticated;
      expect(_redirect(AppRoutePaths.login, authStatus: guest), isNull);
      expect(_redirect(AppRoutePaths.register, authStatus: guest), isNull);
      expect(
        _redirect('${AppRoutePaths.register}/step2', authStatus: guest),
        isNull,
      );
      expect(
        _redirect(AppRoutePaths.home, authStatus: guest),
        AppRoutePaths.login,
      );
    });

    test('authenticated users are bounced off public routes to /home', () {
      const authed = AuthStatus.authenticated;
      expect(
        _redirect(AppRoutePaths.login, authStatus: authed),
        AppRoutePaths.home,
      );
      expect(
        _redirect(AppRoutePaths.register, authStatus: authed),
        AppRoutePaths.home,
      );
      expect(_redirect(AppRoutePaths.home, authStatus: authed), isNull);
    });

    test('loading/initial auth status does not bounce protected routes', () {
      expect(
        _redirect(AppRoutePaths.home, authStatus: AuthStatus.loading),
        isNull,
      );
      expect(
        _redirect(AppRoutePaths.home, authStatus: AuthStatus.initial),
        isNull,
      );
    });

    test('guests hitting protected routes are sent to login, preserving the '
        'destination as a from param', () {
      const guest = AuthStatus.unauthenticated;
      expect(
        _redirect('/notifications', authStatus: guest),
        '/login?from=%2Fnotifications',
      );
      expect(
        _redirect('/ai?conversation=42', authStatus: guest),
        '/login?from=${Uri.encodeComponent('/ai?conversation=42')}',
      );
      expect(
        _redirect('/join-space?code=abc123', authStatus: guest),
        '/login?from=${Uri.encodeComponent('/join-space?code=abc123')}',
      );
    });

    test('home itself does not carry a from param', () {
      expect(
        _redirect(AppRoutePaths.home, authStatus: AuthStatus.unauthenticated),
        AppRoutePaths.login,
      );
    });

    test('from param is honored for authenticated users on public routes', () {
      const authed = AuthStatus.authenticated;
      expect(
        _redirect(
          '${AppRoutePaths.login}?from=%2Fai%3Fconversation%3D42',
          authStatus: authed,
        ),
        '/ai?conversation=42',
      );
    });

    test('from param cannot point at another public route (loop guard)', () {
      const authed = AuthStatus.authenticated;
      expect(
        _redirect(
          '${AppRoutePaths.login}?from=${Uri.encodeComponent(AppRoutePaths.register)}',
          authStatus: authed,
        ),
        AppRoutePaths.home,
      );
    });

    test('from param must be an absolute path (no external URLs)', () {
      const authed = AuthStatus.authenticated;
      expect(
        _redirect(
          '${AppRoutePaths.login}?from=https%3A%2F%2Fevil.example%2Fphish',
          authStatus: authed,
        ),
        AppRoutePaths.home,
      );
    });

    test(
      'prefix matching: /register matches /register/step2, not /registrar',
      () {
        const guest = AuthStatus.unauthenticated;
        expect(
          _redirect('${AppRoutePaths.register}/step2', authStatus: guest),
          isNull,
        );
        expect(_redirect('/registrar', authStatus: guest), isNotNull);
      },
    );
  });
}
