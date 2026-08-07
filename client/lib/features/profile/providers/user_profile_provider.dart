import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finvo/shared/utils/error_message.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/profile/models/user_info.dart';
import 'package:finvo/features/profile/services/profile_service.dart';
import 'package:finvo/features/chat/services/file_upload_service.dart';

part 'user_profile_provider.freezed.dart';
part 'user_profile_provider.g.dart';

@freezed
abstract class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    UserInfo? user,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool isUploadingAvatar,
    String? error,
  }) = _UserProfileState;
}

@riverpod
class UserProfile extends _$UserProfile {
  @override
  UserProfileState build() {
    return const UserProfileState();
  }

  ProfileService get _service => ref.read(profileServiceProvider);
  FileUploadService get _uploadService => ref.read(fileUploadServiceProvider);

  void _syncUserWithAuth() {
    unawaited(ref.read(authProvider.notifier).refreshUser());
  }

  /// Load current user info
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: safeErrorMessage(e));
    }
  }

  /// Update username
  Future<bool> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      final updatedUser = await _service.updateProfile(username: newUsername);
      state = state.copyWith(user: updatedUser, isSaving: false);
      _syncUserWithAuth();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: safeErrorMessage(e));
      return false;
    }
  }

  /// Upload avatar and update profile
  Future<bool> uploadAndUpdateAvatar(XFile imageFile) async {
    state = state.copyWith(isUploadingAvatar: true, error: null);

    try {
      // 1. Upload image to server
      final uploadResult = await _uploadService.uploadFiles([imageFile]);

      if (uploadResult.uploads.isEmpty) {
        throw Exception('Image upload failed');
      }

      // 2. Get uploaded image URL
      final avatarUrl = uploadResult.uploads.first.uri;

      // 3. Update profile with new avatar URL
      final updatedUser = await _service.updateProfile(avatarUrl: avatarUrl);

      state = state.copyWith(user: updatedUser, isUploadingAvatar: false);
      _syncUserWithAuth();
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: safeErrorMessage(e),
      );
      return false;
    }
  }

  /// Update avatar with URL directly (for existing images)
  Future<bool> updateAvatarUrl(String avatarUrl) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final updatedUser = await _service.updateProfile(avatarUrl: avatarUrl);
      state = state.copyWith(user: updatedUser, isSaving: false);
      _syncUserWithAuth();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: safeErrorMessage(e));
      return false;
    }
  }
}
