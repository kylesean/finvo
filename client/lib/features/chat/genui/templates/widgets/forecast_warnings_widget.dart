import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/amount_theme.dart';

class ForecastWarning {
  final DateTime date;
  final String type;
  final String message;

  ForecastWarning({
    required this.date,
    required this.type,
    required this.message,
  });

  factory ForecastWarning.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return ForecastWarning(
      date: parseDate(json['date']),
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class ForecastWarningsWidget extends StatelessWidget {
  final List<ForecastWarning> warnings;
  final AmountTheme amountTheme;

  const ForecastWarningsWidget({
    super.key,
    required this.warnings,
    required this.amountTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amountTheme.expenseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: amountTheme.expenseColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warnings.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.info,
                  size: 14,
                  color: amountTheme.expenseColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning.message,
                    style: theme.typography.body.xs.copyWith(
                      color: amountTheme.expenseColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
