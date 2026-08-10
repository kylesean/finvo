import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/app/router/branches/finance_branch.dart';
import 'package:finvo/app/router/branches/profile_branch.dart';
import 'package:finvo/features/auth/pages/login_page.dart';
import 'package:finvo/features/auth/pages/register_step_1_page.dart';
import 'package:finvo/features/auth/pages/register_step_2_page.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/chat/pages/ai_chat_page.dart';
import 'package:finvo/features/layout/pages/bottom_page.dart';
import 'package:finvo/features/home/pages/home_page.dart';
import 'package:finvo/features/home/pages/transaction_detail_page.dart';
import 'package:finvo/features/report/pages/report_page.dart';
import 'package:finvo/features/notification/pages/notification_center_page.dart';
import 'package:finvo/features/server/pages/server_setup_page.dart';
import 'package:finvo/core/services/server_config_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Pure redirect decision used by [appRouterProvider].
///
/// Extracted (identical behavior) so the auth/server-route matrix can be unit
/// tested without inflating the widget tree: tests build a bare
/// [GoRouterState] and call this directly.
String? appRedirect(
  GoRouterState state, {
  required bool isServerConfigured,
  required AuthStatus authStatus,
}) {
  final location = state.matchedLocation;

  if (location.startsWith(AppRoutePaths.serverSetup)) {
    return null;
  }
  if (!isServerConfigured) {
    return AppRoutePaths.serverSetup;
  }

  // Match on a path-segment boundary (exact match or prefix followed by
  // '/') so that e.g. '/register' matches '/register' and
  // '/register/step2' but not a hypothetical '/registrar'.
  final bool isPublicRoute = publicRoutePrefixes.any(
    (route) => location == route || location.startsWith('$route/'),
  );
  if (isPublicRoute) {
    if (authStatus == AuthStatus.authenticated) {
      // After login, if a 'from' param was stashed by the redirect below
      // (e.g. /join-space?code=xxx), send the user there instead of /home.
      final from = state.uri.queryParameters['from'];
      if (from != null &&
          from.isNotEmpty &&
          from.startsWith('/') &&
          !from.startsWith(AppRoutePaths.login) &&
          !from.startsWith(AppRoutePaths.register)) {
        return from;
      }
      return AppRoutePaths.home;
    }
    return null;
  }
  if (authStatus == AuthStatus.loading || authStatus == AuthStatus.initial) {
    return null;
  }
  final bool loggedIn = authStatus == AuthStatus.authenticated;
  if (!loggedIn) {
    // Preserve the intended destination (including query params like
    // join_code) so the login page can redirect back after success.
    final fullLocation = state.uri.toString();
    if (fullLocation != '/' && fullLocation != AppRoutePaths.home) {
      return '${AppRoutePaths.login}?from=${Uri.encodeComponent(fullLocation)}';
    }
    return AppRoutePaths.login;
  }
  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch only the auth *status* (login state flip), not the whole AuthState.
  // AuthState is an immutable freezed object whose every copyWith (e.g. a
  // background refreshUser) would otherwise rebuild the entire GoRouter and
  // reset the navigation stack back to '/home'.
  final authStatus = ref.watch(authStatusProvider);
  final isServerConfigured = ref.watch(isServerConfiguredProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',
    // Fail-safe page for unmatched routes / navigation errors. Without this,
    // go_router throws a StateError for an unknown route and the app renders
    // a red error screen (debug) or a blank screen (release).
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  t.error.unknownError,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.error.unknownErrorHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutePaths.home),
                  icon: const Icon(FLucideIcons.home),
                  label: Text(t.common.retry),
                ),
              ],
            ),
          ),
        ),
      );
    },
    redirect: (BuildContext context, GoRouterState state) {
      return appRedirect(
        state,
        isServerConfigured: isServerConfigured,
        authStatus: authStatus,
      );
    },

    routes: [
      GoRoute(
        path: AppRoutePaths.serverSetup,
        name: AppRouteNames.serverSetup,
        builder: (context, state) {
          final isReconfiguring =
              state.uri.queryParameters['reconfigure'] == 'true';
          return ServerSetupPage(isReconfiguring: isReconfiguring);
        },
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.registerStep1,
        builder: (context, state) => const RegisterStep1Page(),
        routes: [
          GoRoute(
            path: 'step2',
            name: AppRouteNames.registerStep2,
            builder: (context, state) {
              // state.extra is typed Object; the cast below would throw a
              // TypeError if a caller navigated with a non-map payload.
              // Guard with an is-check so a mis-navigation degrades to the
              // dedicated missing-info screen instead of crashing.
              final extra = state.extra;
              final args = extra is Map<String, dynamic> ? extra : null;
              final contact = args?['contact'] as String?;
              final verificationCode = args?['verificationCode'] as String?;
              if (contact == null || verificationCode == null) {
                return Scaffold(
                  body: Center(child: Text(t.error.registrationMissingInfo)),
                );
              }
              return RegisterStep2Page(
                contact: contact,
                verificationCode: verificationCode,
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BottomPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'transaction/:transactionId',
                    name: AppRouteNames.transactionDetail,
                    builder: (context, state) {
                      // pathParameters is unmodifiable; '!' on a missing key
                      // throws a null check error. Resolve safely and show a
                      // fallback instead of crashing.
                      final transactionId =
                          state.pathParameters['transactionId'];
                      if (transactionId == null) {
                        return Scaffold(
                          body: Center(child: Text(t.error.unknownError)),
                        );
                      }
                      final targetCommentId =
                          state.uri.queryParameters['commentId'];
                      return TransactionDetailPage(
                        transactionId: transactionId,
                        targetCommentId: targetCommentId,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: AppRoutePaths.notifications,
                name: AppRouteNames.notifications,
                builder: (context, state) => const NotificationCenterPage(),
              ),
            ],
          ),
          buildFinanceBranch(),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.ai,
                name: AppRouteNames.ai,
                builder: (context, state) {
                  return const AIChatPage(conversationId: null);
                },
                routes: [
                  GoRoute(
                    path: ':conversationId',
                    name: AppRouteNames.conversation,
                    builder: (context, state) {
                      return AIChatPage(
                        conversationId: state.pathParameters['conversationId'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.report,
                name: AppRouteNames.report,
                builder: (context, state) => const ReportPage(),
              ),
            ],
          ),
          buildProfileBranch(),
        ],
      ),

      GoRoute(
        path: AppRoutePaths.joinSpace,
        name: AppRouteNames.joinSpace,
        redirect: (context, state) {
          final code = state.uri.queryParameters['code'];
          if (code != null) {
            return '${AppRoutePaths.sharedSpaceList}?join_code=$code';
          }
          return AppRoutePaths.sharedSpaceList;
        },
      ),
    ],
  );
});
