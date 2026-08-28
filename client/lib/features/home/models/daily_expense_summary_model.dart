import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/shared/models/expense_heat_level.dart';
import 'package:finvo/shared/utils/tolerant_json.dart';

export 'package:finvo/shared/models/expense_heat_level.dart';

part 'daily_expense_summary_model.freezed.dart';
part 'daily_expense_summary_model.g.dart';

// Helper function: Convert string to ExpenseHeatLevel enum
ExpenseHeatLevel _heatLevelFromString(String? levelStr) {
  switch (levelStr?.toLowerCase()) {
    case 'low':
      return ExpenseHeatLevel.low;
    case 'medium':
      return ExpenseHeatLevel.medium;
    case 'high':
      return ExpenseHeatLevel.high;
    case 'veryHigh':
    case 'very_high': // Backend might return veryHigh or very_high
    case 'veryhigh': // ...or the lowercased-concatenation variant
      return ExpenseHeatLevel.veryHigh;
    case 'none':
    default:
      return ExpenseHeatLevel.none;
  }
}

// Helper function: Convert ExpenseHeatLevel enum to string
String _heatLevelToString(ExpenseHeatLevel level) => level.name;

// Date toJson helper function
String _dateTimeToIso8601String(DateTime dt) {
  return dt.toIso8601String().substring(0, 10); // YYYY-MM-DD
}

// Tolerant date parse — a malformed per-day timestamp must not kill
// the whole calendar-month payload; fall back to the epoch "same-day"
// placeholder semantics of DateTime.now() as the rest of the codebase does.
DateTime _dateFromJson(Object? value) => tryDate(value) ?? DateTime.now();

@freezed
abstract class DailyExpenseSummaryModel with _$DailyExpenseSummaryModel {
  const DailyExpenseSummaryModel._();

  @JsonSerializable(
    explicitToJson: true,
  ) // Ensure toJson methods are also correctly generated
  const factory DailyExpenseSummaryModel({
    @JsonKey(
      fromJson: _dateFromJson,
      toJson: _dateTimeToIso8601String,
    ) // Handle date serialization
    required DateTime date,
    // Money stays in Decimal through the model layer (matching the
    // codebase-wide policy — the calendar heat map sums must not drift from
    // the exact Decimal sums in the transaction feed); double only at the
    // display boundary.
    @JsonKey(fromJson: decimalFromJson, toJson: decimalToJson)
    required Decimal totalExpense,
    @JsonKey(
      fromJson: _heatLevelFromString,
      toJson: _heatLevelToString,
    ) // Handle enum serialization
    required ExpenseHeatLevel heatLevel,
  }) = _DailyExpenseSummaryModel;

  factory DailyExpenseSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DailyExpenseSummaryModelFromJson(json);
}

// Calendar data model for a whole month
@freezed
abstract class CalendarMonthData with _$CalendarMonthData {
  const factory CalendarMonthData({
    required int year,
    required int month,
    // See DailyExpenseSummaryModel.totalExpense.
    @JsonKey(fromJson: decimalFromJson, toJson: decimalToJson)
    required Decimal totalExpenseForMonth,
    required List<DailyExpenseSummaryModel> dailySummaries,
    List<String>? trendColors, // optional
  }) = _CalendarMonthData;

  factory CalendarMonthData.fromJson(Map<String, dynamic> json) =>
      _$CalendarMonthDataFromJson(json);
}
