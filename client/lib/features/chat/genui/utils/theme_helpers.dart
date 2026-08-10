/// Theme-related helpers for consistent styling across GenUI components
///
/// Provides standardized icons, colors, and styles based on forui theme.
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/app/theme/app_semantic_colors.dart';

/// Account type visual configuration
class AccountTypeStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const AccountTypeStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

/// Gets icon and colors for account type
///
/// Uses the passed [colors] from context.theme.colors for theme consistency.
/// All colors are derived from theme primary color with different opacities.
AccountTypeStyle getAccountTypeStyle(String? type, FColors colors) {
  switch (type?.toLowerCase()) {
    case 'bank':
    case 'bank_card':
      return AccountTypeStyle(
        icon: FLucideIcons.landmark,
        iconColor: colors.primary,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
      );
    case 'cash':
      return AccountTypeStyle(
        icon: FLucideIcons.wallet,
        iconColor: colors.primary.withValues(alpha: 0.85),
        backgroundColor: colors.primary.withValues(alpha: 0.08),
      );
    case 'investment':
      return AccountTypeStyle(
        icon: FLucideIcons.trendingUp,
        iconColor: colors.primary.withValues(alpha: 0.7),
        backgroundColor: colors.primary.withValues(alpha: 0.06),
      );
    case 'credit_card':
      return AccountTypeStyle(
        icon: FLucideIcons.creditCard,
        iconColor: colors.primary.withValues(alpha: 0.55),
        backgroundColor: colors.primary.withValues(alpha: 0.05),
      );
    case 'alipay':
      return AccountTypeStyle(
        icon: FLucideIcons.smartphone,
        iconColor: colors.primary,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
      );
    case 'wechat':
      return AccountTypeStyle(
        icon: FLucideIcons.messageCircle,
        iconColor: colors.primary.withValues(alpha: 0.8),
        backgroundColor: colors.primary.withValues(alpha: 0.08),
      );
    default:
      return AccountTypeStyle(
        icon: FLucideIcons.wallet,
        iconColor: colors.mutedForeground,
        backgroundColor: colors.muted,
      );
  }
}

/// Category visual configuration
class CategoryStyle {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryStyle({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Gets name, icon and color for transaction category
///
/// Colors are derived from the theme's primary color at varying opacities
/// (mirroring [getAccountTypeStyle]) so category icons automatically adapt
/// to the active palette and dark mode.
CategoryStyle getCategoryStyle(String? categoryKey, FColors colors) {
  switch (categoryKey?.toLowerCase()) {
    case 'dining':
    case '1':
      return CategoryStyle(
        name: 'Dining',
        icon: FLucideIcons.utensils,
        color: colors.primary,
      );
    case 'transport':
    case '2':
      return CategoryStyle(
        name: 'Transport',
        icon: FLucideIcons.car,
        color: colors.primary.withValues(alpha: 0.9),
      );
    case 'shopping':
    case '3':
      return CategoryStyle(
        name: 'Shopping',
        icon: FLucideIcons.shoppingBag,
        color: colors.primary.withValues(alpha: 0.8),
      );
    case 'life':
    case '4':
      return CategoryStyle(
        name: 'Life Services',
        icon: FLucideIcons.home,
        color: colors.primary.withValues(alpha: 0.7),
      );
    case 'medical':
    case '5':
      return CategoryStyle(
        name: 'Medical',
        icon: FLucideIcons.heartPulse,
        color: colors.primary.withValues(alpha: 0.6),
      );
    case 'education':
    case '6':
      return CategoryStyle(
        name: 'Education',
        icon: FLucideIcons.graduationCap,
        color: colors.primary.withValues(alpha: 0.5),
      );
    case 'entertainment':
    case '7':
      return CategoryStyle(
        name: 'Entertainment',
        icon: FLucideIcons.gamepad2,
        color: colors.primary.withValues(alpha: 0.45),
      );
    case 'salary':
    case 'income':
    case '8':
      return CategoryStyle(
        name: 'Salary',
        icon: FLucideIcons.banknote,
        color: colors.primary,
      );
    case 'transfer':
      return CategoryStyle(
        name: 'Transfer',
        icon: FLucideIcons.arrowRightLeft,
        color: colors.primary.withValues(alpha: 0.7),
      );
    default:
      return CategoryStyle(
        name: 'Others',
        icon: FLucideIcons.receiptText,
        color: colors.primary.withValues(alpha: 0.4),
      );
  }
}

/// Transaction status configuration
class StatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const StatusStyle({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Gets label, color and icon for transaction status
///
/// Returns semantic colors for status indicators.
StatusStyle getStatusStyle(
  String? status,
  FColors colors, [
  AppSemanticColors? semantic,
]) {
  final warningColor =
      semantic?.warningAccent ?? colors.primary.withValues(alpha: 0.7);

  switch (status?.toLowerCase()) {
    case 'completed':
    case 'success':
      return StatusStyle(
        label: 'Completed',
        color: colors.primary,
        icon: FLucideIcons.check,
      );
    case 'pending':
      return StatusStyle(
        label: 'Pending',
        color: warningColor,
        icon: FLucideIcons.clock,
      );
    case 'failed':
    case 'error':
      return StatusStyle(
        label: 'Failed',
        color: colors.destructive,
        icon: FLucideIcons.x,
      );
    case 'cancelled':
      return StatusStyle(
        label: 'Cancelled',
        color: colors.mutedForeground,
        icon: FLucideIcons.x,
      );
    default:
      return StatusStyle(
        label: status ?? 'Unknown',
        color: colors.mutedForeground,
        icon: FLucideIcons.info,
      );
  }
}
