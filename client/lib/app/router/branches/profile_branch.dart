// app/router/branches/profile_branch.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';

import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/profile/pages/profile_page.dart';
import 'package:finvo/features/profile/pages/appearance_settings_page.dart';
import 'package:finvo/features/profile/pages/language_settings_page.dart';
import 'package:finvo/features/profile/pages/speech_settings_page.dart';
import 'package:finvo/features/profile/pages/currency_settings_page.dart';
import 'package:finvo/features/profile/pages/amount_settings_page.dart';
import 'package:finvo/features/shared_space/pages/shared_space_list_page.dart';
import 'package:finvo/features/shared_space/pages/shared_space_detail_page.dart';
import 'package:finvo/features/shared_space/pages/shared_space_settings_page.dart';
import 'package:finvo/features/shared_space/pages/invite_success_page.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';

/// The profile [StatefulShellBranch]: settings and shared spaces.
///
/// Extracted to keep the root router concise. Route `name`s are kept identical
/// to the original definitions because they are referenced by named navigation.
StatefulShellBranch buildProfileBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePaths.profile,
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'appearance',
            name: AppRouteNames.appearanceSettings,
            builder: (context, state) => const AppearanceSettingsPage(),
          ),
          GoRoute(
            path: 'language',
            name: AppRouteNames.languageSettings,
            builder: (context, state) => const LanguageSettingsPage(),
          ),
          GoRoute(
            path: 'speech-settings',
            name: AppRouteNames.speechSettings,
            builder: (context, state) => const SpeechSettingsPage(),
          ),
          GoRoute(
            path: 'currency',
            name: AppRouteNames.currencySettings,
            builder: (context, state) => const CurrencySettingsPage(),
          ),
          GoRoute(
            path: 'amount-style',
            name: AppRouteNames.amountStyleSettings,
            builder: (context, state) => const AmountSettingsPage(),
          ),
          // Shared space routes
          GoRoute(
            path: 'shared-space',
            name: AppRouteNames.sharedSpaceList,
            builder: (context, state) => const SharedSpaceListPage(),
            routes: [
              GoRoute(
                path: 'invite-success',
                name: AppRouteNames.inviteSuccess,
                builder: (context, state) {
                  final space = state.extra as SharedSpace?;
                  if (space == null) {
                    // Guard against deep links / invalid navigation that omit
                    // the required SharedSpace payload.
                    return Scaffold(
                      body: Center(child: Text(t.error.sharedSpaceInfoMissing)),
                    );
                  }
                  return InviteSuccessPage(space: space);
                },
              ),
              GoRoute(
                path: ':spaceId',
                name: AppRouteNames.sharedSpaceDetail,
                builder: (context, state) {
                  final spaceId = state.pathParameters['spaceId'];
                  if (spaceId == null) {
                    return Scaffold(
                      body: Center(child: Text(t.error.unknownError)),
                    );
                  }
                  return SharedSpaceDetailPage(spaceId: spaceId);
                },
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: AppRouteNames.sharedSpaceSettings,
                    builder: (context, state) {
                      final spaceId = state.pathParameters['spaceId'];
                      if (spaceId == null) {
                        return Scaffold(
                          body: Center(child: Text(t.error.unknownError)),
                        );
                      }
                      return SharedSpaceSettingsPage(spaceId: spaceId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
