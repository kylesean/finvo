/// GenUI Event Registry
///
/// Event registry — decouples ContentGenerator/InteractionRouter from business logic.
///
/// Design rationale (P0 typed refactoring):
/// - Handlers take [GenUiInteractionEvent] sealed hierarchy as input, dispatching via exhaustive `switch`.
///   Adding a new event type forces the compiler to require a handler branch, eliminating silent "unhandled" pass-through.
/// - Registry no longer maintains string-key -> handler dynamic mapping; event wire contract is
///   defined at a single point by the sealed types in `events/interaction_events.dart`.
/// - Router only handles `tryParse` + calling [handle], without needing to know specific business events.
///
/// Usage:
/// ```dart
/// final event = GenUiInteractionEvent.tryParse(name, context);
/// if (event != null) {
///   final result = GenUiEventRegistry.handle(event);
///   if (result != null && !result.isEmpty) {
///     body['client_state'] = result.mutation?.toJson();
///   }
/// }
/// ```
library;

import 'package:logging/logging.dart';

import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/chat/models/client_state_mutation.dart';
import 'package:finvo/features/chat/genui/events/interaction_events.dart';

/// Event processing result
///
/// Contains business mutation (ClientStateMutation) and optional payload extensions sent to LLM
class EventProcessingResult {
  final ClientStateMutation? mutation;
  final Map<String, dynamic>? payloadExtensions;

  const EventProcessingResult({this.mutation, this.payloadExtensions});

  bool get isEmpty => mutation == null && payloadExtensions == null;
}

/// GenUI event registry
///
/// Stateless dispatcher with sealed event types as input.
class GenUiEventRegistry {
  GenUiEventRegistry._(); // Prevent instantiation

  static final _logger = Logger('GenUiEventRegistry');

  /// Dispatch typed event, return business processing result.
  ///
  /// Exhaustive `switch` guarantees compile-time enforcement of handler implementation when adding new [GenUiInteractionEvent] subclasses.
  /// Returns null when the event has no business handler (caller falls back).
  static EventProcessingResult? handle(GenUiInteractionEvent event) {
    _logger.fine('GenUiEventRegistry: handling "${event.eventName}"');
    return switch (event) {
      TransferPathConfirmedEvent() => _handleTransferPathConfirmed(event),
      SpaceSelectedEvent() => _handleSpaceSelected(event),
      AccountSelectedEvent() => _handleAccountSelected(event),
      // Transaction confirmation (with account) currently has no atomic mutation, return null to let Router fall back,
      // preserving behavior fully consistent with pre-refactoring.
      TransactionConfirmedWithAccountEvent() => null,
    };
  }

  /// Transfer path confirmed -> direct_execute atomic transfer.
  static EventProcessingResult _handleTransferPathConfirmed(
    TransferPathConfirmedEvent event,
  ) {
    return EventProcessingResult(
      mutation: ClientStateMutation.forTransfer(
        surfaceId: event.surfaceId,
        sourceAccountId: event.sourceAccountId,
        targetAccountId: event.targetAccountId,
        sourceAccountName: event.sourceAccountName,
        targetAccountName: event.targetAccountName,
        amount: event.amount,
        currency: event.currency,
      ),
      payloadExtensions: {
        'role': 'user',
        'content': t.chat.genui.transferPath.executeAction,
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }

  /// Space selected -> direct_execute transaction association.
  static EventProcessingResult _handleSpaceSelected(SpaceSelectedEvent event) {
    return EventProcessingResult(
      mutation: ClientStateMutation.forSpaceAssociation(
        surfaceId: event.surfaceId,
        spaceId: event.spaceId,
        transactionIds: event.transactionIds,
      ),
      payloadExtensions: {
        'role': 'user',
        'content': t.chat.genui.spaceSelector.associateAction,
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }

  /// Account selected -> human-readable message back to LLM (no atomic mutation).
  static EventProcessingResult _handleAccountSelected(
    AccountSelectedEvent event,
  ) {
    return EventProcessingResult(
      payloadExtensions: {
        'role': 'user',
        'content':
            'I selected account ID: ${event.accountId} (${event.accountType})',
        'metadata': {'event_type': event.eventName, ...event.toContext()},
      },
    );
  }
}
