// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Conversation search state management

@ProviderFor(ConversationSearch)
final conversationSearchProvider = ConversationSearchProvider._();

/// Conversation search state management
final class ConversationSearchProvider
    extends $NotifierProvider<ConversationSearch, ConversationSearchState> {
  /// Conversation search state management
  ConversationSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationSearchHash();

  @$internal
  @override
  ConversationSearch create() => ConversationSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationSearchState>(value),
    );
  }
}

String _$conversationSearchHash() =>
    r'0cdfd0ef343d0ce3b4f849dc1c7c7f5090e168b2';

/// Conversation search state management

abstract class _$ConversationSearch extends $Notifier<ConversationSearchState> {
  ConversationSearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ConversationSearchState, ConversationSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConversationSearchState, ConversationSearchState>,
              ConversationSearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
