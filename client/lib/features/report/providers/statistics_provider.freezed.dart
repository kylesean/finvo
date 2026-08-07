// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatisticsState {

 TimeRange get timeRange; ChartType get chartType; SortType get sortType; List<String> get selectedAccountTypes; DateTime? get customStartDate; DateTime? get customEndDate; bool get isLoading; bool get isLoadingMoreTopTransactions; String? get error;/// The date range text used for display in the UI (only has a value in custom mode).
 String? get dateRangeDisplayText; StatisticsOverview? get overview; TrendDataResponse? get trendData; CategoryBreakdownResponse? get categoryBreakdown; TopTransactionsResponse? get topTransactions; CashFlowAnalysis? get cashFlow; HealthScore? get healthScore;
/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatisticsStateCopyWith<StatisticsState> get copyWith => _$StatisticsStateCopyWithImpl<StatisticsState>(this as StatisticsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatisticsState&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.chartType, chartType) || other.chartType == chartType)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&const DeepCollectionEquality().equals(other.selectedAccountTypes, selectedAccountTypes)&&(identical(other.customStartDate, customStartDate) || other.customStartDate == customStartDate)&&(identical(other.customEndDate, customEndDate) || other.customEndDate == customEndDate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMoreTopTransactions, isLoadingMoreTopTransactions) || other.isLoadingMoreTopTransactions == isLoadingMoreTopTransactions)&&(identical(other.error, error) || other.error == error)&&(identical(other.dateRangeDisplayText, dateRangeDisplayText) || other.dateRangeDisplayText == dateRangeDisplayText)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.trendData, trendData) || other.trendData == trendData)&&(identical(other.categoryBreakdown, categoryBreakdown) || other.categoryBreakdown == categoryBreakdown)&&(identical(other.topTransactions, topTransactions) || other.topTransactions == topTransactions)&&(identical(other.cashFlow, cashFlow) || other.cashFlow == cashFlow)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore));
}


@override
int get hashCode => Object.hash(runtimeType,timeRange,chartType,sortType,const DeepCollectionEquality().hash(selectedAccountTypes),customStartDate,customEndDate,isLoading,isLoadingMoreTopTransactions,error,dateRangeDisplayText,overview,trendData,categoryBreakdown,topTransactions,cashFlow,healthScore);

@override
String toString() {
  return 'StatisticsState(timeRange: $timeRange, chartType: $chartType, sortType: $sortType, selectedAccountTypes: $selectedAccountTypes, customStartDate: $customStartDate, customEndDate: $customEndDate, isLoading: $isLoading, isLoadingMoreTopTransactions: $isLoadingMoreTopTransactions, error: $error, dateRangeDisplayText: $dateRangeDisplayText, overview: $overview, trendData: $trendData, categoryBreakdown: $categoryBreakdown, topTransactions: $topTransactions, cashFlow: $cashFlow, healthScore: $healthScore)';
}


}

/// @nodoc
abstract mixin class $StatisticsStateCopyWith<$Res>  {
  factory $StatisticsStateCopyWith(StatisticsState value, $Res Function(StatisticsState) _then) = _$StatisticsStateCopyWithImpl;
@useResult
$Res call({
 TimeRange timeRange, ChartType chartType, SortType sortType, List<String> selectedAccountTypes, DateTime? customStartDate, DateTime? customEndDate, bool isLoading, bool isLoadingMoreTopTransactions, String? error, String? dateRangeDisplayText, StatisticsOverview? overview, TrendDataResponse? trendData, CategoryBreakdownResponse? categoryBreakdown, TopTransactionsResponse? topTransactions, CashFlowAnalysis? cashFlow, HealthScore? healthScore
});


$StatisticsOverviewCopyWith<$Res>? get overview;$TrendDataResponseCopyWith<$Res>? get trendData;$CategoryBreakdownResponseCopyWith<$Res>? get categoryBreakdown;$TopTransactionsResponseCopyWith<$Res>? get topTransactions;$CashFlowAnalysisCopyWith<$Res>? get cashFlow;$HealthScoreCopyWith<$Res>? get healthScore;

}
/// @nodoc
class _$StatisticsStateCopyWithImpl<$Res>
    implements $StatisticsStateCopyWith<$Res> {
  _$StatisticsStateCopyWithImpl(this._self, this._then);

  final StatisticsState _self;
  final $Res Function(StatisticsState) _then;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeRange = null,Object? chartType = null,Object? sortType = null,Object? selectedAccountTypes = null,Object? customStartDate = freezed,Object? customEndDate = freezed,Object? isLoading = null,Object? isLoadingMoreTopTransactions = null,Object? error = freezed,Object? dateRangeDisplayText = freezed,Object? overview = freezed,Object? trendData = freezed,Object? categoryBreakdown = freezed,Object? topTransactions = freezed,Object? cashFlow = freezed,Object? healthScore = freezed,}) {
  return _then(_self.copyWith(
timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as TimeRange,chartType: null == chartType ? _self.chartType : chartType // ignore: cast_nullable_to_non_nullable
as ChartType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as SortType,selectedAccountTypes: null == selectedAccountTypes ? _self.selectedAccountTypes : selectedAccountTypes // ignore: cast_nullable_to_non_nullable
as List<String>,customStartDate: freezed == customStartDate ? _self.customStartDate : customStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customEndDate: freezed == customEndDate ? _self.customEndDate : customEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreTopTransactions: null == isLoadingMoreTopTransactions ? _self.isLoadingMoreTopTransactions : isLoadingMoreTopTransactions // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,dateRangeDisplayText: freezed == dateRangeDisplayText ? _self.dateRangeDisplayText : dateRangeDisplayText // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as StatisticsOverview?,trendData: freezed == trendData ? _self.trendData : trendData // ignore: cast_nullable_to_non_nullable
as TrendDataResponse?,categoryBreakdown: freezed == categoryBreakdown ? _self.categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as CategoryBreakdownResponse?,topTransactions: freezed == topTransactions ? _self.topTransactions : topTransactions // ignore: cast_nullable_to_non_nullable
as TopTransactionsResponse?,cashFlow: freezed == cashFlow ? _self.cashFlow : cashFlow // ignore: cast_nullable_to_non_nullable
as CashFlowAnalysis?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as HealthScore?,
  ));
}
/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatisticsOverviewCopyWith<$Res>? get overview {
    if (_self.overview == null) {
    return null;
  }

  return $StatisticsOverviewCopyWith<$Res>(_self.overview!, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendDataResponseCopyWith<$Res>? get trendData {
    if (_self.trendData == null) {
    return null;
  }

  return $TrendDataResponseCopyWith<$Res>(_self.trendData!, (value) {
    return _then(_self.copyWith(trendData: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryBreakdownResponseCopyWith<$Res>? get categoryBreakdown {
    if (_self.categoryBreakdown == null) {
    return null;
  }

  return $CategoryBreakdownResponseCopyWith<$Res>(_self.categoryBreakdown!, (value) {
    return _then(_self.copyWith(categoryBreakdown: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopTransactionsResponseCopyWith<$Res>? get topTransactions {
    if (_self.topTransactions == null) {
    return null;
  }

  return $TopTransactionsResponseCopyWith<$Res>(_self.topTransactions!, (value) {
    return _then(_self.copyWith(topTransactions: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashFlowAnalysisCopyWith<$Res>? get cashFlow {
    if (_self.cashFlow == null) {
    return null;
  }

  return $CashFlowAnalysisCopyWith<$Res>(_self.cashFlow!, (value) {
    return _then(_self.copyWith(cashFlow: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthScoreCopyWith<$Res>? get healthScore {
    if (_self.healthScore == null) {
    return null;
  }

  return $HealthScoreCopyWith<$Res>(_self.healthScore!, (value) {
    return _then(_self.copyWith(healthScore: value));
  });
}
}


/// Adds pattern-matching-related methods to [StatisticsState].
extension StatisticsStatePatterns on StatisticsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatisticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatisticsState value)  $default,){
final _that = this;
switch (_that) {
case _StatisticsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatisticsState value)?  $default,){
final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimeRange timeRange,  ChartType chartType,  SortType sortType,  List<String> selectedAccountTypes,  DateTime? customStartDate,  DateTime? customEndDate,  bool isLoading,  bool isLoadingMoreTopTransactions,  String? error,  String? dateRangeDisplayText,  StatisticsOverview? overview,  TrendDataResponse? trendData,  CategoryBreakdownResponse? categoryBreakdown,  TopTransactionsResponse? topTransactions,  CashFlowAnalysis? cashFlow,  HealthScore? healthScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that.timeRange,_that.chartType,_that.sortType,_that.selectedAccountTypes,_that.customStartDate,_that.customEndDate,_that.isLoading,_that.isLoadingMoreTopTransactions,_that.error,_that.dateRangeDisplayText,_that.overview,_that.trendData,_that.categoryBreakdown,_that.topTransactions,_that.cashFlow,_that.healthScore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimeRange timeRange,  ChartType chartType,  SortType sortType,  List<String> selectedAccountTypes,  DateTime? customStartDate,  DateTime? customEndDate,  bool isLoading,  bool isLoadingMoreTopTransactions,  String? error,  String? dateRangeDisplayText,  StatisticsOverview? overview,  TrendDataResponse? trendData,  CategoryBreakdownResponse? categoryBreakdown,  TopTransactionsResponse? topTransactions,  CashFlowAnalysis? cashFlow,  HealthScore? healthScore)  $default,) {final _that = this;
switch (_that) {
case _StatisticsState():
return $default(_that.timeRange,_that.chartType,_that.sortType,_that.selectedAccountTypes,_that.customStartDate,_that.customEndDate,_that.isLoading,_that.isLoadingMoreTopTransactions,_that.error,_that.dateRangeDisplayText,_that.overview,_that.trendData,_that.categoryBreakdown,_that.topTransactions,_that.cashFlow,_that.healthScore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimeRange timeRange,  ChartType chartType,  SortType sortType,  List<String> selectedAccountTypes,  DateTime? customStartDate,  DateTime? customEndDate,  bool isLoading,  bool isLoadingMoreTopTransactions,  String? error,  String? dateRangeDisplayText,  StatisticsOverview? overview,  TrendDataResponse? trendData,  CategoryBreakdownResponse? categoryBreakdown,  TopTransactionsResponse? topTransactions,  CashFlowAnalysis? cashFlow,  HealthScore? healthScore)?  $default,) {final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that.timeRange,_that.chartType,_that.sortType,_that.selectedAccountTypes,_that.customStartDate,_that.customEndDate,_that.isLoading,_that.isLoadingMoreTopTransactions,_that.error,_that.dateRangeDisplayText,_that.overview,_that.trendData,_that.categoryBreakdown,_that.topTransactions,_that.cashFlow,_that.healthScore);case _:
  return null;

}
}

}

/// @nodoc


class _StatisticsState implements StatisticsState {
  const _StatisticsState({this.timeRange = TimeRange.month, this.chartType = ChartType.expense, this.sortType = SortType.amount, final  List<String> selectedAccountTypes = const <String>[], this.customStartDate, this.customEndDate, this.isLoading = false, this.isLoadingMoreTopTransactions = false, this.error, this.dateRangeDisplayText, this.overview, this.trendData, this.categoryBreakdown, this.topTransactions, this.cashFlow, this.healthScore}): _selectedAccountTypes = selectedAccountTypes;


@override@JsonKey() final  TimeRange timeRange;
@override@JsonKey() final  ChartType chartType;
@override@JsonKey() final  SortType sortType;
 final  List<String> _selectedAccountTypes;
@override@JsonKey() List<String> get selectedAccountTypes {
  if (_selectedAccountTypes is EqualUnmodifiableListView) return _selectedAccountTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedAccountTypes);
}

@override final  DateTime? customStartDate;
@override final  DateTime? customEndDate;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingMoreTopTransactions;
@override final  String? error;
/// The date range text used for display in the UI (only has a value in custom mode).
@override final  String? dateRangeDisplayText;
@override final  StatisticsOverview? overview;
@override final  TrendDataResponse? trendData;
@override final  CategoryBreakdownResponse? categoryBreakdown;
@override final  TopTransactionsResponse? topTransactions;
@override final  CashFlowAnalysis? cashFlow;
@override final  HealthScore? healthScore;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatisticsStateCopyWith<_StatisticsState> get copyWith => __$StatisticsStateCopyWithImpl<_StatisticsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatisticsState&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.chartType, chartType) || other.chartType == chartType)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&const DeepCollectionEquality().equals(other._selectedAccountTypes, _selectedAccountTypes)&&(identical(other.customStartDate, customStartDate) || other.customStartDate == customStartDate)&&(identical(other.customEndDate, customEndDate) || other.customEndDate == customEndDate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMoreTopTransactions, isLoadingMoreTopTransactions) || other.isLoadingMoreTopTransactions == isLoadingMoreTopTransactions)&&(identical(other.error, error) || other.error == error)&&(identical(other.dateRangeDisplayText, dateRangeDisplayText) || other.dateRangeDisplayText == dateRangeDisplayText)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.trendData, trendData) || other.trendData == trendData)&&(identical(other.categoryBreakdown, categoryBreakdown) || other.categoryBreakdown == categoryBreakdown)&&(identical(other.topTransactions, topTransactions) || other.topTransactions == topTransactions)&&(identical(other.cashFlow, cashFlow) || other.cashFlow == cashFlow)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore));
}


@override
int get hashCode => Object.hash(runtimeType,timeRange,chartType,sortType,const DeepCollectionEquality().hash(_selectedAccountTypes),customStartDate,customEndDate,isLoading,isLoadingMoreTopTransactions,error,dateRangeDisplayText,overview,trendData,categoryBreakdown,topTransactions,cashFlow,healthScore);

@override
String toString() {
  return 'StatisticsState(timeRange: $timeRange, chartType: $chartType, sortType: $sortType, selectedAccountTypes: $selectedAccountTypes, customStartDate: $customStartDate, customEndDate: $customEndDate, isLoading: $isLoading, isLoadingMoreTopTransactions: $isLoadingMoreTopTransactions, error: $error, dateRangeDisplayText: $dateRangeDisplayText, overview: $overview, trendData: $trendData, categoryBreakdown: $categoryBreakdown, topTransactions: $topTransactions, cashFlow: $cashFlow, healthScore: $healthScore)';
}


}

/// @nodoc
abstract mixin class _$StatisticsStateCopyWith<$Res> implements $StatisticsStateCopyWith<$Res> {
  factory _$StatisticsStateCopyWith(_StatisticsState value, $Res Function(_StatisticsState) _then) = __$StatisticsStateCopyWithImpl;
@override @useResult
$Res call({
 TimeRange timeRange, ChartType chartType, SortType sortType, List<String> selectedAccountTypes, DateTime? customStartDate, DateTime? customEndDate, bool isLoading, bool isLoadingMoreTopTransactions, String? error, String? dateRangeDisplayText, StatisticsOverview? overview, TrendDataResponse? trendData, CategoryBreakdownResponse? categoryBreakdown, TopTransactionsResponse? topTransactions, CashFlowAnalysis? cashFlow, HealthScore? healthScore
});


@override $StatisticsOverviewCopyWith<$Res>? get overview;@override $TrendDataResponseCopyWith<$Res>? get trendData;@override $CategoryBreakdownResponseCopyWith<$Res>? get categoryBreakdown;@override $TopTransactionsResponseCopyWith<$Res>? get topTransactions;@override $CashFlowAnalysisCopyWith<$Res>? get cashFlow;@override $HealthScoreCopyWith<$Res>? get healthScore;

}
/// @nodoc
class __$StatisticsStateCopyWithImpl<$Res>
    implements _$StatisticsStateCopyWith<$Res> {
  __$StatisticsStateCopyWithImpl(this._self, this._then);

  final _StatisticsState _self;
  final $Res Function(_StatisticsState) _then;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeRange = null,Object? chartType = null,Object? sortType = null,Object? selectedAccountTypes = null,Object? customStartDate = freezed,Object? customEndDate = freezed,Object? isLoading = null,Object? isLoadingMoreTopTransactions = null,Object? error = freezed,Object? dateRangeDisplayText = freezed,Object? overview = freezed,Object? trendData = freezed,Object? categoryBreakdown = freezed,Object? topTransactions = freezed,Object? cashFlow = freezed,Object? healthScore = freezed,}) {
  return _then(_StatisticsState(
timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as TimeRange,chartType: null == chartType ? _self.chartType : chartType // ignore: cast_nullable_to_non_nullable
as ChartType,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as SortType,selectedAccountTypes: null == selectedAccountTypes ? _self._selectedAccountTypes : selectedAccountTypes // ignore: cast_nullable_to_non_nullable
as List<String>,customStartDate: freezed == customStartDate ? _self.customStartDate : customStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customEndDate: freezed == customEndDate ? _self.customEndDate : customEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMoreTopTransactions: null == isLoadingMoreTopTransactions ? _self.isLoadingMoreTopTransactions : isLoadingMoreTopTransactions // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,dateRangeDisplayText: freezed == dateRangeDisplayText ? _self.dateRangeDisplayText : dateRangeDisplayText // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as StatisticsOverview?,trendData: freezed == trendData ? _self.trendData : trendData // ignore: cast_nullable_to_non_nullable
as TrendDataResponse?,categoryBreakdown: freezed == categoryBreakdown ? _self.categoryBreakdown : categoryBreakdown // ignore: cast_nullable_to_non_nullable
as CategoryBreakdownResponse?,topTransactions: freezed == topTransactions ? _self.topTransactions : topTransactions // ignore: cast_nullable_to_non_nullable
as TopTransactionsResponse?,cashFlow: freezed == cashFlow ? _self.cashFlow : cashFlow // ignore: cast_nullable_to_non_nullable
as CashFlowAnalysis?,healthScore: freezed == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as HealthScore?,
  ));
}

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatisticsOverviewCopyWith<$Res>? get overview {
    if (_self.overview == null) {
    return null;
  }

  return $StatisticsOverviewCopyWith<$Res>(_self.overview!, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendDataResponseCopyWith<$Res>? get trendData {
    if (_self.trendData == null) {
    return null;
  }

  return $TrendDataResponseCopyWith<$Res>(_self.trendData!, (value) {
    return _then(_self.copyWith(trendData: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryBreakdownResponseCopyWith<$Res>? get categoryBreakdown {
    if (_self.categoryBreakdown == null) {
    return null;
  }

  return $CategoryBreakdownResponseCopyWith<$Res>(_self.categoryBreakdown!, (value) {
    return _then(_self.copyWith(categoryBreakdown: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopTransactionsResponseCopyWith<$Res>? get topTransactions {
    if (_self.topTransactions == null) {
    return null;
  }

  return $TopTransactionsResponseCopyWith<$Res>(_self.topTransactions!, (value) {
    return _then(_self.copyWith(topTransactions: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashFlowAnalysisCopyWith<$Res>? get cashFlow {
    if (_self.cashFlow == null) {
    return null;
  }

  return $CashFlowAnalysisCopyWith<$Res>(_self.cashFlow!, (value) {
    return _then(_self.copyWith(cashFlow: value));
  });
}/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthScoreCopyWith<$Res>? get healthScore {
    if (_self.healthScore == null) {
    return null;
  }

  return $HealthScoreCopyWith<$Res>(_self.healthScore!, (value) {
    return _then(_self.copyWith(healthScore: value));
  });
}
}

// dart format on
