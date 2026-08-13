import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Chart card Widget implementation (CHAT-M9).
///
/// Renders the `ChartCard` GenUI component with fl_chart. Previously this was
/// a placeholder stub that displayed "Requires full fl_chart library
/// implementation" to the user.
///
/// Wire contract (see catalog_transaction_items.dart `_buildChartCard`):
/// ```
/// {
///   "title": string,
///   "chartType": "pie" | "bar" | "line" | "area" | "radar",
///   "chartData": {
///     "labels": [string],
///     "datasets": [{"label": string, "data": [number],
///                   "backgroundColor": string (hex, optional),
///                   "borderColor": string (optional)}]
///   },
///   "chartOptions": {"showLegend": bool, "showGrid": bool}
/// }
/// ```
/// AI-supplied data is untrusted: every field is coerced defensively and bad
/// items are skipped — a malformed chart degrades to an empty state instead
/// of crashing the message list.
class ChartCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ChartCard({super.key, required this.data});

  static Color _parseColor(String? raw, Color fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    var hex = raw.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(0xFF000000 | value);
      }
    }
    return fallback;
  }

  List<Color> _datasetColors(FColors colors, int datasetCount) {
    // Deterministic palette for datasets without an explicit backgroundColor.
    final palette = [
      colors.primary,
      colors.secondary,
      colors.muted,
      colors.destructive,
      colors.error,
    ];
    return List.generate(datasetCount, (i) => palette[i % palette.length]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    final title = data['title']?.toString() ?? '';
    final chartType = data['chartType']?.toString().toLowerCase() ?? '';

    final rawChartData = data['chartData'];
    final chartData = rawChartData is Map
        ? Map<String, dynamic>.from(rawChartData)
        : const <String, dynamic>{};
    final rawLabels = chartData['labels'];
    final labels = rawLabels is List
        ? [for (final l in rawLabels) l?.toString() ?? '']
        : <String>[];
    final rawDatasets = chartData['datasets'];
    final datasets = rawDatasets is List ? rawDatasets : const <dynamic>[];

    // Defensive per-dataset extraction: a malformed dataset is skipped
    // (GenUI philosophy: bad AI data degrades, never crashes).
    final parsedDatasets =
        <({String label, List<double> values, Color? color})>[];
    for (final raw in datasets) {
      if (raw is! Map) continue;
      final rawValues = raw['data'];
      if (rawValues is! List) continue;
      final values = <double>[];
      for (final v in rawValues) {
        final parsed = v is num
            ? v.toDouble()
            : double.tryParse(v?.toString() ?? '');
        if (parsed != null) values.add(parsed);
      }
      if (values.isEmpty) continue;
      parsedDatasets.add((
        label: raw['label']?.toString() ?? '',
        values: values,
        color: _parseColor(raw['backgroundColor']?.toString(), colors.primary),
      ));
    }

    if (parsedDatasets.isEmpty) {
      return _buildFrame(
        colors: colors,
        theme: theme,
        title: title,
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'No chart data available',
              style: AppTextStyles.listSubtitle(theme),
            ),
          ),
        ),
      );
    }

    final rawOptions = data['chartOptions'];
    final chartOptions = rawOptions is Map
        ? Map<String, dynamic>.from(rawOptions)
        : const <String, dynamic>{};
    final showLegend = chartOptions['showLegend'] as bool? ?? true;
    final showGrid = chartOptions['showGrid'] as bool? ?? true;

    final Widget chart = switch (chartType) {
      'pie' || 'donut' => _buildPieChart(colors, parsedDatasets),
      'bar' => _buildBarChart(colors, parsedDatasets, labels, showGrid),
      'line' || 'area' || 'radar' => _buildLineChart(
        colors,
        parsedDatasets,
        labels,
        showGrid,
        chartType == 'area',
      ),
      _ => SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Unsupported chart type: $chartType',
            style: AppTextStyles.listSubtitle(theme),
          ),
        ),
      ),
    };

    return _buildFrame(
      colors: colors,
      theme: theme,
      title: title,
      child: Column(
        children: [
          chart,
          if (showLegend && parsedDatasets.length > 1) ...[
            const SizedBox(height: 12),
            _buildLegend(colors, parsedDatasets),
          ],
        ],
      ),
    );
  }

  Widget _buildFrame({
    required FColors colors,
    required FThemeData theme,
    required String title,
    required Widget child,
  }) {
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
          if (title.isNotEmpty) ...[
            Text(title, style: AppTextStyles.listTitle(theme)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildPieChart(
    FColors colors,
    List<({String label, List<double> values, Color? color})> datasets,
  ) {
    // Pie: use the first dataset's values as slices.
    final ds = datasets.first;
    final palette = _datasetColors(colors, ds.values.length);
    final total = ds.values.fold<double>(0, (a, b) => a + b);
    final slices = <PieChartSectionData>[];
    for (var i = 0; i < ds.values.length; i++) {
      final value = ds.values[i];
      final pct = total == 0 ? 0.0 : value / total;
      slices.add(
        PieChartSectionData(
          value: value,
          color: ds.color ?? palette[i],
          title: pct >= 0.08 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: slices,
          sectionsSpace: 2,
          centerSpaceRadius: total == 0 ? 60 : 36,
        ),
      ),
    );
  }

  Widget _buildBarChart(
    FColors colors,
    List<({String label, List<double> values, Color? color})> datasets,
    List<String> labels,
    bool showGrid,
  ) {
    final maxValues = <double>[];
    for (var i = 0; i < labels.length; i++) {
      var max = 0.0;
      for (final ds in datasets) {
        if (i < ds.values.length && ds.values[i] > max) max = ds.values[i];
      }
      maxValues.add(max);
    }
    final maxY = maxValues.isEmpty
        ? 1.0
        : maxValues.reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY : 1.0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showGrid,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < labels.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  for (final ds in datasets)
                    if (i < ds.values.length)
                      BarChartRodData(
                        toY: ds.values[i],
                        color: ds.color ?? colors.primary,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    FColors colors,
    List<({String label, List<double> values, Color? color})> datasets,
    List<String> labels,
    bool showGrid,
    bool fillArea,
  ) {
    final allValues = [for (final ds in datasets) ...ds.values];
    final maxY = allValues.isEmpty
        ? 1.0
        : allValues.reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          maxY: maxY > 0 ? maxY : 1.0,
          minY: 0,
          gridData: FlGridData(show: showGrid),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showGrid,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            for (var d = 0; d < datasets.length; d++)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < datasets[d].values.length; i++)
                    FlSpot(i.toDouble(), datasets[d].values[i]),
                ],
                color: datasets[d].color ?? colors.primary,
                isCurved: true,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: fillArea
                    ? BarAreaData(
                        show: true,
                        color: (datasets[d].color ?? colors.primary).withValues(
                          alpha: 0.15,
                        ),
                      )
                    : BarAreaData(show: false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
    FColors colors,
    List<({String label, List<double> values, Color? color})> datasets,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final ds in datasets)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: ds.color ?? colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ds.label.isEmpty ? 'Dataset' : ds.label,
                style: TextStyle(fontSize: 12, color: colors.mutedForeground),
              ),
            ],
          ),
      ],
    );
  }
}
