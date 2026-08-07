// shared/services/toast_service.dart
import 'package:flutter/material.dart';
import 'package:finvo/app/router/app_router.dart';
import 'package:finvo/shared/widgets/top_toast.dart';

class ToastService {
  ToastService._(); // Private constructor

  static BuildContext? get _context => navigatorKey.currentContext;

  /// Get overlay state from navigator key
  static OverlayState? get _overlay => navigatorKey.currentState?.overlay;

  /// Show a standard Toast (using TopToast for top-center positioning)
  static void show({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    final context = _context;
    if (context == null) return;

    TopToast.showWidget(
      context,
      description: description,
      title: title,
      type: ToastType.info,
      duration: duration ?? const Duration(seconds: 3),
      overlayState: _overlay,
      action: action,
    );
  }

  /// Show a success Toast
  static void success({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    final context = _context;
    if (context == null) return;

    TopToast.showWidget(
      context,
      description: description,
      title: title,
      type: ToastType.success,
      duration: duration ?? const Duration(seconds: 3),
      overlayState: _overlay,
      action: action,
    );
  }

  /// Show a destructive (error) Toast
  static void showDestructive({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    final context = _context;
    if (context == null) return;

    TopToast.showWidget(
      context,
      description: description,
      title: title,
      type: ToastType.error,
      duration: duration ?? const Duration(seconds: 3),
      overlayState: _overlay,
      action: action,
    );
  }

  /// Show a warning Toast
  static void showWarning({
    required Widget description,
    Widget? title,
    Duration? duration,
    TopToastAction? action,
  }) {
    final context = _context;
    if (context == null) return;

    TopToast.showWidget(
      context,
      description: description,
      title: title,
      type: ToastType.warning,
      duration: duration ?? const Duration(seconds: 3),
      overlayState: _overlay,
      action: action,
    );
  }
}
