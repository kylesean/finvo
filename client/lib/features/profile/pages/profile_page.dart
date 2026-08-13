import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/profile/pages/profile_edit_sheet.dart';
import 'package:finvo/features/profile/pages/profile_settings_sections.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _usernameController = TextEditingController();
  final _logger = Logger('ProfilePage');

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final userState = ref.watch(userProfileProvider);

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

            // Settings tile groups (preferences / services / system)
            const ProfileSettingsSections(),

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
          return ProfileEditBottomSheet(
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
    // Guard the platform call: permission denial / an unavailable gallery
    // throws a PlatformException. Without this the exception escapes as an
    // uncaught async error (zone log only) and the user gets no feedback.
    final XFile? image;
    try {
      image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
    } catch (e, stackTrace) {
      _logger.warning('Failed to open image picker', e, stackTrace);
      if (mounted) {
        ToastService.showDestructive(description: Text(t.error.unknownError));
      }
      return;
    }

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
}
