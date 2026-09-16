import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Amount display theme configuration
///
/// Provides three preset color schemes:
/// - [chinaMarket] - China market (Red increase, Black decrease, default)
/// - [international] - International standard (Green increase, Red decrease)
/// - [minimalist] - Minimalist (All black + symbols)
///
/// Usage:
/// ```dart
/// final theme = AmountTheme.chinaMarket;
/// final color = theme.incomeColor; // Income color
/// ```
class AmountTheme {
  /// Expense color (default dark gray/red)
  final Color expenseColor;

  /// Income color (default red/green)
  final Color incomeColor;

  /// Transfer color (neutral gray)
  final Color transferColor;

  /// Neutral color (for scenarios that don't distinguish income/expense)
  final Color neutralColor;

  /// Dark-mode variants. `null` falls back to the light value.
  ///
  /// The light values above are tuned for white backgrounds (gray-700/800
  /// body text). On a dark background they collapse to ~1.4–2.0:1 contrast —
  /// unreadable for the primary datum of a finance app — so every palette
  /// ships explicit, lighter dark-mode counterparts.
  final Color? darkExpenseColor;
  final Color? darkIncomeColor;
  final Color? darkTransferColor;
  final Color? darkNeutralColor;

  const AmountTheme({
    required this.expenseColor,
    required this.incomeColor,
    required this.transferColor,
    required this.neutralColor,
    this.darkExpenseColor,
    this.darkIncomeColor,
    this.darkTransferColor,
    this.darkNeutralColor,
  });

  /// Resolve the palette for [brightness].
  AmountTheme resolve(Brightness brightness) {
    if (brightness == Brightness.light) return this;
    return AmountTheme(
      expenseColor: darkExpenseColor ?? expenseColor,
      incomeColor: darkIncomeColor ?? incomeColor,
      transferColor: darkTransferColor ?? transferColor,
      neutralColor: darkNeutralColor ?? neutralColor,
    );
  }

  /// Resolve against the ambient Forui theme.
  static AmountTheme of(BuildContext context, AmountTheme theme) =>
      theme.resolve(context.theme.colors.brightness);

  /// China market color scheme (default)
  ///
  /// - Income: Red (represents auspiciousness and growth in Chinese culture)
  /// - Expense: Dark gray (neutral, reduces anxiety)
  /// - Transfer: Medium gray
  ///
  /// Reference: Ant Design financial design specifications
  static const chinaMarket = AmountTheme(
    expenseColor: Color(0xFF374151), // gray-700, dark gray
    incomeColor: Color(0xFFDC2626), // red-600, Chinese red
    transferColor: Color(0xFF6B7280), // gray-500
    neutralColor: Color(0xFF1F2937), // gray-800
    darkExpenseColor: Color(0xFFD1D5DB), // gray-300
    darkIncomeColor: Color(0xFFF87171), // red-400
    darkTransferColor: Color(0xFF9CA3AF), // gray-400
    darkNeutralColor: Color(0xFFE5E7EB), // gray-200
  );

  /// International market color scheme
  ///
  /// - Income: Green (represents growth, profit)
  /// - Expense: Red (represents deficit, Red Ink)
  /// - Transfer: Medium gray
  ///
  /// Complies with Western accounting conventions and global standards
  static const international = AmountTheme(
    expenseColor: Color(0xFFDC2626), // red-600, deficit red
    incomeColor: Color(0xFF16A34A), // green-600, growth green
    transferColor: Color(0xFF6B7280), // gray-500
    neutralColor: Color(0xFF1F2937), // gray-800
    darkExpenseColor: Color(0xFFF87171), // red-400
    darkIncomeColor: Color(0xFF4ADE80), // green-400
    darkTransferColor: Color(0xFF9CA3AF), // gray-400
    darkNeutralColor: Color(0xFFE5E7EB), // gray-200
  );

  /// Minimalist color scheme
  ///
  /// All use dark gray, only distinguish income/expense via +/- symbols
  /// Suitable for information-dense transaction lists, reduces visual fatigue
  ///
  /// Reference: Revolut, Monzo and other modern financial app design trends
  static const minimalist = AmountTheme(
    expenseColor: Color(0xFF374151), // gray-700
    incomeColor: Color(0xFF374151), // gray-700
    transferColor: Color(0xFF6B7280), // gray-500
    neutralColor: Color(0xFF1F2937), // gray-800
    darkExpenseColor: Color(0xFFD1D5DB), // gray-300
    darkIncomeColor: Color(0xFFD1D5DB), // gray-300
    darkTransferColor: Color(0xFF9CA3AF), // gray-400
    darkNeutralColor: Color(0xFFE5E7EB), // gray-200
  );

  /// Color-blind friendly color scheme
  ///
  /// Uses blue and orange, more friendly for red-green colorblind users
  /// Blue: Expense (cool tone)
  /// Orange: Income (warm tone)
  static const colorBlindFriendly = AmountTheme(
    expenseColor: Color(0xFF2563EB), // blue-600
    incomeColor: Color(0xFFC2410C), // orange-700 (WCAG AA compliant >= 4.5:1)
    transferColor: Color(0xFF6B7280), // gray-500
    neutralColor: Color(0xFF1F2937), // gray-800
    darkExpenseColor: Color(0xFF60A5FA), // blue-400
    darkIncomeColor: Color(0xFFFB923C), // orange-400
    darkTransferColor: Color(0xFF9CA3AF), // gray-400
    darkNeutralColor: Color(0xFFE5E7EB), // gray-200
  );

  /// Get theme by name
  static AmountTheme fromName(String name) {
    switch (name) {
      case 'international':
        return international;
      case 'minimalist':
        return minimalist;
      case 'colorBlindFriendly':
        return colorBlindFriendly;
      case 'chinaMarket':
        return chinaMarket;
      default:
        return international;
    }
  }

  /// List of all available themes (for settings page)
  static const List<AmountThemeOption> availableThemes = [
    AmountThemeOption(id: 'international', theme: international),
    AmountThemeOption(id: 'chinaMarket', theme: chinaMarket),
    AmountThemeOption(id: 'minimalist', theme: minimalist),
    AmountThemeOption(id: 'colorBlindFriendly', theme: colorBlindFriendly),
  ];
}

/// Theme option (for settings page display).
///
/// Deliberately has no name/description: hardcoded English labels leaked
/// into non-English locales the moment a new palette id was added. The
/// settings page localizes via `t.amountTheme.*` keyed on [id].
class AmountThemeOption {
  final String id;
  final AmountTheme theme;

  const AmountThemeOption({required this.id, required this.theme});
}
