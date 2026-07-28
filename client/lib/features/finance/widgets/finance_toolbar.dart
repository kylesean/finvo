import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:animate_do/animate_do.dart';
import '../../../i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

class ForecastToolbar extends ConsumerWidget {
  const ForecastToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.forecast.title, style: AppTextStyles.statValue(theme)),
            Text(
              t.forecast.subtitle,
              style: theme.typography.body.md.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
