// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotalExpenseDisplay _$TotalExpenseDisplayFromJson(Map<String, dynamic> json) =>
    _TotalExpenseDisplay(
      value: json['value'] as String,
      currencySymbol: json['currencySymbol'] as String,
      fullString: json['fullString'] as String,
    );

Map<String, dynamic> _$TotalExpenseDisplayToJson(
  _TotalExpenseDisplay instance,
) => <String, dynamic>{
  'value': instance.value,
  'currencySymbol': instance.currencySymbol,
  'fullString': instance.fullString,
};

_TotalExpenseData _$TotalExpenseDataFromJson(Map<String, dynamic> json) =>
    _TotalExpenseData(
      totalExpense: json['total_expense'] as String,
      todayExpense: json['today_expense'] as String,
      monthExpense: json['month_expense'] as String,
      yearExpense: json['year_expense'] as String,
      currency: json['currency'] as String,
      display: json['display'] == null
          ? null
          : TotalExpenseDisplay.fromJson(
              json['display'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TotalExpenseDataToJson(_TotalExpenseData instance) =>
    <String, dynamic>{
      'total_expense': instance.totalExpense,
      'today_expense': instance.todayExpense,
      'month_expense': instance.monthExpense,
      'year_expense': instance.yearExpense,
      'currency': instance.currency,
      'display': instance.display,
    };
