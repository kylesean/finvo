import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Toast type
enum ToastType { success, error, warning, info }

/// Optional action button rendered inside a [TopToast].
class TopToastAction {
  final String label;
  final VoidCallback onPressed;

  const TopToastAction({required this.label, required this.onPressed});
}

/// Top Toast utility class
class TopToast {
  static OverlayEntry? _currentEntry;

  /// Display a top toast with a plain [message] string.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    OverlayState? overlayState,
    TopToastAction? action,
  }) {
    _show(
      context,
      description: Text(message),
      type: type,
      duration: duration,
      overlayState: overlayState,
      action: action,
    );
  }

  /// Display a top toast with arbitrary [description] widget content and an
  /// optional [title] rendered above it.
  static void showWidget(
    BuildContext context, {
    required Widget description,
    Widget? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    OverlayState? overlayState,
    TopToastAction? action,
  }) {
    _show(
      context,
      description: description,
      title: title,
      type: type,
      duration: duration,
      overlayState: overlayState,
      action: action,
    );
  }

  static void _show(
    BuildContext context, {
    required Widget description,
    Widget? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    OverlayState? overlayState,
    TopToastAction? action,
  }) {
    // Remove previous toast
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = overlayState ?? Overlay.maybeOf(context);
    // If no overlay is found (e.g. context is from NavigatorKey), return to avoid crash
    if (overlay == null) {
      debugPrint('TopToast: No overlay found for context: $context');
      return;
    }

    final theme = context.theme;
    final colors = theme.colors;
    final semantic = theme.semantic;

    // Select color and icon based on type
    final (backgroundColor, iconData, iconColor) = switch (type) {
      ToastType.success => (
        semantic.successAccent,
        FLucideIcons.check,
        semantic.successAccent,
      ),
      ToastType.error => (
        colors.destructive,
        FLucideIcons.x,
        colors.destructive,
      ),
      ToastType.warning => (
        semantic.warningAccent,
        FLucideIcons.circleAlert,
        semantic.warningAccent,
      ),
      ToastType.info => (colors.primary, FLucideIcons.info, colors.primary),
    };

    // Each entry captures a reference to itself so its dismiss callback removes
    // exactly *this* entry, never the current (possibly newer) toast. This avoids
    // a stale toast's timer closing a freshly-shown one.
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        description: description,
        title: title,
        backgroundColor: backgroundColor,
        iconData: iconData,
        iconColor: iconColor,
        theme: theme,
        onDismiss: () {
          entry.remove();
          if (identical(_currentEntry, entry)) {
            _currentEntry = null;
          }
        },
        duration: duration,
        action: action,
      ),
    );

    _currentEntry = entry;

    try {
      overlay.insert(entry);
    } catch (e) {
      debugPrint('TopToast: Failed to insert overlay: $e');
    }
  }

  /// Display success message
  static void success(
    BuildContext context,
    String message, {
    OverlayState? overlay,
    TopToastAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      overlayState: overlay,
      action: action,
    );
  }

  /// Display error message
  static void error(
    BuildContext context,
    String message, {
    OverlayState? overlay,
    TopToastAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      overlayState: overlay,
      action: action,
    );
  }

  /// Display warning message
  static void warning(
    BuildContext context,
    String message, {
    OverlayState? overlay,
    TopToastAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      overlayState: overlay,
      action: action,
    );
  }

  /// Display info message
  static void info(
    BuildContext context,
    String message, {
    OverlayState? overlay,
    TopToastAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      overlayState: overlay,
      action: action,
    );
  }
}

class _TopToastWidget extends StatefulWidget {
  final Widget description;
  final Widget? title;
  final Color backgroundColor;
  final IconData iconData;
  final Color iconColor;
  final FThemeData theme;
  final VoidCallback onDismiss;
  final Duration duration;
  final TopToastAction? action;

  const _TopToastWidget({
    required this.description,
    this.title,
    required this.backgroundColor,
    required this.iconData,
    required this.iconColor,
    required this.theme,
    required this.onDismiss,
    required this.duration,
    this.action,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    unawaited(_controller.forward());

    // Auto dismiss
    unawaited(
      Future<void>.delayed(widget.duration).then((_) {
        if (mounted) {
          unawaited(_dismiss());
        }
      }),
    );
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < 0) {
                  unawaited(_dismiss());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.iconData,
                        size: 18,
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null)
                            DefaultTextStyle(
                              style: AppTextStyles.listTrailing(
                                widget.theme,
                              ).copyWith(fontWeight: FontWeight.w600),
                              child: widget.title!,
                            ),
                          DefaultTextStyle(
                            style: AppTextStyles.listTrailing(widget.theme),
                            child: widget.description,
                          ),
                        ],
                      ),
                    ),
                    if (widget.action != null)
                      GestureDetector(
                        onTap: () {
                          unawaited(_dismiss());
                          widget.action!.onPressed();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            widget.action!.label,
                            style: TextStyle(
                              color: widget.iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Icon(
                      FLucideIcons.x,
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
