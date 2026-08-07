// lib/shared/models/transaction_type.dart
//
// Moved out of `features/home/models/transaction_model.dart` so that shared
// widgets/utils (amount formatters, amount text) can depend on it without
// importing a feature module. Features re-export it for source compatibility;
// shared code should import this file directly.
enum TransactionType {
  expense, // Expense
  income, // Income
  transfer, // Transfer
  other,
}
