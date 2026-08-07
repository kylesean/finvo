import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/features/profile/services/profile_service.dart';
import 'package:finvo/features/profile/models/user_info.dart';
import 'package:finvo/features/chat/services/file_upload_service.dart';

part 'user_profile_provider.freezed.dart';
part 'user_profile_provider.g.dart';

/// User profile state
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

/// User profile notifier
///
/// [keepAlive] so the logged-in user is loaded once on login and reused across
/// screens without being torn down when a consuming screen leaves the tree.
@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  UserProfileState build() {
    // Pure build: MyApp triggers [loadUser] explicitly on successful login
    // instead of firing a network side-effect from build().
    return const UserProfileState();
  }

  ProfileService get _service => ref.read(profileServiceProvider);
  FileUploadService get _uploadService => ref.read(fileUploadServiceProvider);

  /// Load current user info
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update username
  Future<bool> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      final updatedUser = await _service.updateProfile(username: newUsername);
      state = state.copyWith(user: updatedUser, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
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
      return true;
    } catch (e) {
      state = state.copyWith(isUploadingAvatar: false, error: e.toString());
      return false;
    }
  }

  /// Update avatar with URL directly (for existing images)
  Future<bool> updateAvatarUrl(String avatarUrl) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final updatedUser = await _service.updateProfile(avatarUrl: avatarUrl);
      state = state.copyWith(user: updatedUser, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
