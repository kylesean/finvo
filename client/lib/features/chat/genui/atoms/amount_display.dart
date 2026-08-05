import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/genui/utils/formatters.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A formatted currency amount display
///
/// This is a Layer 1 (Atom) component that provides consistent
/// amount formatting with currency symbols.
///
/// Example:
/// ```dart
/// AmountDisplay(
///   amount: 1234.56,
///   currency: 'CNY',
///   style: theme.typography.body.lg,
/// )
/// ```
class AmountDisplay extends StatelessWidget {
  /// The numeric amount to display
  final num amount;

  /// Currency code (CNY, USD, EUR, etc.). Defaults to 'CNY'.
  final String currency;

  /// Custom text style. Uses theme typography if not provided.
  final TextStyle? style;

  /// Whether to show + sign for positive values. Defaults to false.
  final bool showSign;

  /// Whether to use compact notation (1.2M, 3.5K). Defaults to false.
  final bool compact;

  /// Text color override. Uses style color or theme foreground if null.
  final Color? color;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'CNY',
    this.style,
    this.showSign = false,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final formattedAmount = formatAmount(
      amount,
      currency: currency,
      showSign: showSign,
      compact: compact,
    );

    final effectiveStyle = (style ?? theme.typography.body.md).copyWith(
      color: color,
    );

    return Text(formattedAmount, style: effectiveStyle);
  }
}

/// A large, prominent amount display for receipts/cards
///
/// Extends [AmountDisplay] with larger default styling.
class LargeAmountDisplay extends StatelessWidget {
  final num amount;
  final String currency;
  final Color? color;
  final bool showSign;

  const LargeAmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'CNY',
    this.color,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AmountDisplay(
      amount: amount,
      currency: currency,
      showSign: showSign,
      style: AppTextStyles.statValue(theme),
    );
  }
}
