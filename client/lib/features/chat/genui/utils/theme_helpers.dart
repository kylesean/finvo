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
CategoryStyle getCategoryStyle(String? categoryKey) {
  switch (categoryKey?.toLowerCase()) {
    case 'dining':
    case '1':
      return const CategoryStyle(
        name: 'Dining',
        icon: Icons.restaurant,
        color: Color(0xFFF97316), // Orange
      );
    case 'transport':
    case '2':
      return const CategoryStyle(
        name: 'Transport',
        icon: Icons.directions_car,
        color: Color(0xFF3B82F6), // Blue
      );
    case 'shopping':
    case '3':
      return const CategoryStyle(
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: Color(0xFFEC4899), // Pink
      );
    case 'life':
    case '4':
      return const CategoryStyle(
        name: 'Life Services',
        icon: Icons.home,
        color: Color(0xFF10B981), // Green
      );
    case 'medical':
    case '5':
      return const CategoryStyle(
        name: 'Medical',
        icon: Icons.medical_services,
        color: Color(0xFFEF4444), // Red
      );
    case 'education':
    case '6':
      return const CategoryStyle(
        name: 'Education',
        icon: Icons.school,
        color: Color(0xFF8B5CF6), // Purple
      );
    case 'entertainment':
    case '7':
      return const CategoryStyle(
        name: 'Entertainment',
        icon: Icons.sports_esports,
        color: Color(0xFFF59E0B), // Amber
      );
    case 'salary':
    case 'income':
    case '8':
      return const CategoryStyle(
        name: 'Salary',
        icon: Icons.attach_money,
        color: Color(0xFF22C55E), // Green
      );
    case 'transfer':
      return const CategoryStyle(
        name: 'Transfer',
        icon: Icons.swap_horiz,
        color: Color(0xFF6366F1), // Indigo
      );
    default:
      return const CategoryStyle(
        name: 'Others',
        icon: Icons.receipt_long,
        color: Color(0xFFF97316), // Default orange
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
