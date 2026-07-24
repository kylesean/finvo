import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart' show UiEvent;

final _logger = Logger('HistoricalWrapper');

/// Historical mode utility class
///
/// Provides unified historical mode handling, including:
/// - Disable interactions
/// - Visual feedback
/// - noopDispatch function

/// Historical mode wrapper
///
/// Automatically handles:
/// - Disable interactions (IgnorePointer)
/// - Visual feedback (optional opacity adjustment)
/// - Badge marker (optional)
///
/// Example:
/// ```dart
/// HistoricalWrapper(
///   isHistorical: _isHistorical,
///   child: MyWidget(),
/// )
/// ```
class HistoricalWrapper extends StatelessWidget {
  final Widget child;
  final bool isHistorical;

  /// Whether to reduce opacity
  final bool dimOpacity;

  /// Opacity value (used when dimOpacity is true)
  final double opacity;

  /// Whether to show historical badge
  final bool showBadge;

  const HistoricalWrapper({
    super.key,
    required this.child,
    required this.isHistorical,
    this.dimOpacity = false,
    this.opacity = 0.85,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHistorical) return child;

    Widget result = child;

    // Optional: reduce opacity
    if (dimOpacity) {
      result = Opacity(opacity: opacity, child: result);
    }

    // Disable interactions
    return IgnorePointer(child: result);
  }
}

/// Historical mode helper functions
class HistoricalModeHelper {
  HistoricalModeHelper._();

  /// No-op event dispatcher
  ///
  /// Used to ignore all events in historical mode
  static void noopDispatch(UiEvent event) {
    _logger.info(
      'HistoricalModeHelper: Ignored event in historical mode: ${event.runtimeType}',
    );
  }

  /// Check if data contains historical mode marker
  static bool isHistorical(Map<String, dynamic>? data) {
    return data?['_isHistorical'] == true;
  }

  /// Add historical mode marker to data
  static Map<String, dynamic> markAsHistorical(Map<String, dynamic> data) {
    return {...data, '_isHistorical': true};
  }
}
