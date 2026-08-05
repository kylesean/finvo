// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current conversation expense Notifier
///
/// Tracks the active conversation; expense totals are derived from messages.

@ProviderFor(ConversationExpenseNotifier)
final conversationExpenseProvider = ConversationExpenseNotifierProvider._();

/// Current conversation expense Notifier
///
/// Tracks the active conversation; expense totals are derived from messages.
final class ConversationExpenseNotifierProvider
    extends
        $NotifierProvider<
          ConversationExpenseNotifier,
          ConversationExpenseState
        > {
  /// Current conversation expense Notifier
  ///
  /// Tracks the active conversation; expense totals are derived from messages.
  ConversationExpenseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationExpenseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationExpenseNotifierHash();

  @$internal
  @override
  ConversationExpenseNotifier create() => ConversationExpenseNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationExpenseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationExpenseState>(value),
    );
  }
}

String _$conversationExpenseNotifierHash() =>
    r'1aaa89a1eb2b82d78f331d975a5afd69a53b2904';

/// Current conversation expense Notifier
///
/// Tracks the active conversation; expense totals are derived from messages.

abstract class _$ConversationExpenseNotifier
    extends $Notifier<ConversationExpenseState> {
  ConversationExpenseState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ConversationExpenseState, ConversationExpenseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConversationExpenseState, ConversationExpenseState>,
              ConversationExpenseState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Current conversation expense statistics Provider
///
/// Derived purely from historical messages (uiComponents + toolCalls).
/// A single transaction is counted at most once per message via toolCallId
/// deduplication between the two data sources.

@ProviderFor(conversationTotalExpense)
final conversationTotalExpenseProvider = ConversationTotalExpenseProvider._();

/// Current conversation expense statistics Provider
///
/// Derived purely from historical messages (uiComponents + toolCalls).
/// A single transaction is counted at most once per message via toolCallId
/// deduplication between the two data sources.

final class ConversationTotalExpenseProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Current conversation expense statistics Provider
  ///
  /// Derived purely from historical messages (uiComponents + toolCalls).
  /// A single transaction is counted at most once per message via toolCallId
  /// deduplication between the two data sources.
  ConversationTotalExpenseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationTotalExpenseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationTotalExpenseHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return conversationTotalExpense(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$conversationTotalExpenseHash() =>
    r'857112985dce3985ce69b341cd32cbd17d53a33f';

/// Formatted current conversation expense title Provider
///

@ProviderFor(conversationExpenseTitle)
final conversationExpenseTitleProvider = ConversationExpenseTitleProvider._();

/// Formatted current conversation expense title Provider
///

final class ConversationExpenseTitleProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Formatted current conversation expense title Provider
  ///
  ConversationExpenseTitleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationExpenseTitleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationExpenseTitleHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return conversationExpenseTitle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$conversationExpenseTitleHash() =>
    r'd986d45cf47769c948101b9ce1d4e0596027204b';
