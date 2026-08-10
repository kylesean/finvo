// features/chat/widgets/welcome/suggestion_card.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// Suggestion card component
/// Compact design, sends prompt to AI on tap
class SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String prompt;
  final String description;
  final VoidCallback onTap;

  const SuggestionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.prompt,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: theme.style.borderRadius.lg,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colors.muted.withValues(alpha: 0.25),
            borderRadius: theme.style.borderRadius.lg,
            border: Border.all(
              color: theme.colors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              // Icon container - unified ThemedIcon styling
              ThemedIcon(icon: icon),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.listTrailing(theme),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Description
                    Text(
                      description,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow indicator
              Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: theme.colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
