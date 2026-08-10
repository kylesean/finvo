/// GenUI shared formatting utilities
///
/// Provides consistent formatting functions for amounts, times, and other
/// display values used across all GenUI components.
library;

import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';
import 'package:finvo/shared/utils/time_utils.dart';

/// Formats a numeric amount with currency symbol
///
/// [amount] - The numeric value to format
/// [currency] - Currency code (CNY, USD, EUR, etc.)
/// [showSign] - Whether to show + for positive values
/// [compact] - Whether to use compact notation (1.2M, 3.5K)
String formatAmount(
  dynamic amount, {
  String currency = 'CNY',
  bool showSign = false,
  bool compact = false,
}) {
  if (amount == null) return '${getCurrencySymbol(currency)}0.00';

  final num value = amount is num
      ? amount
      : num.tryParse(amount.toString()) ?? 0;
  final symbol = getCurrencySymbol(currency);
  final sign = showSign && value > 0 ? '+' : '';

  if (compact && value.abs() >= 1000000) {
    return '$sign$symbol${(value / 1000000).toStringAsFixed(1)}M';
  } else if (compact && value.abs() >= 1000) {
    return '$sign$symbol${(value / 1000).toStringAsFixed(1)}K';
  }

  return '$sign$symbol${value.toStringAsFixed(2)}';
}

/// Gets currency symbol for a currency code
String getCurrencySymbol(String currency) {
  final currencyEnum = Currency.fromCode(currency);
  if (currencyEnum != null) {
    return currencyEnum.symbol;
  }

  switch (currency.toUpperCase()) {
    case 'CNY':
    case 'RMB':
      return '¥';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    case 'RUB':
      return '₽';
    case 'INR':
      return '₹';
    case 'TRY':
      return '₺';
    default:
      return currency;
  }
}

/// Formats ISO time string to HH:mm format (local time).
String formatTimeOnly(String isoTime) {
  final dateTime = tryParseDateTime(isoTime);
  if (dateTime == null) return isoTime;
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

/// Formats ISO time string to a localized relative time (e.g. "3 minutes ago").
///
/// Delegates to [relativeTime] so every locale is covered by the app's own i18n
/// strings instead of a duplicated, hardcoded-English implementation. Unparseable
/// input is returned unchanged.
String formatRelativeTime(String isoTime) {
  // Parsed defensively and converted to local time so relative labels match
  // the user's timezone.
  final dateTime = tryParseDateTime(isoTime);
  if (dateTime == null) return isoTime;
  return relativeTime(dateTime);
}

/// Formats date to YYYY-MM-DD format
String formatDate(String isoTime) {
  final dateTime = tryParseDateTime(isoTime);
  if (dateTime == null) return isoTime;
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}
