// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_space_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SharedSpaceNotifier)
final sharedSpaceProvider = SharedSpaceNotifierProvider._();

final class SharedSpaceNotifierProvider
    extends $NotifierProvider<SharedSpaceNotifier, SharedSpaceState> {
  SharedSpaceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSpaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSpaceNotifierHash();

  @$internal
  @override
  SharedSpaceNotifier create() => SharedSpaceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedSpaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedSpaceState>(value),
    );
  }
}

String _$sharedSpaceNotifierHash() =>
    r'cdd27defb33124a5e3c1245d40b10a659fc50503';

abstract class _$SharedSpaceNotifier extends $Notifier<SharedSpaceState> {
  SharedSpaceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SharedSpaceState, SharedSpaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SharedSpaceState, SharedSpaceState>,
              SharedSpaceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(spaceDetail)
final spaceDetailProvider = SpaceDetailFamily._();

final class SpaceDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedSpace>,
          SharedSpace,
          FutureOr<SharedSpace>
        >
    with $FutureModifier<SharedSpace>, $FutureProvider<SharedSpace> {
  SpaceDetailProvider._({
    required SpaceDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'spaceDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spaceDetailHash();

  @override
  String toString() {
    return r'spaceDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedSpace> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedSpace> create(Ref ref) {
    final argument = this.argument as String;
    return spaceDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpaceDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spaceDetailHash() => r'6aff9136a09a1b8c7f83a3fb932f73908b740909';

final class SpaceDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedSpace>, String> {
  SpaceDetailFamily._()
    : super(
        retry: null,
        name: r'spaceDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpaceDetailProvider call(String spaceId) =>
      SpaceDetailProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'spaceDetailProvider';
}

@ProviderFor(spaceSettlement)
final spaceSettlementProvider = SpaceSettlementFamily._();

final class SpaceSettlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<Settlement>,
          Settlement,
          FutureOr<Settlement>
        >
    with $FutureModifier<Settlement>, $FutureProvider<Settlement> {
  SpaceSettlementProvider._({
    required SpaceSettlementFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'spaceSettlementProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spaceSettlementHash();

  @override
  String toString() {
    return r'spaceSettlementProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Settlement> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Settlement> create(Ref ref) {
    final argument = this.argument as String;
    return spaceSettlement(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpaceSettlementProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spaceSettlementHash() => r'4d3556fbef2a5b7da9a8152b4d4e44313ca68f61';

final class SpaceSettlementFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Settlement>, String> {
  SpaceSettlementFamily._()
    : super(
        retry: null,
        name: r'spaceSettlementProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpaceSettlementProvider call(String spaceId) =>
      SpaceSettlementProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'spaceSettlementProvider';
}

/// Paginated transaction list for a shared space.
///
/// Keyed by [spaceId] so each space keeps an independent, accumulated list.
/// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
/// so the detail page can drive infinite-scroll through its scroll controller.

@ProviderFor(SpaceTransactionNotifier)
final spaceTransactionProvider = SpaceTransactionNotifierFamily._();

/// Paginated transaction list for a shared space.
///
/// Keyed by [spaceId] so each space keeps an independent, accumulated list.
/// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
/// so the detail page can drive infinite-scroll through its scroll controller.
final class SpaceTransactionNotifierProvider
    extends $NotifierProvider<SpaceTransactionNotifier, SpaceTransactionState> {
  /// Paginated transaction list for a shared space.
  ///
  /// Keyed by [spaceId] so each space keeps an independent, accumulated list.
  /// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
  /// so the detail page can drive infinite-scroll through its scroll controller.
  SpaceTransactionNotifierProvider._({
    required SpaceTransactionNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'spaceTransactionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spaceTransactionNotifierHash();

  @override
  String toString() {
    return r'spaceTransactionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SpaceTransactionNotifier create() => SpaceTransactionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceTransactionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceTransactionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpaceTransactionNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spaceTransactionNotifierHash() =>
    r'47b4e2e0f1dc2fc29e03512656c7f5945fe95290';

/// Paginated transaction list for a shared space.
///
/// Keyed by [spaceId] so each space keeps an independent, accumulated list.
/// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
/// so the detail page can drive infinite-scroll through its scroll controller.

final class SpaceTransactionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SpaceTransactionNotifier,
          SpaceTransactionState,
          SpaceTransactionState,
          SpaceTransactionState,
          String
        > {
  SpaceTransactionNotifierFamily._()
    : super(
        retry: null,
        name: r'spaceTransactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Paginated transaction list for a shared space.
  ///
  /// Keyed by [spaceId] so each space keeps an independent, accumulated list.
  /// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
  /// so the detail page can drive infinite-scroll through its scroll controller.

  SpaceTransactionNotifierProvider call(String spaceId) =>
      SpaceTransactionNotifierProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'spaceTransactionProvider';
}

/// Paginated transaction list for a shared space.
///
/// Keyed by [spaceId] so each space keeps an independent, accumulated list.
/// Mirrors [SharedSpaceNotifier]'s pagination contract (currentPage/hasMore)
/// so the detail page can drive infinite-scroll through its scroll controller.

abstract class _$SpaceTransactionNotifier
    extends $Notifier<SpaceTransactionState> {
  late final _$args = ref.$arg as String;
  String get spaceId => _$args;

  SpaceTransactionState build(String spaceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SpaceTransactionState, SpaceTransactionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpaceTransactionState, SpaceTransactionState>,
              SpaceTransactionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
