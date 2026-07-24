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

import 'event_names.dart';
import 'space_events.dart';

/// Safely convert wire amount field (num or String) to double.
double _amountToDouble(Object? raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? 0.0;
  return 0.0;
}

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
  final double amount;
  final String currency;
  final String? memo;
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
    this.surfaceId,
  });

  factory TransferPathConfirmedEvent.fromContext(Map<String, dynamic> context) {
    return TransferPathConfirmedEvent(
      sourceAccountId: context['source_account_id'] as String? ?? '',
      targetAccountId: context['target_account_id'] as String? ?? '',
      sourceAccountName:
          context['source_account_name'] as String? ?? 'Source Account',
      targetAccountName:
          context['target_account_name'] as String? ?? 'Target Account',
      amount: _amountToDouble(context['amount']),
      currency: context['currency'] as String? ?? 'CNY',
      memo: context['memo'] as String?,
      surfaceId: context['surface_id'] as String?,
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
    'amount': amount,
    'currency': currency,
    'memo': memo,
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
    return SpaceSelectedEvent(
      spaceId: (context['space_id'] as num?)?.toInt() ?? 0,
      spaceName: context['space_name'] as String?,
      transactionIds:
          (context['transaction_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      surfaceId: context['surface_id'] as String?,
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
      accountId: context['account_id'] as String?,
      accountName: context['account_name'] as String?,
      accountType: context['account_type'] as String?,
      surfaceId: context['surface_id'] as String?,
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
      accountId: context['account_id'] as String?,
      accountName: context['account_name'] as String?,
      amount: context['amount'],
      description: context['description'] as String?,
      transactionType: context['transaction_type'] as String?,
      categoryKey: context['category_key'] as String?,
      currency: context['currency'] as String?,
      rawInput: context['raw_input'] as String?,
      tags: context['tags'] as List<dynamic>?,
      surfaceId: context['surface_id'] as String?,
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
