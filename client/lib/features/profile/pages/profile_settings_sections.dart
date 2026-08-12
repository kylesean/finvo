// Settings tile groups of the profile page (preferences, services, system),
// extracted from the 800-line profile page so the page build stays readable.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/features/version/providers/version_provider.dart';
import 'package:finvo/features/version/services/app_version_service.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/shared/services/locale_service.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/utils/error_message.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// The three settings tile groups of the profile page.
///
/// Renders the Preferences & Finance, Shared Spaces & Services and System &
/// Appearance groups. All values and actions are provider-driven; the parent
/// only supplies the update-check callback scope via [ref].
class ProfileSettingsSections extends ConsumerWidget {
  const ProfileSettingsSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final currentLocale = ref.watch(localeProvider);

    return Column(
      children: [
        // Group 1: Preferences & Finance
        FTileGroup(
          label: Text(t.settings.groupPreferences),
          children: [
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.globe),
              title: Text(t.settings.language),
              suffix: _buildTrailingValue(
                context,
                LocaleService.getLocaleDisplayName(currentLocale),
              ),
              onPress: () => context.goNamed(AppRouteNames.languageSettings),
            ),
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.dollarSign),
              title: Text(t.settings.currency),
              suffix: _buildTrailingValue(
                context,
                _getCurrencyDisplayName(ref),
              ),
              onPress: () => context.goNamed(AppRouteNames.currencySettings),
            ),
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.palette),
              title: Text(t.settings.amountDisplayStyle),
              suffix: _buildTrailingValue(
                context,
                _getAmountThemeDisplayName(ref),
              ),
              onPress: () => context.goNamed(AppRouteNames.amountStyleSettings),
            ),
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.mic),
              title: Text(t.settings.speechRecognition),
              suffix: Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: colors.mutedForeground,
              ),
              onPress: () => context.goNamed(AppRouteNames.speechSettings),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Group 2: Shared Spaces & Services
        FTileGroup(
          label: Text(t.settings.groupServices),
          children: [
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.users),
              title: Text(t.settings.sharedSpace),
              suffix: Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: colors.mutedForeground,
              ),
              onPress: () => context.pushNamed(AppRouteNames.sharedSpaceList),
            ),
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.server),
              title: Text(t.server.serverSettings),
              suffix: _buildTrailingValue(context, _getServerHostName(ref)),
              onPress: () => context.pushNamed(
                AppRouteNames.serverSetup,
                queryParameters: {'reconfigure': 'true'},
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Group 3: System & Appearance
        FTileGroup(
          label: Text(t.settings.groupSystem),
          children: [
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.sun),
              title: Text(t.settings.appearance),
              suffix: Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: colors.mutedForeground,
              ),
              onPress: () => context.goNamed(AppRouteNames.appearanceSettings),
            ),
            FTile(
              prefix: _buildSettingIcon(context, FLucideIcons.info),
              title: Text(t.settings.aboutApp),
              suffix: Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: colors.mutedForeground,
              ),
              onPress: () => _checkAppUpdate(context, ref),
            ),
            FTile(
              prefix: Icon(
                FLucideIcons.logOut,
                size: 20,
                color: colors.destructive,
              ),
              title: Text(
                t.auth.logout,
                style: TextStyle(color: colors.destructive),
              ),
              onPress: () => _handleLogout(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds setting item icon (using unified ThemedIcon component)
  Widget _buildSettingIcon(BuildContext context, IconData icon) {
    return ThemedIcon(icon: icon);
  }

  /// Builds right-aligned value with chevron icon
  Widget _buildTrailingValue(BuildContext context, String text) {
    final colors = context.theme.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          FLucideIcons.chevronRight,
          size: 16,
          color: colors.mutedForeground,
        ),
      ],
    );
  }

  /// Gets amount theme display name
  String _getAmountThemeDisplayName(WidgetRef ref) {
    final themeId = ref.watch(amountThemeProvider).themeId;
    switch (themeId) {
      case 'chinaMarket':
        return t.amountTheme.chinaMarket;
      case 'international':
        return t.amountTheme.international;
      case 'minimalist':
        return t.amountTheme.minimalist;
      default:
        return t.amountTheme.colorBlind;
    }
  }

  /// Gets currency display name
  String _getCurrencyDisplayName(WidgetRef ref) {
    final currencyCode = ref.watch(financialSettingsProvider).primaryCurrency;
    final currency = Currency.fromCode(currencyCode);
    return currency != null
        ? '${currency.flag} ${currency.code}'
        : currencyCode;
  }

  /// Build server hostname
  String _getServerHostName(WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    if (serverUrl != null && serverUrl.isNotEmpty) {
      final uri = Uri.tryParse(serverUrl);
      return uri?.host ?? serverUrl;
    }
    return '';
  }

  /// Handles logout
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.auth.confirmLogoutTitle,
        message: t.auth.confirmLogoutContent,
        cancelLabel: t.common.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: t.auth.logout,
        onConfirm: () async {
          // Fail-closed logout: only report success once the credentials are
          // actually gone from secure storage; a storage failure keeps the
          // session intact and surfaces the error instead.
          try {
            await ref.read(authProvider.notifier).logout();
          } catch (e) {
            if (context.mounted) {
              ToastService.showDestructive(
                title: Text(t.auth.logoutFailedTitle),
                description: Text(safeErrorMessage(e)),
              );
            }
            return;
          }
          if (context.mounted) {
            ToastService.success(description: Text(t.auth.logoutSuccess));
          }
        },
      ),
    );
  }

  /// Check app updates and display Forui update dialog
  Future<void> _checkAppUpdate(BuildContext context, WidgetRef ref) async {
    final versionState = ref.read(versionNotifierProvider);
    if (versionState.isChecking) return;

    ToastService.success(description: Text(t.settings.checkingUpdate));

    final updateInfo = await ref
        .read(versionNotifierProvider.notifier)
        .checkUpdate();

    if (!context.mounted) return;

    if (updateInfo == null) {
      ToastService.showDestructive(
        description: Text(t.settings.fetchUpdateFailed),
      );
      return;
    }

    if (!updateInfo.hasUpdate) {
      ToastService.success(
        description: Text(
          '${t.settings.latestVersionToast} (v${updateInfo.currentVersion})',
        ),
      );
      return;
    }

    // Show update modal dialog using showFDialog
    unawaited(
      showFDialog<void>(
        context: context,
        builder: (dialogContext, style, animation) => FDialog(
          animation: animation,
          builder: (context, dialogStyle) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${t.settings.newVersionTitle} v${updateInfo.latestVersion}',
                  style: dialogStyle.titleTextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  t.settings.currentVersion(version: updateInfo.currentVersion),
                  style: dialogStyle.bodyTextStyle.copyWith(fontSize: 12),
                ),
                if (updateInfo.changelog.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.theme.colors.muted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      updateInfo.changelog,
                      style: dialogStyle.bodyTextStyle,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FButton(
                  variant: .primary,
                  onPress: () async {
                    Navigator.of(dialogContext).pop();
                    if (updateInfo.targetDownloadUrl != null &&
                        updateInfo.targetDownloadUrl!.isNotEmpty) {
                      await ref
                          .read(appVersionServiceProvider)
                          .openUpdateUrl(updateInfo.targetDownloadUrl!);
                    }
                  },
                  child: Text(t.settings.updateNow),
                ),
                if (!updateInfo.forceUpdate) ...[
                  const SizedBox(height: 8),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(dialogContext).pop(),
                    child: Text(t.common.cancel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
