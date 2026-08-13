// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FinancialSummary {

 Decimal get totalNetWorth; Decimal get totalAssets; Decimal get totalLiabilities; String get currencyCode; bool get isLoading; bool get ratesFailed; Set<String> get missingRateCurrencies;
/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<FinancialSummary> get copyWith => _$FinancialSummaryCopyWithImpl<FinancialSummary>(this as FinancialSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummary&&(identical(other.totalNetWorth, totalNetWorth) || other.totalNetWorth == totalNetWorth)&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalLiabilities, totalLiabilities) || other.totalLiabilities == totalLiabilities)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ratesFailed, ratesFailed) || other.ratesFailed == ratesFailed)&&const DeepCollectionEquality().equals(other.missingRateCurrencies, missingRateCurrencies));
}


@override
int get hashCode => Object.hash(runtimeType,totalNetWorth,totalAssets,totalLiabilities,currencyCode,isLoading,ratesFailed,const DeepCollectionEquality().hash(missingRateCurrencies));

@override
String toString() {
  return 'FinancialSummary(totalNetWorth: $totalNetWorth, totalAssets: $totalAssets, totalLiabilities: $totalLiabilities, currencyCode: $currencyCode, isLoading: $isLoading, ratesFailed: $ratesFailed, missingRateCurrencies: $missingRateCurrencies)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryCopyWith<$Res>  {
  factory $FinancialSummaryCopyWith(FinancialSummary value, $Res Function(FinancialSummary) _then) = _$FinancialSummaryCopyWithImpl;
@useResult
$Res call({
 Decimal totalNetWorth, Decimal totalAssets, Decimal totalLiabilities, String currencyCode, bool isLoading, bool ratesFailed, Set<String> missingRateCurrencies
});




}
/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._self, this._then);

  final FinancialSummary _self;
  final $Res Function(FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalNetWorth = null,Object? totalAssets = null,Object? totalLiabilities = null,Object? currencyCode = null,Object? isLoading = null,Object? ratesFailed = null,Object? missingRateCurrencies = null,}) {
  return _then(_self.copyWith(
totalNetWorth: null == totalNetWorth ? _self.totalNetWorth : totalNetWorth // ignore: cast_nullable_to_non_nullable
as Decimal,totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as Decimal,totalLiabilities: null == totalLiabilities ? _self.totalLiabilities : totalLiabilities // ignore: cast_nullable_to_non_nullable
as Decimal,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ratesFailed: null == ratesFailed ? _self.ratesFailed : ratesFailed // ignore: cast_nullable_to_non_nullable
as bool,missingRateCurrencies: null == missingRateCurrencies ? _self.missingRateCurrencies : missingRateCurrencies // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialSummary].
extension FinancialSummaryPatterns on FinancialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Decimal totalNetWorth,  Decimal totalAssets,  Decimal totalLiabilities,  String currencyCode,  bool isLoading,  bool ratesFailed,  Set<String> missingRateCurrencies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalNetWorth,_that.totalAssets,_that.totalLiabilities,_that.currencyCode,_that.isLoading,_that.ratesFailed,_that.missingRateCurrencies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Decimal totalNetWorth,  Decimal totalAssets,  Decimal totalLiabilities,  String currencyCode,  bool isLoading,  bool ratesFailed,  Set<String> missingRateCurrencies)  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that.totalNetWorth,_that.totalAssets,_that.totalLiabilities,_that.currencyCode,_that.isLoading,_that.ratesFailed,_that.missingRateCurrencies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Decimal totalNetWorth,  Decimal totalAssets,  Decimal totalLiabilities,  String currencyCode,  bool isLoading,  bool ratesFailed,  Set<String> missingRateCurrencies)?  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.totalNetWorth,_that.totalAssets,_that.totalLiabilities,_that.currencyCode,_that.isLoading,_that.ratesFailed,_that.missingRateCurrencies);case _:
  return null;

}
}

}

/// @nodoc


class _FinancialSummary implements FinancialSummary {
  const _FinancialSummary({required this.totalNetWorth, required this.totalAssets, required this.totalLiabilities, required this.currencyCode, this.isLoading = false, this.ratesFailed = false, final  Set<String> missingRateCurrencies = const <String>{}}): _missingRateCurrencies = missingRateCurrencies;


@override final  Decimal totalNetWorth;
@override final  Decimal totalAssets;
@override final  Decimal totalLiabilities;
@override final  String currencyCode;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool ratesFailed;
 final  Set<String> _missingRateCurrencies;
@override@JsonKey() Set<String> get missingRateCurrencies {
  if (_missingRateCurrencies is EqualUnmodifiableSetView) return _missingRateCurrencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_missingRateCurrencies);
}


/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryCopyWith<_FinancialSummary> get copyWith => __$FinancialSummaryCopyWithImpl<_FinancialSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummary&&(identical(other.totalNetWorth, totalNetWorth) || other.totalNetWorth == totalNetWorth)&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalLiabilities, totalLiabilities) || other.totalLiabilities == totalLiabilities)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ratesFailed, ratesFailed) || other.ratesFailed == ratesFailed)&&const DeepCollectionEquality().equals(other._missingRateCurrencies, _missingRateCurrencies));
}


@override
int get hashCode => Object.hash(runtimeType,totalNetWorth,totalAssets,totalLiabilities,currencyCode,isLoading,ratesFailed,const DeepCollectionEquality().hash(_missingRateCurrencies));

@override
String toString() {
  return 'FinancialSummary(totalNetWorth: $totalNetWorth, totalAssets: $totalAssets, totalLiabilities: $totalLiabilities, currencyCode: $currencyCode, isLoading: $isLoading, ratesFailed: $ratesFailed, missingRateCurrencies: $missingRateCurrencies)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryCopyWith<$Res> implements $FinancialSummaryCopyWith<$Res> {
  factory _$FinancialSummaryCopyWith(_FinancialSummary value, $Res Function(_FinancialSummary) _then) = __$FinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 Decimal totalNetWorth, Decimal totalAssets, Decimal totalLiabilities, String currencyCode, bool isLoading, bool ratesFailed, Set<String> missingRateCurrencies
});




}
/// @nodoc
class __$FinancialSummaryCopyWithImpl<$Res>
    implements _$FinancialSummaryCopyWith<$Res> {
  __$FinancialSummaryCopyWithImpl(this._self, this._then);

  final _FinancialSummary _self;
  final $Res Function(_FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalNetWorth = null,Object? totalAssets = null,Object? totalLiabilities = null,Object? currencyCode = null,Object? isLoading = null,Object? ratesFailed = null,Object? missingRateCurrencies = null,}) {
  return _then(_FinancialSummary(
totalNetWorth: null == totalNetWorth ? _self.totalNetWorth : totalNetWorth // ignore: cast_nullable_to_non_nullable
as Decimal,totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as Decimal,totalLiabilities: null == totalLiabilities ? _self.totalLiabilities : totalLiabilities // ignore: cast_nullable_to_non_nullable
as Decimal,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ratesFailed: null == ratesFailed ? _self.ratesFailed : ratesFailed // ignore: cast_nullable_to_non_nullable
as bool,missingRateCurrencies: null == missingRateCurrencies ? _self._missingRateCurrencies : missingRateCurrencies // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
