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

String _$conversationListHash() => r'2f159d36b15d027aa7e79d23070b865688d635f5';
