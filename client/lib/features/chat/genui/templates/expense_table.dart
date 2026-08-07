import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Data table Widget implementation
class ExpenseTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const ExpenseTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    // AI-provided payloads are untrusted: guard every shape instead of
    // letting a TypeError escape during build.
    final headers = data['headers'];
    final rows = data['rows'];
    if (headers is! List || rows is! List) {
      return const SizedBox.shrink();
    }

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: headers
                  .map(
                    (h) => DataColumn(
                      label: Text(
                        h.toString(),
                        style: AppTextStyles.listTrailing(theme),
                      ),
                    ),
                  )
                  .toList(),
              rows: rows.map((row) {
                if (row is! List) {
                  return const DataRow(cells: [DataCell(SizedBox.shrink())]);
                }
                final cells = row;
                return DataRow(
                  cells: cells
                      .map(
                        (cell) => DataCell(
                          Text(
                            cell.toString(),
                            style: theme.typography.body.sm,
                          ),
                        ),
                      )
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
