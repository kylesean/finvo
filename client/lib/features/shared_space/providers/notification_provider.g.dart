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
    r'175215bad3e9884af63f161e2919bb14f032205b';

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
