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

  const ChatActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          left: isFirst ? 0 : 20,
          right: 0,
          top: 4,
          bottom: 4,
        ),
        child: Icon(icon, color: color ?? colors.mutedForeground, size: 16),
      ),
    );
  }
}
