import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';

/// Tolerant JSON parsing utilities for defensive data modeling.
///
/// Prevents runtime [TypeError] or [FormatException] crashes caused by
/// backend type mismatch, missing fields, or inconsistent numbers/strings.

/// Safely convert dynamic input to [double].
/// Returns [defaultValue] if null or parsing fails.
double tryDouble(Object? v, [double defaultValue = 0.0]) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s.trim()) ?? defaultValue,
  _ => defaultValue,
};

/// Safely convert dynamic input to nullable [double].
double? tryNullableDouble(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s.trim()),
  _ => null,
};

/// Safely convert dynamic input to [int].
/// Returns [defaultValue] if null or parsing fails.
int tryInt(Object? v, [int defaultValue = 0]) => switch (v) {
  final num n => n.toInt(),
  final String s => int.tryParse(s.trim()) ?? defaultValue,
  _ => defaultValue,
};

/// Safely convert dynamic input to nullable [int].
int? tryNullableInt(Object? v) => switch (v) {
  final num n => n.toInt(),
  final String s => int.tryParse(s.trim()),
  _ => null,
};

/// Safely convert dynamic input (num/String) to [Decimal].
/// Uses [AmountFormatter.parseDecimal] for precision preservation.
Decimal tryDecimal(Object? v) => switch (v) {
  final Decimal d => d,
  final num n => AmountFormatter.parseDecimal(n.toString()),
  final String s => AmountFormatter.parseDecimal(s),
  _ => Decimal.zero,
};

/// Safely convert dynamic input to [DateTime].
/// Returns `null` if input is invalid or cannot be parsed.
DateTime? tryDate(Object? v) => switch (v) {
  final DateTime d => d,
  final String s => DateTime.tryParse(s.trim()),
  final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
  _ => null,
};

/// Safely convert dynamic input to [String].
String tryString(Object? v, [String defaultValue = '']) => switch (v) {
  null => defaultValue,
  final String s => s,
  _ => v.toString(),
};

// =========================================================================
// Reusable @JsonKey JsonSerializable converter helpers for Decimal fields
// =========================================================================

/// Parse non-null Decimal from dynamic value.
Decimal decimalFromJson(dynamic value) {
  if (value is String) return Decimal.tryParse(value) ?? Decimal.zero;
  if (value is num) return Decimal.tryParse(value.toString()) ?? Decimal.zero;
  if (value is Decimal) return value;
  return Decimal.zero;
}

/// Parse Decimal from nullable dynamic value, defaulting to Decimal.zero if null.
Decimal decimalFromJsonNullable(dynamic value) {
  if (value == null) return Decimal.zero;
  return decimalFromJson(value);
}

/// Parse Decimal from nullable dynamic value, preserving null.
Decimal? decimalOrNullFromJson(dynamic value) {
  if (value == null) return null;
  return decimalFromJson(value);
}

/// Serialize Decimal to String.
String decimalToJson(Decimal value) => value.toString();

/// Serialize nullable Decimal to String (or '0' if null).
String decimalToJsonOrZero(Decimal? value) => value?.toString() ?? '0';
