// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationService)
final conversationServiceProvider = ConversationServiceProvider._();

final class ConversationServiceProvider
    extends
        $FunctionalProvider<
          ConversationService,
          ConversationService,
          ConversationService
        >
    with $Provider<ConversationService> {
  ConversationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationServiceHash();

  @$internal
  @override
  $ProviderElement<ConversationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationService create(Ref ref) {
    return conversationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationService>(value),
    );
  }
}

String _$conversationServiceHash() =>
    r'9df2218177ccdd1f021a0af3c6001d906574edce';

@ProviderFor(conversationList)
final conversationListProvider = ConversationListProvider._();

final class ConversationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationInfo>>,
          List<ConversationInfo>,
          FutureOr<List<ConversationInfo>>
        >
    with
        $FutureModifier<List<ConversationInfo>>,
        $FutureProvider<List<ConversationInfo>> {
  ConversationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationListHash();

  @$internal
  @override
  $FutureProviderElement<List<ConversationInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConversationInfo>> create(Ref ref) {
    return conversationList(ref);
  }
}

String _$conversationListHash() => r'73eb470256dadec04261277c964c12f0aca9b1fa';

@ProviderFor(ConversationListRefresh)
final conversationListRefreshProvider = ConversationListRefreshProvider._();

final class ConversationListRefreshProvider
    extends $NotifierProvider<ConversationListRefresh, int> {
  ConversationListRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationListRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationListRefreshHash();

  @$internal
  @override
  ConversationListRefresh create() => ConversationListRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$conversationListRefreshHash() =>
    r'f3bc1ad209066ba97293a5fa5320dc104a2cdeab';

abstract class _$ConversationListRefresh extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(refreshableConversationList)
final refreshableConversationListProvider =
    RefreshableConversationListProvider._();

final class RefreshableConversationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationInfo>>,
          List<ConversationInfo>,
          FutureOr<List<ConversationInfo>>
        >
    with
        $FutureModifier<List<ConversationInfo>>,
        $FutureProvider<List<ConversationInfo>> {
  RefreshableConversationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshableConversationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshableConversationListHash();

  @$internal
  @override
  $FutureProviderElement<List<ConversationInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConversationInfo>> create(Ref ref) {
    return refreshableConversationList(ref);
  }
}

String _$refreshableConversationListHash() =>
    r'c228748fd280d580dbe01fe66be2d4270efe2417';
