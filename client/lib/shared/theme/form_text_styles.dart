import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Centralized text styles for the entire app, ensuring visual consistency
/// across all pages and components.
///
/// ## Core Design Principle
///
/// **Editable = w400 (Regular), Read-only / Identifying = w500 (Medium)**
///
/// - w400: User is actively editing (form inputs), or text is secondary
///   (labels, descriptions). The cursor or control widget provides visual
///   anchoring, so text stays light.
/// - w500: System displays information to user (list titles, detail values,
///   settings options). No cursor exists, so text needs more weight to feel
///   "solid" and identifiable.
///
/// ## Visual Hierarchy (top to bottom)
///
/// ```
/// pageTitle        (lg  / w500 / foreground)     — AppBar title
/// sectionHeader    (sm  / w500 / muted)          — Group labels
/// cardTitle        (md  / w500 / foreground)     — Card/list item name
/// detailValue      (md  / w500 / foreground)     — Read-only display
/// formValue        (md  / w400 / foreground)     — Editable input
/// switchTitle      (sm  / w400 / foreground)     — Toggle row title
/// formLabel        (xs  / w400 / muted)          — Inline label
/// ```
///
/// ## Usage
///
/// ```dart
/// import 'package:finvo/shared/theme/form_text_styles.dart';
///
/// Text('Account Name', style: AppTextStyles.formLabel(theme))
/// Text('¥1,234.00', style: AppTextStyles.statValue(theme))
/// ```
abstract class AppTextStyles {
  AppTextStyles._();

  // ===========================================================================
  // STRUCTURAL — Page-level hierarchy
  // ===========================================================================

  /// AppBar / page title
  /// Size: lg | Weight: w500 | Color: foreground
  static TextStyle pageTitle(FThemeData theme) => theme.typography.body.lg
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Large page title (e.g. financial accounts overview header)
  /// Size: xl | Weight: w500 | Color: foreground
  static TextStyle pageTitleLarge(FThemeData theme) => theme.typography.body.xl
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Dialog / bottom sheet title
  /// Size: md | Weight: w500 | Color: foreground
  static TextStyle dialogTitle(FThemeData theme) => theme.typography.body.md
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Section header / group label (e.g. "周期设置", "高级选项")
  /// Size: sm | Weight: w500 | Color: mutedForeground
  static TextStyle sectionHeader(FThemeData theme) =>
      theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.mutedForeground,
      );

  // ===========================================================================
  // FORM — Editable context (w400)
  // ===========================================================================

  /// Inline form label (next to icon, above input)
  /// Size: xs | Weight: regular | Color: mutedForeground
  static TextStyle formLabel(FThemeData theme) =>
      theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

  /// Standalone label above a text field (bottom sheets / dialogs)
  /// Size: sm | Weight: regular | Color: mutedForeground
  static TextStyle formFieldLabel(FThemeData theme) =>
      theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground);

  /// Form input value / user-editable text
  /// Size: md | Weight: regular | Color: foreground
  static TextStyle formValue(FThemeData theme) =>
      theme.typography.body.md.copyWith(color: theme.colors.foreground);

  /// Form input value with tabular figures (numeric fields)
  /// Size: md | Weight: regular | Color: foreground | Features: tabularFigures
  static TextStyle formValueNumeric(FThemeData theme) =>
      theme.typography.body.md.copyWith(
        color: theme.colors.foreground,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Switch / toggle row title
  /// Size: sm | Weight: regular | Color: foreground
  static TextStyle switchTitle(FThemeData theme) =>
      theme.typography.body.sm.copyWith(color: theme.colors.foreground);

  /// Switch / toggle row description
  /// Size: xs | Weight: regular | Color: mutedForeground
  static TextStyle switchSubtitle(FThemeData theme) =>
      theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

  // ===========================================================================
  // LIST / CARD — Read-only identifying context (w500)
  // ===========================================================================

  /// List item / card title (e.g. account name in list)
  /// Size: md | Weight: w500 | Color: foreground
  static TextStyle listTitle(FThemeData theme) => theme.typography.body.md
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// List item subtitle / secondary line
  /// Size: sm | Weight: regular | Color: mutedForeground
  static TextStyle listSubtitle(FThemeData theme) =>
      theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground);

  /// List item trailing text (e.g. balance amount on right)
  /// Size: sm | Weight: w500 | Color: foreground
  static TextStyle listTrailing(FThemeData theme) => theme.typography.body.sm
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// List item trailing muted (e.g. date, status)
  /// Size: xs | Weight: regular | Color: mutedForeground
  static TextStyle listTrailingMuted(FThemeData theme) =>
      theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

  // ===========================================================================
  // DETAIL — Read-only display context (w500)
  // ===========================================================================

  /// Detail page label (field name in read-only view)
  /// Size: xs | Weight: regular | Color: mutedForeground
  static TextStyle detailLabel(FThemeData theme) =>
      theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

  /// Detail page value (read-only display)
  /// Size: md | Weight: w500 | Color: foreground
  static TextStyle detailValue(FThemeData theme) => theme.typography.body.md
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Detail page large value (e.g. primary balance)
  /// Size: lg | Weight: w500 | Color: foreground
  static TextStyle detailValueLarge(FThemeData theme) => theme
      .typography
      .body
      .lg
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  // ===========================================================================
  // SETTINGS — FTile-style option rows (w500 for title, per Forui convention)
  // ===========================================================================

  /// Settings option title (FTile title equivalent)
  /// Size: md | Weight: w500 | Color: foreground
  static TextStyle settingTitle(FThemeData theme) => theme.typography.body.md
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Settings option subtitle / description
  /// Size: xs | Weight: regular | Color: mutedForeground
  static TextStyle settingSubtitle(FThemeData theme) =>
      theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

  /// Settings option trailing value (e.g. "CNY", "中文")
  /// Size: sm | Weight: regular | Color: mutedForeground
  static TextStyle settingTrailing(FThemeData theme) =>
      theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground);

  // ===========================================================================
  // STATS / METRICS — Dashboard numbers
  // ===========================================================================

  /// Primary stat value (e.g. total balance, net worth)
  /// Size: xl2 | Weight: w500 | Color: foreground
  static TextStyle statValue(FThemeData theme) => theme.typography.body.xl2
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Stat label (e.g. "总资产", "本月支出")
  /// Size: xs | Weight: w500 | Color: mutedForeground
  static TextStyle statLabel(FThemeData theme) =>
      theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.mutedForeground,
      );

  /// Stat value on dark/primary background
  /// Size: xl2 | Weight: bold | Color: primaryForeground
  static TextStyle statValueOnDark(FThemeData theme) =>
      theme.typography.body.xl2.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colors.primaryForeground,
      );

  /// Stat label on dark/primary background
  /// Size: sm | Weight: w500 | Color: primaryForeground (reduced alpha)
  static TextStyle statLabelOnDark(FThemeData theme) =>
      theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.primaryForeground.withValues(alpha: 0.9),
      );

  /// Stat secondary value on dark background (e.g. today/month expense)
  /// Size: md | Weight: w500 | Color: primaryForeground
  static TextStyle statValueOnDarkSecondary(FThemeData theme) =>
      theme.typography.body.md.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.primaryForeground,
      );

  /// Stat secondary label on dark background
  /// Size: xs | Weight: w500 | Color: primaryForeground (reduced alpha)
  static TextStyle statLabelOnDarkSecondary(FThemeData theme) =>
      theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.primaryForeground.withValues(alpha: 0.7),
      );

  // ===========================================================================
  // INTERACTIVE — Buttons, links, actions
  // ===========================================================================

  /// Action button text / inline link
  /// Size: sm | Weight: w500 | Color: primary
  static TextStyle actionText(FThemeData theme) => theme.typography.body.sm
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.primary);

  /// Destructive action text
  /// Size: sm | Weight: w500 | Color: destructive
  static TextStyle destructiveText(FThemeData theme) => theme.typography.body.sm
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.destructive);

  // ===========================================================================
  // MISC — Badges, pickers, calendar
  // ===========================================================================

  /// Badge / tag label (e.g. "Others owe me")
  /// Size: xs | Weight: w500 | Color: primary
  static TextStyle badge(FThemeData theme) => theme.typography.body.xs.copyWith(
    fontWeight: FontWeight.w500,
    color: theme.colors.primary,
  );

  /// Picker wheel item text
  /// Size: md | Weight: regular | Color: foreground
  static TextStyle pickerItem(FThemeData theme) =>
      theme.typography.body.md.copyWith(color: theme.colors.foreground);

  /// Calendar header title (e.g. "消费日历")
  /// Size: xl | Weight: w500 | Color: foreground
  static TextStyle calendarTitle(FThemeData theme) => theme.typography.body.xl
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Calendar footer info (e.g. "今天: ¥0.00")
  /// Size: sm | Weight: regular | Color: mutedForeground
  static TextStyle calendarFooter(FThemeData theme) =>
      theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground);

  /// Tab bar item text (selected)
  /// Size: sm | Weight: w500 | Color: primaryForeground
  static TextStyle tabSelected(FThemeData theme) =>
      theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.primaryForeground,
      );

  /// Tab bar item text (unselected)
  /// Size: sm | Weight: w500 | Color: mutedForeground
  static TextStyle tabUnselected(FThemeData theme) =>
      theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.mutedForeground,
      );

  /// Chat message category / tag label
  /// Size: sm | Weight: w500 | Color: foreground
  static TextStyle chatTag(FThemeData theme) => theme.typography.body.sm
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.foreground);

  /// Chat message muted info (e.g. timestamp, category label)
  /// Size: xs | Weight: w500 | Color: mutedForeground
  static TextStyle chatMeta(FThemeData theme) =>
      theme.typography.body.xs.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colors.mutedForeground,
      );

  /// Chat action link (e.g. category name in summary card)
  /// Size: sm | Weight: w500 | Color: primary
  static TextStyle chatAction(FThemeData theme) => theme.typography.body.sm
      .copyWith(fontWeight: FontWeight.w500, color: theme.colors.primary);
}
