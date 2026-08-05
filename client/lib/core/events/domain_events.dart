import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_events.g.dart';

/// Fired whenever a transaction has been created outside the home feature
/// (currently: the AI chat flow). Home-side providers subscribe to this
/// stream and invalidate their own data, so features never reach into each
/// other's providers directly.
class TransactionCreatedEvent {
  final double amount;
  final String transactionType;
  final String currency;
  final DateTime occurredAt;

  const TransactionCreatedEvent({
    required this.amount,
    required this.transactionType,
    required this.currency,
    required this.occurredAt,
  });
}

/// Broadcast bus for [TransactionCreatedEvent].
///
/// Kept alive for the whole app lifetime: events must not be dropped just
/// because no listener happens to be attached at emit time.
@Riverpod(keepAlive: true)
StreamController<TransactionCreatedEvent> transactionCreatedEvents(Ref ref) {
  final controller = StreamController<TransactionCreatedEvent>.broadcast();
  ref.onDispose(controller.close);
  return controller;
}
