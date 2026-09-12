// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notification Repository Provider

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// Notification Repository Provider

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  /// Notification Repository Provider
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'a9a637a020c8bc0922faf5bfcdf3206117ea0baa';

/// Notification State Notifier Provider

@ProviderFor(NotificationNotifier)
final notificationProvider = NotificationNotifierProvider._();

/// Notification State Notifier Provider
final class NotificationNotifierProvider
    extends $NotifierProvider<NotificationNotifier, NotificationState> {
  /// Notification State Notifier Provider
  NotificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNotifierHash();

  @$internal
  @override
  NotificationNotifier create() => NotificationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationState>(value),
    );
  }
}

String _$notificationNotifierHash() =>
    r'b9dfc9d6fd37e2a0aa3e2a7c685141d5077b64c9';

/// Notification State Notifier Provider

abstract class _$NotificationNotifier extends $Notifier<NotificationState> {
  NotificationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationState, NotificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationState, NotificationState>,
              NotificationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// WebSocket service provider for real-time notifications.
///
/// Initializes connection on first read and wires incoming
/// notifications to the central NotificationNotifier.
///
/// Marked [keepAlive] so the long-lived WebSocket connection is not torn down
/// when the widget that reads it (MyApp) stops listening. A plain auto-dispose
/// provider would dispose the connection (and trigger `onDispose`) as soon as
/// the build frame that read it completes.
/// Exposes the notification WebSocket connection state to the UI.
///
/// Without a consumer, a `failed` status (reconnect budget exhausted after a
/// server outage) meant push notifications silently died until the app
/// happened to resume. Surfaces it so the app shell can warn + offer retry.

@ProviderFor(notificationWsStatus)
final notificationWsStatusProvider = NotificationWsStatusProvider._();

/// WebSocket service provider for real-time notifications.
///
/// Initializes connection on first read and wires incoming
/// notifications to the central NotificationNotifier.
///
/// Marked [keepAlive] so the long-lived WebSocket connection is not torn down
/// when the widget that reads it (MyApp) stops listening. A plain auto-dispose
/// provider would dispose the connection (and trigger `onDispose`) as soon as
/// the build frame that read it completes.
/// Exposes the notification WebSocket connection state to the UI.
///
/// Without a consumer, a `failed` status (reconnect budget exhausted after a
/// server outage) meant push notifications silently died until the app
/// happened to resume. Surfaces it so the app shell can warn + offer retry.

final class NotificationWsStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationWsConnectionStatus>,
          NotificationWsConnectionStatus,
          Stream<NotificationWsConnectionStatus>
        >
    with
        $FutureModifier<NotificationWsConnectionStatus>,
        $StreamProvider<NotificationWsConnectionStatus> {
  /// WebSocket service provider for real-time notifications.
  ///
  /// Initializes connection on first read and wires incoming
  /// notifications to the central NotificationNotifier.
  ///
  /// Marked [keepAlive] so the long-lived WebSocket connection is not torn down
  /// when the widget that reads it (MyApp) stops listening. A plain auto-dispose
  /// provider would dispose the connection (and trigger `onDispose`) as soon as
  /// the build frame that read it completes.
  /// Exposes the notification WebSocket connection state to the UI.
  ///
  /// Without a consumer, a `failed` status (reconnect budget exhausted after a
  /// server outage) meant push notifications silently died until the app
  /// happened to resume. Surfaces it so the app shell can warn + offer retry.
  NotificationWsStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationWsStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationWsStatusHash();

  @$internal
  @override
  $StreamProviderElement<NotificationWsConnectionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationWsConnectionStatus> create(Ref ref) {
    return notificationWsStatus(ref);
  }
}

String _$notificationWsStatusHash() =>
    r'53bd2604ff602a98d4188db80193e902da1f4551';

@ProviderFor(notificationWs)
final notificationWsProvider = NotificationWsProvider._();

final class NotificationWsProvider
    extends
        $FunctionalProvider<
          NotificationWsService,
          NotificationWsService,
          NotificationWsService
        >
    with $Provider<NotificationWsService> {
  NotificationWsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationWsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationWsHash();

  @$internal
  @override
  $ProviderElement<NotificationWsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationWsService create(Ref ref) {
    return notificationWs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationWsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationWsService>(value),
    );
  }
}

String _$notificationWsHash() => r'ad02a730addc176f9ef28e1ca5c1c0fe1d05507b';
