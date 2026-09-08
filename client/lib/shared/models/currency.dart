import 'package:finvo/i18n/strings.g.dart';

/// Supported currencies for the application
/// G9 countries + TWD + HKD
enum Currency {
  // G9 Countries & Most Common
  usd('USD', 'US Dollar', '\$', '🇺🇸', 2),
  cny('CNY', 'Chinese Yuan', '¥', '🇨🇳', 2),
  eur('EUR', 'Euro', '€', '🇪🇺', 2),
  gbp('GBP', 'British Pound', '£', '🇬🇧', 2),
  jpy('JPY', 'Japanese Yen', '¥', '🇯🇵', 0),
  cad('CAD', 'Canadian Dollar', 'C\$', '🇨🇦', 2),
  aud('AUD', 'Australian Dollar', 'A\$', '🇦🇺', 2),
  inr('INR', 'Indian Rupee', '₹', '🇮🇳', 2),
  rub('RUB', 'Russian Ruble', '₽', '🇷🇺', 2),

  // Additional currencies
  hkd('HKD', 'Hong Kong Dollar', 'HK\$', '🇭🇰', 2),
  twd('TWD', 'New Taiwan Dollar', 'NT\$', '🇹🇼', 2);

  final String code;
  final String name;
  final String symbol;
  final String flag;

  /// Fraction digits conventionally displayed for this currency.
  /// Zero-decimal currencies (e.g. JPY) must not render ".00".
  final int decimalDigits;

  const Currency(
    this.code,
    this.name,
    this.symbol,
    this.flag,
    this.decimalDigits,
  );

  /// Default code, as a const for default parameter values and @Default.
  static const String defaultCode = 'CNY';

  /// Get currency by code
  static Currency? fromCode(String code) {
    final upperCode = code.toUpperCase();
    final index = Currency.values.indexWhere(
      (c) => c.code.toUpperCase() == upperCode,
    );
    return index == -1 ? null : Currency.values[index];
  }

  /// Get display name with symbol
  String get displayName => '$localizedName ($symbol)';

  /// Get display name with flag
  String get displayNameWithFlag => '$flag $code - $localizedName';

  /// Get localized name using i18n
  String get localizedName {
    switch (this) {
      case Currency.usd:
        return t.currency.usd;
      case Currency.cny:
        return t.currency.cny;
      case Currency.eur:
        return t.currency.eur;
      case Currency.gbp:
        return t.currency.gbp;
      case Currency.jpy:
        return t.currency.jpy;
      case Currency.cad:
        return t.currency.cad;
      case Currency.aud:
        return t.currency.aud;
      case Currency.inr:
        return t.currency.inr;
      case Currency.rub:
        return t.currency.rub;
      case Currency.hkd:
        return t.currency.hkd;
      case Currency.twd:
        return t.currency.twd;
    }
  }
}
