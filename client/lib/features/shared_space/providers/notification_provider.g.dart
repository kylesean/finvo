// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared-space notification provider.
///
/// Delegates generic notification CRUD to the central NotificationRepository.
/// Only adds space-specific logic (respondToSpaceInvite).

@ProviderFor(SharedSpaceNotification)
final sharedSpaceNotificationProvider = SharedSpaceNotificationProvider._();

/// Shared-space notification provider.
///
/// Delegates generic notification CRUD to the central NotificationRepository.
/// Only adds space-specific logic (respondToSpaceInvite).
final class SharedSpaceNotificationProvider
    extends
        $NotifierProvider<
          SharedSpaceNotification,
          SharedSpaceNotificationState
        > {
  /// Shared-space notification provider.
  ///
  /// Delegates generic notification CRUD to the central NotificationRepository.
  /// Only adds space-specific logic (respondToSpaceInvite).
  SharedSpaceNotificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSpaceNotificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSpaceNotificationHash();

  @$internal
  @override
  SharedSpaceNotification create() => SharedSpaceNotification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedSpaceNotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedSpaceNotificationState>(value),
    );
  }
}

String _$sharedSpaceNotificationHash() =>
    r'2c1c2f3a97cbd2ef46a935d583e757c177239906';

/// Shared-space notification provider.
///
/// Delegates generic notification CRUD to the central NotificationRepository.
/// Only adds space-specific logic (respondToSpaceInvite).

abstract class _$SharedSpaceNotification
    extends $Notifier<SharedSpaceNotificationState> {
  SharedSpaceNotificationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<SharedSpaceNotificationState, SharedSpaceNotificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                SharedSpaceNotificationState,
                SharedSpaceNotificationState
              >,
              SharedSpaceNotificationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Unread count derived from central notification provider

@ProviderFor(sharedSpaceUnreadCount)
final sharedSpaceUnreadCountProvider = SharedSpaceUnreadCountProvider._();

/// Unread count derived from central notification provider

final class SharedSpaceUnreadCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Unread count derived from central notification provider
  SharedSpaceUnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSpaceUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSpaceUnreadCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return sharedSpaceUnreadCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sharedSpaceUnreadCountHash() =>
    r'0ad81561aaa9877e8e96e880a8086b723963c25c';
