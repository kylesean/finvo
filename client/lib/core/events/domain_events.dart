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

/// Unified buffered item: either a data event or an error. Used so [add] and
/// [addError] can share one ordered buffer and be replayed faithfully.
sealed class _BufferedItem<T> {
  const _BufferedItem();
}

class _BufferedData<T> extends _BufferedItem<T> {
  const _BufferedData(this.event);
  final T event;
}

class _BufferedError<T> extends _BufferedItem<T> {
  const _BufferedError(this.error, this.stackTrace);
  final Object error;
  final StackTrace? stackTrace;
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
  final List<_BufferedItem<T>> _pending = <_BufferedItem<T>>[];

  /// Upper bound on buffered events. If producers outpace the first listener
  /// attaching, the buffer is capped instead of growing without limit (a
  /// memory leak when a subscriber never arrives). The oldest events are
  /// dropped to keep the newest.
  static const int _maxPending = 200;

  BufferingBroadcastController() {
    _controller = StreamController<T>.broadcast(onListen: _replayPending);
  }

  /// Replay buffered events in order once a listener attaches. Fires each time
  /// a new listener subscribes; after the first replay the buffer is empty so
  /// later listeners only observe subsequent events.
  void _replayPending() {
    final toReplay = List<_BufferedItem<T>>.of(_pending);
    _pending.clear();
    for (final item in toReplay) {
      switch (item) {
        case final _BufferedData<T> data:
          _controller.add(data.event);
        case final _BufferedError<T> error:
          _controller.addError(error.error, error.stackTrace);
      }
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

  /// Buffer one [item] while no listener is attached, dropping the oldest item
  /// if the buffer is at its cap so it can never grow unboundedly.
  void _buffer(_BufferedItem<T> item) {
    if (_pending.length >= _maxPending) {
      _pending.removeAt(0);
    }
    _pending.add(item);
  }

  @override
  void add(T event) {
    if (hasListener) {
      _controller.add(event);
    } else {
      // No listener attached yet: buffer instead of dropping.
      _buffer(_BufferedData<T>(event));
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (hasListener) {
      _controller.addError(error, stackTrace);
    } else {
      // Keep addError consistent with add: buffer errors too so an error
      // emitted before the first listener is replayed (as an error) instead of
      // being silently discarded.
      _buffer(_BufferedError<T>(error, stackTrace));
    }
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
