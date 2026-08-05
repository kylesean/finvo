import 'package:flutter/material.dart';
import 'package:finvo/features/home/models/daily_expense_summary_model.dart';

/// Background alpha applied to the theme primary color per heat level, as a
/// (light, dark) pair.
///
/// The daily calendar cell and the month trend strip intentionally use
/// different intensities (the strip is visually lighter). Both tables live
/// here so the two call sites stay consistent and can be tuned together —
/// previously they were maintained separately and could drift.
class HeatColorTables {
  static const Map<ExpenseHeatLevel, (double, double)> cell = {
    ExpenseHeatLevel.none: (0.0, 0.0),
    ExpenseHeatLevel.low: (0.2, 0.25),
    ExpenseHeatLevel.medium: (0.35, 0.4),
    ExpenseHeatLevel.high: (0.55, 0.6),
    ExpenseHeatLevel.veryHigh: (0.8, 0.85),
  };

  static const Map<ExpenseHeatLevel, (double, double)> strip = {
    ExpenseHeatLevel.none: (0.0, 0.0),
    ExpenseHeatLevel.low: (0.12, 0.15),
    ExpenseHeatLevel.medium: (0.25, 0.3),
    ExpenseHeatLevel.high: (0.45, 0.5),
    ExpenseHeatLevel.veryHigh: (0.7, 0.75),
  };
}

/// Resolve the heat-level background color, mirroring the original per-site
/// semantics exactly:
/// - `none` → transparent
/// - `veryHigh` → a direct translucent [base] overlay
/// - otherwise → [base] at the table alpha blended over [background]
Color heatLevelColor(
  ExpenseHeatLevel level, {
  required Map<ExpenseHeatLevel, (double, double)> table,
  required Color base,
  required Color background,
  required bool isDark,
}) {
  final (light, dark) = table[level]!;
  final alpha = isDark ? dark : light;

  if (level == ExpenseHeatLevel.none) {
    return Colors.transparent;
  }
  if (level == ExpenseHeatLevel.veryHigh) {
    return base.withValues(alpha: alpha);
  }
  return Color.alphaBlend(base.withValues(alpha: alpha), background);
}
