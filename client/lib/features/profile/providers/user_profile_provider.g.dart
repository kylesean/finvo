// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User profile notifier
///
/// [keepAlive] so the logged-in user is loaded once on login and reused across
/// screens without being torn down when a consuming screen leaves the tree.

@ProviderFor(UserProfile)
final userProfileProvider = UserProfileProvider._();

/// User profile notifier
///
/// [keepAlive] so the logged-in user is loaded once on login and reused across
/// screens without being torn down when a consuming screen leaves the tree.
final class UserProfileProvider
    extends $NotifierProvider<UserProfile, UserProfileState> {
  /// User profile notifier
  ///
  /// [keepAlive] so the logged-in user is loaded once on login and reused across
  /// screens without being torn down when a consuming screen leaves the tree.
  UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  UserProfile create() => UserProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileState>(value),
    );
  }
}

String _$userProfileHash() => r'c75a28765e5f302e23b5f2cd661bd0e357bbda4e';

/// User profile notifier
///
/// [keepAlive] so the logged-in user is loaded once on login and reused across
/// screens without being torn down when a consuming screen leaves the tree.

abstract class _$UserProfile extends $Notifier<UserProfileState> {
  UserProfileState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserProfileState, UserProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserProfileState, UserProfileState>,
              UserProfileState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
