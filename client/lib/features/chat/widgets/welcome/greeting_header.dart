// features/chat/widgets/welcome/greeting_header.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_font_config.dart';

/// Greeting header component
/// Centered display of time-based greeting and subtitle
class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting - larger and more prominent
        Text(
          greeting,
          style: theme.typography.body.xl2.copyWith(
            // CJK font weight compensation: reduce one level to restore pre-upgrade visual weight.
            fontWeight: AppFontConfig.titleSemibold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        // Subtitle - concise hint
        Text(
          subtitle,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
