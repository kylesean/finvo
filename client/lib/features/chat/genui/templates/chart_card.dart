import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Chart card Widget implementation
class ChartCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

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
          const SizedBox(height: 16),
          Container(
            height: 200,
            alignment: Alignment.center,
            child: Text(
              'Chart type: ${data['chartType']}\n(Requires full fl_chart library implementation)',
              textAlign: TextAlign.center,
              style: AppTextStyles.listSubtitle(theme),
            ),
          ),
        ],
      ),
    );
  }
}
