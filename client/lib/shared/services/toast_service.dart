// shared/services/toast_service.dart
import 'package:flutter/material.dart';
import 'package:finvo/app/router/app_router.dart';
import 'package:finvo/shared/widgets/top_toast.dart';

class ToastService {
  ToastService._(); // Private constructor

  static BuildContext? get _context => navigatorKey.currentContext;

  /// Get overlay state from navigator key
  static OverlayState? get _overlay => navigatorKey.currentState?.overlay;

  /// Pending toast invocations queued when context was not ready
  static final List<void Function(BuildContext context, OverlayState? overlay)>
  _pendingToasts = [];

  static void _showOrQueue(
    void Function(BuildContext context, OverlayState? overlay) action,
  ) {
    final context = _context;
    if (context != null) {
      _flushPending(context);
      action(context, _overlay);
    } else {
      _pendingToasts.add(action);
    }
  }

  /// Flush any buffered toast requests using the active context
  static void _flushPending(BuildContext context) {
    if (_pendingToasts.isEmpty) return;
    final overlay = _overlay;
    final pending = List.of(_pendingToasts);
    _pendingToasts.clear();
    for (final toastAction in pending) {
      toastAction(context, overlay);
    }
  }

  /// Show a standard Toast (using TopToast for top-center positioning)
  static void show({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    _showOrQueue((context, overlay) {
      TopToast.showWidget(
        context,
        description: description,
        title: title,
        type: ToastType.info,
        duration: duration ?? const Duration(seconds: 3),
        overlayState: overlay,
        action: action,
      );
    });
  }

  /// Show a success Toast
  static void success({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    _showOrQueue((context, overlay) {
      TopToast.showWidget(
        context,
        description: description,
        title: title,
        type: ToastType.success,
        duration: duration ?? const Duration(seconds: 3),
        overlayState: overlay,
        action: action,
      );
    });
  }

  /// Show a destructive (error) Toast
  static void showDestructive({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    _showOrQueue((context, overlay) {
      TopToast.showWidget(
        context,
        description: description,
        title: title,
        type: ToastType.error,
        duration: duration ?? const Duration(seconds: 3),
        overlayState: overlay,
        action: action,
      );
    });
  }

  /// Show a warning Toast
  static void showWarning({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    _showOrQueue((context, overlay) {
      TopToast.showWidget(
        context,
        description: description,
        title: title,
        type: ToastType.warning,
        duration: duration ?? const Duration(seconds: 3),
        overlayState: overlay,
        action: action,
      );
    });
  }
}
