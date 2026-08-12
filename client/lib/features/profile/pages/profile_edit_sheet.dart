// ChatGPT-style edit-profile bottom sheet, extracted from the 800-line
// profile page so the sheet can be reviewed and reused independently.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/profile/providers/user_profile_provider.dart';
import 'package:finvo/shared/widgets/user_avatar.dart';
import 'package:finvo/i18n/strings.g.dart';

/// ChatGPT style Edit Profile Bottom Sheet
class ProfileEditBottomSheet extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Future<bool> Function(String) onSave;
  final VoidCallback onPickAvatar;

  const ProfileEditBottomSheet({
    required this.controller,
    required this.onSave,
    required this.onPickAvatar,
    super.key,
  });

  @override
  ConsumerState<ProfileEditBottomSheet> createState() =>
      _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState
    extends ConsumerState<ProfileEditBottomSheet> {
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
