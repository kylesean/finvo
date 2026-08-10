// lib/shared/utils/amount_formatter.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/shared/models/transaction_type.dart';
import 'package:finvo/shared/theme/amount_theme.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Unified amount formatting service
///
/// Design principles:
/// - Sign required: Always display +/- symbols (core accessibility principle)
/// - Tabular figures: Use tabular figures for alignment
/// - Decimal alignment: Fixed 2 decimal places
///
/// Usage:
/// ```dart
/// // Format transaction amount
/// final text = AmountFormatter.formatTransaction(
///   type: TransactionType.expense,
///   amount: 123.45,
/// );
/// // Result: "-¥123.45"
///
/// // Get amount color
/// final color = AmountFormatter.getAmountColor(
///   TransactionType.income,
///   AmountTheme.chinaMarket,
/// );
/// ```
class AmountFormatter {
  // NumberFormat instance cache (bounded to avoid unbounded memory growth).
  static final Map<String, NumberFormat> _formatCache = {};

  /// Maximum number of cached [NumberFormat] instances.
  static const int _maxCacheSize = 64;

  /// Parse a backend amount string into a [Decimal], falling back to zero.
  ///
  /// Centralizes the string→Decimal conversion so callers don't each
  /// reimplement `double.tryParse(x) ?? 0`. Parsing through [Decimal] (instead
  /// of [double]) preserves precision for aggregation: summing many
  /// `double.tryParse` results accumulates floating-point error, while
  /// `Decimal` is exact. Convert to [double] only at the display boundary
  /// (e.g. [AmountText]) via [Decimal.toDouble].
  static Decimal parseDecimal(String? amount) =>
      Decimal.tryParse(amount ?? '') ?? Decimal.zero;

  /// Get currency formatter.
  ///
  /// Uses the current Intl locale (kept in sync with the app locale by
  /// [LocaleService]) instead of a hardcoded locale, so grouping/decimal
  /// separators follow the selected language.
  static NumberFormat getNumberFormat(
    String currency, {
    String? locale,
    int decimalDigits = 2,
  }) {
    final effectiveLocale = locale ?? Intl.getCurrentLocale();
    final cacheKey = '$effectiveLocale:$currency:$decimalDigits';
    return _formatCache.putIfAbsent(cacheKey, () {
      // Evict the oldest entry when the cache exceeds its bound.
      if (_formatCache.length >= _maxCacheSize) {
        final oldestKey = _formatCache.keys.first;
        _formatCache.remove(oldestKey);
      }
      return NumberFormat.currency(
        locale: effectiveLocale,
        symbol: '',
        decimalDigits: decimalDigits,
      );
    });
  }

  /// Format transaction amount
  ///
  /// [type] - Transaction type (expense/income/transfer)
  /// [amount] - Amount (always use absolute value)
  /// [currency] - Currency code, default CNY
  /// [showSign] - Whether to show positive/negative sign, default true
  /// [compact] - Whether to use compact format, default false
  ///
  /// Returns formatted string, e.g., "-¥123.45" or "+¥100.00"
  static String formatTransaction({
    required TransactionType type,
    required double amount,
    String currency = 'CNY',
    bool showSign = true,
    bool compact = false,
  }) {
    final symbol = getCurrencySymbol(currency);
    final absAmount = amount.abs();

    String formattedValue;
    if (compact) {
      formattedValue = formatCompact(absAmount);
    } else {
      formattedValue = getNumberFormat(currency).format(absAmount);
    }

    if (!showSign) {
      return '$symbol$formattedValue';
    }

    switch (type) {
      case TransactionType.expense:
        return '-$symbol$formattedValue';
      case TransactionType.income:
        return '+$symbol$formattedValue';
      case TransactionType.transfer:
        return '$symbol$formattedValue'; // Transfer without sign
      case TransactionType.other:
        return '$symbol$formattedValue';
    }
  }

  /// Format common amount (no sign)
  ///
  /// [amount] - Amount
  /// [currencyCode] - Currency code
  static String formatCommon(double amount, {String currencyCode = 'CNY'}) {
    final symbol = getCurrencySymbol(currencyCode);
    final absAmount = amount.abs();
    final formattedValue = getNumberFormat(currencyCode).format(absAmount);
    return '$symbol$formattedValue';
  }

  /// Format a backend amount [String] with its currency symbol.
  ///
  /// Convenience for call sites that receive raw string amounts (e.g.
  /// `totalExpense`, `contributionAmount`) and previously hand-prefixed a
  /// hardcoded `'¥'`. Uses [getCurrencySymbol] + [getNumberFormat] so the
  /// symbol follows [currencyCode] instead of a constant.
  ///
  /// [amount] - Backend amount string (parsed defensively, falls back to 0)
  /// [currencyCode] - Currency code, default 'CNY'
  ///
  /// Returns e.g. `"¥1,234.56"`.
  static String formatWithCurrency(
    String amount, {
    String currencyCode = 'CNY',
  }) {
    final symbol = getCurrencySymbol(currencyCode);
    final value = double.tryParse(amount) ?? 0.0;
    return '$symbol${getNumberFormat(currencyCode).format(value)}';
  }

  /// Format as compact format based on system Locale
  ///
  /// For Chinese (zh): 10k, 100M
  /// For other languages: K(1k), M(1M), B(1B)
  ///
  /// [locale] - Optional locale override, defaults to system locale
  static String formatCompact(double amount, {String? locale}) {
    // Determine if using Chinese format
    final effectiveLocale = locale ?? Intl.getCurrentLocale();
    final isChineseLocale = effectiveLocale.startsWith('zh');
    // Traditional Chinese locales (zh_Hant/zh_TW/zh_HK) use the traditional
    // glyphs 「萬/億」 instead of the simplified 「万/亿」.
    final isTraditionalChinese =
        effectiveLocale.contains('Hant') ||
        effectiveLocale.contains('TW') ||
        effectiveLocale.contains('HK') ||
        effectiveLocale.contains('tw') ||
        effectiveLocale.contains('hk');

    if (isChineseLocale) {
      final wan = isTraditionalChinese ? '萬' : '万';
      final yi = isTraditionalChinese ? '億' : '亿';
      // Chinese units: 10k, 100M
      if (amount >= 100000000) {
        return '${(amount / 100000000).toStringAsFixed(1)}$yi';
      } else if (amount >= 10000) {
        return '${(amount / 10000).toStringAsFixed(1)}$wan';
      } else {
        return amount.toStringAsFixed(2);
      }
    } else {
      // International: K(1k), M(1M), B(1B)
      if (amount >= 1000000000) {
        return '${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)}K';
      } else {
        return amount.toStringAsFixed(2);
      }
    }
  }

  /// Format a budget [Decimal] amount using localized units (萬/万) and thousands separators.
  static String formatBudgetCompact(Decimal amount) {
    final sign = amount < Decimal.zero ? '-' : '';
    final absValue = amount.abs();

    if (absValue >= Decimal.fromInt(10000)) {
      final wanValue = (absValue / Decimal.fromInt(10000)).toDecimal();
      return '$sign${wanValue.toStringAsFixed(1)}${t.budget.tenThousandSuffix}';
    }

    final parts = absValue.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    var formatted = '';
    var count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ',$formatted';
      }
      formatted = intPart[i] + formatted;
      count++;
    }

    if (decPart == '00') {
      return '$sign$formatted';
    }
    return '$sign$formatted.$decPart';
  }

  /// Get amount color
  ///
  /// Returns corresponding color based on transaction type and theme
  static Color getAmountColor(TransactionType type, AmountTheme theme) {
    switch (type) {
      case TransactionType.expense:
        return theme.expenseColor;
      case TransactionType.income:
        return theme.incomeColor;
      case TransactionType.transfer:
        return theme.transferColor;
      case TransactionType.other:
        return theme.neutralColor;
    }
  }

  /// Get amount color from string type
  ///
  /// Convenient for handling string types returned from backend
  static Color getAmountColorFromString(String typeStr, AmountTheme theme) {
    final type = _parseTransactionType(typeStr);
    return getAmountColor(type, theme);
  }

  /// Parse transaction type string
  static TransactionType _parseTransactionType(String typeStr) {
    switch (typeStr.toUpperCase()) {
      case 'EXPENSE':
        return TransactionType.expense;
      case 'INCOME':
        return TransactionType.income;
      case 'TRANSFER':
        return TransactionType.transfer;
      default:
        return TransactionType.other;
    }
  }

  /// Get currency symbol
  ///
  /// Uses the unified Currency enum for G9 countries + TWD + HKD
  /// Falls back to currency code for unknown currencies
  static String getCurrencySymbol(String currency) {
    // Import Currency enum
    final currencyEnum = Currency.fromCode(currency);
    if (currencyEnum != null) {
      return currencyEnum.symbol;
    }

    // Fallback for other currencies
    switch (currency.toUpperCase()) {
      case 'RMB':
        return '¥';
      case 'MXN':
        return '\$';
      case 'KRW':
        return '₩';
      case 'RUB':
        return '₽';
      case 'INR':
        return '₹';
      case 'TRY':
        return '₺';
      case 'HKD':
        return 'HK\$';
      case 'TWD':
        return 'NT\$';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return currency;
    }
  }

  /// Get amount sign
  ///
  /// Returns "+", "-" or ""
  static String getAmountSign(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return '-';
      case TransactionType.income:
        return '+';
      case TransactionType.transfer:
      case TransactionType.other:
        return '';
    }
  }

  /// Determine if amount is negative (expense)
  static bool isNegativeAmount(TransactionType type) {
    return type == TransactionType.expense;
  }

  /// Determine if amount is positive (income)
  static bool isPositiveAmount(TransactionType type) {
    return type == TransactionType.income;
  }
}
