import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A wrapper around FBadge for consistent tag styling
///
/// This is a Layer 1 (Atom) component for displaying
/// text labels or tags.
///
/// Example:
/// ```dart
/// Tag(label: 'Coffee')
/// ```
class Tag extends StatelessWidget {
  /// The text label to display
  final String label;

  /// Optional style override
  final FBadgeStyle? style;

  /// Standard variant (default: secondary)
  final bool isPrimary;
  final bool isOutline;
  final bool isDestructive;

  const Tag({
    super.key,
    required this.label,
    this.style,
    this.isPrimary = false,
    this.isOutline = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    FBadgeVariant variant;

    if (isPrimary) {
      variant = .primary;
    } else if (isOutline) {
      variant = .outline;
    } else if (isDestructive) {
      variant = .destructive;
    } else {
      variant = .secondary;
    }

    return FBadge(variant: variant, child: Text(label));
  }
}
