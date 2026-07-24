import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// GenUI reusable bottom sheet container
///
/// Layer 3 (Organism) component, providing unified bottom sheet appearance and behavior.
/// Includes drag handle, title bar, and scrollable content area.
///
/// Usage:
/// ```dart
/// GenUIBottomSheet.show(
///   context: context,
///   title: 'Expense Details',
///   builder: (context) => TransactionListView(data: data),
/// );
/// ```
class GenUIBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final double heightFactor;

  const GenUIBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.heightFactor = 0.85,
  });

  /// Show bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    Widget? trailing,
    double heightFactor = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenUIBottomSheet(
        title: title,
        trailing: trailing,
        heightFactor: heightFactor,
        child: builder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
                FButton.icon(
                  variant: .ghost,
                  onPress: () => Navigator.pop(context),
                  child: Icon(
                    FLucideIcons.x,
                    size: 20,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: colors.border),

          // Content area - fills to bottom
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
