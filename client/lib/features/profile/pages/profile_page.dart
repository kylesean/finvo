import 'package:flutter/material.dart';
import 'package:finvo/shared/widgets/confirm_dialog.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/providers/locale_provider.dart';
import 'package:finvo/shared/services/locale_service.dart';
import 'package:finvo/shared/providers/amount_theme_provider.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/core/services/server_config_service.dart';
import 'package:finvo/features/version/providers/version_provider.dart';
import 'package:finvo/features/version/services/app_version_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(userProfileProvider.notifier).loadUser());
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final userState = ref.watch(userProfileProvider);
    final currentLocale = ref.watch(localeProvider);

    return FScaffold(
      resizeToAvoidBottomInset: false,
      header: const FHeader(title: SizedBox.shrink()),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: 16.0 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // User avatar section - centered
            _buildUserAvatarSection(context, theme, colors, userState),

            const SizedBox(height: 24),

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
                  onPress: () =>
                      context.goNamed(AppRouteNames.languageSettings),
                ),
                FTile(
                  prefix: _buildSettingIcon(context, FLucideIcons.dollarSign),
                  title: Text(t.settings.currency),
                  suffix: _buildTrailingValue(
                    context,
                    _getCurrencyDisplayName(ref),
                  ),
                  onPress: () =>
                      context.goNamed(AppRouteNames.currencySettings),
                ),
                FTile(
                  prefix: _buildSettingIcon(context, FLucideIcons.palette),
                  title: Text(t.settings.amountDisplayStyle),
                  suffix: _buildTrailingValue(
                    context,
                    _getAmountThemeDisplayName(ref),
                  ),
                  onPress: () =>
                      context.goNamed(AppRouteNames.amountStyleSettings),
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
                  onPress: () =>
                      context.pushNamed(AppRouteNames.sharedSpaceList),
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
                  onPress: () =>
                      context.goNamed(AppRouteNames.appearanceSettings),
                ),
                FTile(
                  prefix: _buildSettingIcon(context, FLucideIcons.info),
                  title: Text(t.settings.aboutApp),
                  suffix: Icon(
                    FLucideIcons.chevronRight,
                    size: 16,
                    color: colors.mutedForeground,
                  ),
                  onPress: () => _checkAppUpdate(context),
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
                  onPress: () => _handleLogout(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds the user avatar section
  Widget _buildUserAvatarSection(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    UserProfileState userState,
  ) {
    final user = userState.user;
    final isUploadingAvatar = userState.isUploadingAvatar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Header Section (Avatar + Username) -> Tap opens Edit Profile Modal
        GestureDetector(
          onTap: () => _openEditProfileSheet(context),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Avatar
                  isUploadingAvatar
                      ? Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: colors.muted,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border, width: 2),
                          ),
                          child: ClipOval(
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        )
                      : UserAvatar(
                          userId: user?.id ?? 'Finvo',
                          avatarUrl: user?.avatarUrl,
                          size: 88,
                          border: Border.all(color: colors.border, width: 2),
                          version:
                              userState.avatarCacheBuster ?? user?.updatedAt,
                        ),
                  // Edit pencil badge icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border, width: 1.5),
                      ),
                      child: Icon(
                        FLucideIcons.pencil,
                        size: 14,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Username display with subtle pencil
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userState.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.mutedForeground,
                      ),
                    )
                  else
                    Text(
                      user?.username ??
                          ref.watch(currentUserProvider)?.username ??
                          t.user.username,
                      style: theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Opens the ChatGPT style Edit Profile Bottom Sheet
  void _openEditProfileSheet(BuildContext context) {
    final userState = ref.read(userProfileProvider);
    final currentUsername =
        userState.user?.username ??
        ref.read(currentUserProvider)?.username ??
        '';
    _usernameController.text = currentUsername;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) {
          return _EditProfileBottomSheet(
            controller: _usernameController,
            onSave: (newUsername) async {
              if (newUsername.isEmpty) {
                ToastService.showDestructive(
                  description: Text(t.settings.usernameRequired),
                );
                return false;
              }
              final success = await ref
                  .read(userProfileProvider.notifier)
                  .updateUsername(newUsername);
              if (success) {
                ToastService.success(
                  description: Text(t.settings.usernameUpdated),
                );
                return true;
              } else {
                final error = ref.read(userProfileProvider).error;
                ToastService.showDestructive(
                  description: Text(error ?? t.common.error),
                );
                return false;
              }
            },
            onPickAvatar: _pickAndUploadAvatar,
          );
        },
      ),
    );
  }

  /// Pick and upload avatar
  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return;

    final success = await ref
        .read(userProfileProvider.notifier)
        .uploadAndUpdateAvatar(image);

    if (mounted) {
      if (success) {
        ToastService.success(description: Text(t.settings.avatarUpdated));
      } else {
        final error = ref.read(userProfileProvider).error;
        ToastService.showDestructive(
          description: Text(error ?? t.common.error),
        );
      }
    }
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

  /// Handles logout
  Future<void> _handleLogout(BuildContext context) async {
    unawaited(
      showConfirmDialog(
        context: context,
        title: t.auth.confirmLogoutTitle,
        message: t.auth.confirmLogoutContent,
        cancelLabel: t.common.cancel,
        confirmVariant: FButtonVariant.destructive,
        confirmLabel: t.auth.logout,
        onConfirm: () async {
          // Send toast message first to avoid context failure after redirection
          ToastService.success(description: Text(t.auth.logoutSuccess));

          await ref.read(authProvider.notifier).logout();
        },
      ),
    );
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

  /// Check app updates and display Forui update dialog
  Future<void> _checkAppUpdate(BuildContext context) async {
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

/// ChatGPT style Edit Profile Bottom Sheet
class _EditProfileBottomSheet extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Future<bool> Function(String) onSave;
  final VoidCallback onPickAvatar;

  const _EditProfileBottomSheet({
    required this.controller,
    required this.onSave,
    required this.onPickAvatar,
  });

  @override
  ConsumerState<_EditProfileBottomSheet> createState() =>
      __EditProfileBottomSheetState();
}

class __EditProfileBottomSheetState
    extends ConsumerState<_EditProfileBottomSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final userState = ref.watch(userProfileProvider);
    final user = userState.user;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: 24 + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top drag handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 4, bottom: 16),
                decoration: BoxDecoration(
                  color: colors.mutedForeground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Large Avatar with camera icon & uploading progress overlay
              GestureDetector(
                onTap: userState.isUploadingAvatar ? null : widget.onPickAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      userId: user?.id ?? 'Finvo',
                      avatarUrl: user?.avatarUrl,
                      size: 104,
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      version: userState.avatarCacheBuster ?? user?.updatedAt,
                    ),
                    if (userState.isUploadingAvatar)
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          userState.isUploadingAvatar
                              ? FLucideIcons.loader2
                              : FLucideIcons.camera,
                          size: 16,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Username Label & FTextField
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                  child: Text(
                    t.user.username,
                    style: theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: widget.controller,
                ),
                hint: t.settings.enterUsernameHint,
              ),
              const SizedBox(height: 16),

              // Help hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  t.settings.profileHelpHint,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // High contrast Pill Save profile button (Compact ChatGPT style)
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.primaryForeground,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          setState(() {
                            _isSaving = true;
                          });
                          final success = await widget.onSave(
                            widget.controller.text.trim(),
                          );
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                            });
                            if (success) {
                              navigator.pop();
                            }
                          }
                        },
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primaryForeground,
                          ),
                        )
                      : Text(
                          t.settings.saveProfile,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Clean text Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  t.common.cancel,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
