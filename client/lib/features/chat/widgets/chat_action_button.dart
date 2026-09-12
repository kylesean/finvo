import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Minimal action icon button used below AI chat messages (copy, thumbs up/down, share).
///
/// Extracted to a standalone [StatelessWidget] so element nodes remain stable across
/// parent rebuilds without recreating inline closure functions inside `build()`.
class ChatActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isFirst;

  /// Accessibility label for screen readers (icon-only button has no text).
  final String semanticLabel;

  const ChatActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(left: isFirst ? 0 : 12, right: 4),
          child: Container(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            alignment: Alignment.center,
            child: Icon(icon, color: color ?? colors.mutedForeground, size: 16),
          ),
        ),
      ),
    );
  }
}
