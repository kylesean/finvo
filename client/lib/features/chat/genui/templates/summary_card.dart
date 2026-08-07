import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Summary card Widget implementation
class SummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const SummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    // AI-provided payloads are untrusted: guard every shape instead of
    // letting a TypeError escape during layout/build.
    final itemsRaw = data['items'];
    if (itemsRaw is! List) return const SizedBox.shrink();
    final items = itemsRaw;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title']?.toString() ?? '',
            style: AppTextStyles.listTitle(theme),
          ),
          const SizedBox(height: 12),
          Text(
            data['summary']?.toString() ?? '',
            style: theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
              height: 1.5,
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...items.map((item) {
              final i = item is Map ? Map<String, dynamic>.from(item) : null;
              if (i == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        i['label']?.toString() ?? '',
                        style: AppTextStyles.listSubtitle(theme),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        i['value']?.toString() ?? '',
                        style: AppTextStyles.listTrailing(theme),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
