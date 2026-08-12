// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_conversation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Paginated conversation list state management

@ProviderFor(PaginatedConversation)
final paginatedConversationProvider = PaginatedConversationProvider._();

/// Paginated conversation list state management
final class PaginatedConversationProvider
    extends
        $NotifierProvider<PaginatedConversation, PaginatedConversationState> {
  /// Paginated conversation list state management
  PaginatedConversationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedConversationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedConversationHash();

  @$internal
  @override
  PaginatedConversation create() => PaginatedConversation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedConversationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedConversationState>(value),
    );
  }
}

String _$paginatedConversationHash() =>
    r'f23f03d3d88211c10a5faf867c07e53cb0c2d2aa';

/// Paginated conversation list state management

abstract class _$PaginatedConversation
    extends $Notifier<PaginatedConversationState> {
  PaginatedConversationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<PaginatedConversationState, PaginatedConversationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginatedConversationState,
                PaginatedConversationState
              >,
              PaginatedConversationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
