import 'package:decimal/decimal.dart';

/// Parses a budget amount field. Returns null for empty/garbage/non-positive
/// input so the page can show the invalid-amount toast.
Decimal? parseBudgetAmount(String text) {
  final amount = Decimal.tryParse(text.trim());
  if (amount == null || amount <= Decimal.zero) return null;
  return amount;
}
