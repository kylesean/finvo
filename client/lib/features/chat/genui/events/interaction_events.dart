/// Typed GenUI Interaction Events
///
/// Typed interaction event model — the single source of truth for GenUI button interaction wire contract.
///
/// Design rationale (P0: eliminate key-name spelling / type inconsistency bugs):
/// - In A2UI v0.9, Surface button interactions are emitted via genui [genui.UserActionEvent],
///   whose `context` is an untyped `Map<String, Object?>`. Before refactoring, dispatcher (component)
///   and handler (registry) relied on implicit string-key conventions for context structure,
///   which the compiler could not verify, leading to silent mismatches like
///   `sourceAccount` vs `source_account_id`.
/// - This model defines each interaction event as a sealed subclass; wire key names appear only once
///   in the corresponding class's [toContext] (encoding / dispatcher side) and `fromContext`
///   (decoding / handler side). Dispatcher emits via [toUserActionEvent], handler decodes via
///   [GenUiInteractionEvent.tryParse], both sharing the same typed contract.
/// - The sealed hierarchy enables exhaustive `switch` in the registry: adding a new event type
///   forces the compiler to require a handler, eliminating silent "unhandled" pass-through.
///
/// Behavioral contract (fully equivalent to pre-refactoring):
/// - [tryParse] returns null for unknown event names; the caller (InteractionRouter) falls back
///   to `Action: <name>`.
/// - Each event's `toContext` output is byte-level identical to the pre-refactoring inline context,
///   ensuring the backend contract remains unchanged.
library;

import 'package:genui/genui.dart' as genui;
import 'package:decimal/decimal.dart';

import 'package:finvo/features/chat/genui/events/event_names.dart';
import 'package:finvo/features/chat/genui/events/space_events.dart';

/// Safely convert wire amount field (num or String) to Decimal.
///
/// Backend money fields are serialized as strings (or sometimes numbers); parse
/// them back into [Decimal] so downstream arithmetic preserves full precision.
Decimal _amountToDecimal(Object? raw) {
  if (raw == null) return Decimal.zero;
  return Decimal.tryParse(raw.toString()) ?? Decimal.zero;
}

/// Decode an untrusted AI/backend-supplied context value as a String (CHAT-H2).
///
/// The context map is produced by the LLM and must never be trusted: a bare
/// `as String?` cast would TypeError on a numeric/boolean value and blow
/// through the request pipeline. `is`-check + `toString()` fallback keeps the
/// same defensive posture as [SpaceSelectedEvent.fromContext].
String? _asString(Object? value) => switch (value) {
  final String s => s,
  final num n => n.toString(),
  final bool b => b.toString(),
  _ => null,
};

/// GenUI interaction event base class.
///
/// Sealed to support exhaustive switch; each subclass corresponds to a wire event name ([eventName]).
sealed class GenUiInteractionEvent {
  const GenUiInteractionEvent();

  /// The `action.name` on the wire.
  String get eventName;

  /// Source Surface ID (nullable for events without surface context).
  String? get surfaceId;

  /// Encode to wire context (dispatcher side).
  ///
  /// Key names must be fully symmetric with the corresponding `fromContext` decoding.
  Map<String, dynamic> toContext();

  /// Encode to genui [genui.UserActionEvent] (unified dispatcher exit).
  ///
  /// [sourceComponentId] is the triggering component identifier, written to wire `action.sourceComponentId`.
  genui.UserActionEvent toUserActionEvent({required String sourceComponentId}) {
    return genui.UserActionEvent(
      name: eventName,
      sourceComponentId: sourceComponentId,
      context: toContext(),
    );
  }

  /// Decode wire action to typed event (unified handler entry).
  ///
  /// Returns null for unknown event names (caller falls back); known events return an instance
  /// even with missing fields (fields degrade to defaults), consistent with pre-refactoring lenient parsing.
  static GenUiInteractionEvent? tryParse(
    String? name,
    Map<String, dynamic> context,
  ) {
    return switch (name) {
      GenUiEventNames.transferPathConfirmed =>
        TransferPathConfirmedEvent.fromContext(context),
      SpaceEventNames.spaceSelected => SpaceSelectedEvent.fromContext(context),
      GenUiEventNames.accountSelected => AccountSelectedEvent.fromContext(
        context,
      ),
      GenUiEventNames.transactionConfirmedWithAccount =>
        TransactionConfirmedWithAccountEvent.fromContext(context),
      _ => null,
    };
  }
}

/// Transfer path confirmed event (`transfer_path_confirmed`).
///
/// Emitted by TransferWizard when user confirms the transfer path; the registry
/// generates a `direct_execute` atomic transfer mutation from it.
final class TransferPathConfirmedEvent extends GenUiInteractionEvent {
  final String sourceAccountId;
  final String targetAccountId;
  final String sourceAccountName;
  final String targetAccountName;
  final Decimal amount;
  final String currency;
  final String? memo;

  /// LLM-generated tags extracted from the user's message (e.g. ["转账"]).
  final List<String> tags;

  /// The user's original message that triggered this transfer (e.g. "转账"),
  /// persisted as the transaction's raw input.
  final String? rawInput;
  @override
  final String? surfaceId;

  const TransferPathConfirmedEvent({
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.sourceAccountName,
    required this.targetAccountName,
    required this.amount,
    this.currency = 'CNY',
    this.memo,
    this.tags = const [],
    this.rawInput,
    this.surfaceId,
  });

  factory TransferPathConfirmedEvent.fromContext(Map<String, dynamic> context) {
    final rawTags = context['tags'];
    return TransferPathConfirmedEvent(
      sourceAccountId: _asString(context['source_account_id']) ?? '',
      targetAccountId: _asString(context['target_account_id']) ?? '',
      sourceAccountName:
          _asString(context['source_account_name']) ?? 'Source Account',
      targetAccountName:
          _asString(context['target_account_name']) ?? 'Target Account',
      amount: _amountToDecimal(context['amount']),
      currency: _asString(context['currency']) ?? 'CNY',
      memo: _asString(context['memo']),
      tags: rawTags is List
          ? rawTags.map((e) => e.toString()).where((t) => t.isNotEmpty).toList()
          : const [],
      rawInput: _asString(context['raw_input']),
      surfaceId: _asString(context['surface_id']),
    );
  }

  @override
  String get eventName => GenUiEventNames.transferPathConfirmed;

  @override
  Map<String, dynamic> toContext() => {
    'surface_id': surfaceId,
    'source_account_id': sourceAccountId,
    'target_account_id': targetAccountId,
    'source_account_name': sourceAccountName,
    'target_account_name': targetAccountName,
    // Decimal is not JSON-serializable; serialize to string at the wire boundary.
    'amount': amount.toString(),
    'currency': currency,
    'memo': memo,
    'tags': tags,
    'raw_input': rawInput,
  };
}

/// Shared space selected event (`space_selected`).
///
/// Emitted by SpaceSelectorCard when user confirms space assignment; the registry
/// generates a `direct_execute` transaction association mutation from it.
final class SpaceSelectedEvent extends GenUiInteractionEvent {
  final int spaceId;
  final String? spaceName;
  final List<String> transactionIds;
  @override
  final String? surfaceId;

  const SpaceSelectedEvent({
    required this.spaceId,
    this.spaceName,
    this.transactionIds = const [],
    this.surfaceId,
  });

  factory SpaceSelectedEvent.fromContext(Map<String, dynamic> context) {
    // AI-supplied context is untrusted: decode defensively instead of casting
    // so a malformed value degrades to a sensible default instead of throwing
    // through the request pipeline.
    final rawIds = context['transaction_ids'];
    return SpaceSelectedEvent(
      spaceId: switch (context['space_id']) {
        final num n => n.toInt(),
        final String s => int.tryParse(s) ?? 0,
        _ => 0,
      },
      spaceName: context['space_name'] is String
          ? context['space_name'] as String
          : null,
      transactionIds: rawIds is List
          ? [
              for (final id in rawIds)
                if (id is String) id,
            ]
          : const [],
      surfaceId: context['surface_id'] is String
          ? context['surface_id'] as String
          : null,
    );
  }

  @override
  String get eventName => SpaceEventNames.spaceSelected;

  @override
  Map<String, dynamic> toContext() => {
    'surface_id': surfaceId,
    'space_id': spaceId,
    'space_name': spaceName ?? '',
    'transaction_ids': transactionIds,
  };
}

/// Account selected event (`account_selected`).
///
/// Emitted by AccountSelector when user taps an account; the registry generates
/// a human-readable message back to the LLM (no atomic mutation).
final class AccountSelectedEvent extends GenUiInteractionEvent {
  final String? accountId;
  final String? accountName;
  final String? accountType;
  @override
  final String? surfaceId;

  const AccountSelectedEvent({
    this.accountId,
    this.accountName,
    this.accountType,
    this.surfaceId,
  });

  factory AccountSelectedEvent.fromContext(Map<String, dynamic> context) {
    return AccountSelectedEvent(
      accountId: _asString(context['account_id']),
      accountName: _asString(context['account_name']),
      accountType: _asString(context['account_type']),
      surfaceId: _asString(context['surface_id']),
    );
  }

  @override
  String get eventName => GenUiEventNames.accountSelected;

  @override
  Map<String, dynamic> toContext() => {
    'account_id': accountId,
    'account_name': accountName,
    'account_type': accountType,
  };
}

/// Transaction confirmed (with account association) event (`transaction_confirmed_with_account`).
///
/// Emitted by TransactionConfirmation when user confirms the entry. Currently no atomic mutation;
/// the registry returns null for it, and InteractionRouter falls back (preserving pre-refactoring behavior).
/// After typing, the dispatcher side still gains compile-time key-name/type validation.
final class TransactionConfirmedWithAccountEvent extends GenUiInteractionEvent {
  final String? accountId;
  final String? accountName;
  final Object? amount;
  final String? description;
  final String? transactionType;
  final String? categoryKey;
  final String? currency;
  final String? rawInput;
  final List<dynamic>? tags;
  @override
  final String? surfaceId;

  const TransactionConfirmedWithAccountEvent({
    this.accountId,
    this.accountName,
    this.amount,
    this.description,
    this.transactionType,
    this.categoryKey,
    this.currency,
    this.rawInput,
    this.tags,
    this.surfaceId,
  });

  factory TransactionConfirmedWithAccountEvent.fromContext(
    Map<String, dynamic> context,
  ) {
    return TransactionConfirmedWithAccountEvent(
      accountId: _asString(context['account_id']),
      accountName: _asString(context['account_name']),
      amount: context['amount'],
      description: _asString(context['description']),
      transactionType: _asString(context['transaction_type']),
      categoryKey: _asString(context['category_key']),
      currency: _asString(context['currency']),
      rawInput: _asString(context['raw_input']),
      tags: context['tags'] is List ? context['tags'] as List<dynamic> : null,
      surfaceId: _asString(context['surface_id']),
    );
  }

  @override
  String get eventName => GenUiEventNames.transactionConfirmedWithAccount;

  @override
  Map<String, dynamic> toContext() => {
    'account_id': accountId,
    'account_name': accountName,
    'amount': amount,
    'description': description,
    'transaction_type': transactionType,
    'category_key': categoryKey,
    'currency': currency,
    'raw_input': rawInput,
    'tags': tags,
  };
}
