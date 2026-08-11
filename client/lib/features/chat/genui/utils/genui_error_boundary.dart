import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/i18n/strings.g.dart';

final _logger = Logger('GenUiErrorBoundary');

/// GenUI component error boundary
///
/// Catches child widget build errors and provides graceful degradation
///
/// Example:
/// ```dart
/// GenUiErrorBoundary(
///   componentName: 'TransferPathBuilder',
///   child: TransferPathBuilder(...),
/// )
/// ```
class GenUiErrorBoundary extends StatefulWidget {
  /// Either [child] or [builder] must be provided.
  ///
  /// Prefer [builder] when the subtree is expensive to construct: the builder
  /// is invoked inside this boundary's [State.build], so exceptions raised
  /// while constructing the subtree are caught here and degrade gracefully.
  /// A plain [child] widget is already constructed by the caller, so errors
  /// thrown later by the child's own `build` cannot be caught here — those are
  /// handled by the global [ErrorWidget.builder] fallback instead.
  final Widget? child;
  final Widget Function(BuildContext context)? builder;
  final String componentName;
  final Map<String, dynamic>? data;

  /// Custom error callback
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const GenUiErrorBoundary({
    super.key,
    this.child,
    this.builder,
    required this.componentName,
    this.data,
    this.onError,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided',
       );

  @override
  State<GenUiErrorBoundary> createState() => _GenUiErrorBoundaryState();
}

class _GenUiErrorBoundaryState extends State<GenUiErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _FallbackWidget(
        componentName: widget.componentName,
        error: _error.toString(),
      );
    }

    // Construct the guarded subtree inside this build so any exception raised
    // during construction (e.g. parsing untrusted AI data in a builder) is
    // caught here and degrades to the fallback UI. Errors thrown later by a
    // child widget's own build are outside this frame and are surfaced by the
    // global ErrorWidget.builder set up in main.dart.
    try {
      final builder = widget.builder;
      if (builder != null) {
        return builder(context);
      }
      return widget.child!;
    } catch (e, stack) {
      _handleError(e, stack);
      return _FallbackWidget(
        componentName: widget.componentName,
        error: e.toString(),
      );
    }
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    _logger.warning(
      'GenUiErrorBoundary: Error in ${widget.componentName}',
      error,
      stackTrace,
    );

    widget.onError?.call(error, stackTrace);

    // Defer setState to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    });
  }
}

/// Fallback UI widget
class _FallbackWidget extends StatelessWidget {
  final String componentName;
  final String error;

  const _FallbackWidget({required this.componentName, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.destructive.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FLucideIcons.circleAlert,
                  color: colors.destructive,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.error.genui.loadingFailed,
                      style: AppTextStyles.destructiveText(theme),
                    ),
                    Text(
                      componentName,
                      style: AppTextStyles.detailLabel(theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error,
              style: theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Public fallback widget (for external use)
class GenUiFallbackWidget extends StatelessWidget {
  final String componentName;
  final String error;

  const GenUiFallbackWidget({
    super.key,
    required this.componentName,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return _FallbackWidget(componentName: componentName, error: error);
  }
}
