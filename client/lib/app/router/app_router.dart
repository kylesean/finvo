import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'app_routes.dart';
import 'branches/finance_branch.dart';
import 'branches/profile_branch.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_step_1_page.dart';
import '../../features/auth/pages/register_step_2_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/chat/pages/ai_chat_page.dart';
import '../../features/layout/pages/bottom_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/home/pages/transaction_detail_page.dart';
import '../../features/report/pages/report_page.dart';
import '../../features/notification/pages/notification_center_page.dart';
import '../../features/server/pages/server_setup_page.dart';
import '../../core/services/server_config_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isServerConfigured = ref.watch(isServerConfiguredProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authState.status;
      final String location = state.matchedLocation;

      if (location.startsWith('/server-setup')) {
        return null;
      }
      if (!isServerConfigured) {
        return '/server-setup';
      }

      final bool isPublicRoute = publicRoutePrefixes.any(
        (route) => location.startsWith(route),
      );
      if (isPublicRoute) {
        if (authStatus == AuthStatus.authenticated) {
          return '/home';
        }
        return null;
      }
      if (authStatus == AuthStatus.loading ||
          authStatus == AuthStatus.initial) {
        return null;
      }
      final bool loggedIn = authStatus == AuthStatus.authenticated;
      if (!loggedIn) {
        return '/login';
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/server-setup',
        name: 'serverSetup',
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
            name: 'registerStep2',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
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
                    name: 'transactionDetail',
                    builder: (context, state) {
                      final transactionId =
                          state.pathParameters['transactionId']!;
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
                path: '/notifications',
                name: 'notifications',
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
                    name: 'conversation',
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
        path: '/join-space',
        name: 'joinSpace',
        redirect: (context, state) {
          final code = state.uri.queryParameters['code'];
          if (code != null) {
            return '/profile/shared-space?join_code=$code';
          }
          return '/profile/shared-space';
        },
      ),
    ],
  );
});
