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

/// A buffering broadcast controller that never drops events.
///
/// A raw `StreamController.broadcast()` silently discards events published
/// while no listener is attached. This class buffers such events and replays
/// them (in order) once the first listener subscribes, honouring the invariant
/// "events must not be dropped just because no listener happens to be attached
/// at emit time" (e.g. a transaction created by the AI chat flow before the
/// home feature's subscriber first activates).
///
/// Implemented via composition + `implements StreamController<T>` because
/// `StreamController` only exposes factory constructors and therefore cannot
/// be subclassed with `extends`.
class BufferingBroadcastController<T> implements StreamController<T> {
  late final StreamController<T> _controller;
  final List<T> _pending = <T>[];

  BufferingBroadcastController() {
    _controller = StreamController<T>.broadcast(onListen: _replayPending);
  }

  /// Replay buffered events in order once a listener attaches. Fires each time
  /// a new listener subscribes; after the first replay the buffer is empty so
  /// later listeners only observe subsequent events.
  void _replayPending() {
    final toReplay = List<T>.of(_pending);
    _pending.clear();
    for (final event in toReplay) {
      _controller.add(event);
    }
  }

  @override
  Stream<T> get stream => _controller.stream;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  void add(T event) {
    if (hasListener) {
      _controller.add(event);
    } else {
      // No listener attached yet: buffer instead of dropping.
      _pending.add(event);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    return _controller.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future<void> close() => _controller.close();

  @override
  Future<void> get done => _controller.done;

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  void Function()? get onListen => _controller.onListen;

  @override
  set onListen(void Function()? onListenHandler) {
    _controller.onListen = onListenHandler;
  }

  @override
  void Function()? get onPause => _controller.onPause;

  @override
  set onPause(void Function()? onPauseHandler) {
    _controller.onPause = onPauseHandler;
  }

  @override
  void Function()? get onResume => _controller.onResume;

  @override
  set onResume(void Function()? onResumeHandler) {
    _controller.onResume = onResumeHandler;
  }

  @override
  void Function()? get onCancel => _controller.onCancel;

  @override
  set onCancel(void Function()? onCancelHandler) {
    _controller.onCancel = onCancelHandler;
  }
}

/// Buffering broadcast bus for [TransactionCreatedEvent].
///
/// Kept alive for the whole app lifetime: events must not be dropped just
/// because no listener happens to be attached at emit time.
@Riverpod(keepAlive: true)
StreamController<TransactionCreatedEvent> transactionCreatedEvents(Ref ref) {
  final controller = BufferingBroadcastController<TransactionCreatedEvent>();
  ref.onDispose(controller.close);
  return controller;
}
