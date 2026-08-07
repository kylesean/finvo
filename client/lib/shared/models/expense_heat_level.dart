// lib/shared/models/expense_heat_level.dart
//
// Moved out of `features/home/models/daily_expense_summary_model.dart` so that
// shared utils (heat colors) can depend on it without importing a feature
// module. Features re-export it for source compatibility; shared code should
// import this file directly.
enum ExpenseHeatLevel { none, low, medium, high, veryHigh }
