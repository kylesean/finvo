// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'version_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VersionCheckState {

 bool get isChecking; UpdateInfo? get updateInfo; String? get error;
/// Create a copy of VersionCheckState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionCheckStateCopyWith<VersionCheckState> get copyWith => _$VersionCheckStateCopyWithImpl<VersionCheckState>(this as VersionCheckState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionCheckState&&(identical(other.isChecking, isChecking) || other.isChecking == isChecking)&&(identical(other.updateInfo, updateInfo) || other.updateInfo == updateInfo)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isChecking,updateInfo,error);

@override
String toString() {
  return 'VersionCheckState(isChecking: $isChecking, updateInfo: $updateInfo, error: $error)';
}


}

/// @nodoc
abstract mixin class $VersionCheckStateCopyWith<$Res>  {
  factory $VersionCheckStateCopyWith(VersionCheckState value, $Res Function(VersionCheckState) _then) = _$VersionCheckStateCopyWithImpl;
@useResult
$Res call({
 bool isChecking, UpdateInfo? updateInfo, String? error
});




}
/// @nodoc
class _$VersionCheckStateCopyWithImpl<$Res>
    implements $VersionCheckStateCopyWith<$Res> {
  _$VersionCheckStateCopyWithImpl(this._self, this._then);

  final VersionCheckState _self;
  final $Res Function(VersionCheckState) _then;

/// Create a copy of VersionCheckState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isChecking = null,Object? updateInfo = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
isChecking: null == isChecking ? _self.isChecking : isChecking // ignore: cast_nullable_to_non_nullable
as bool,updateInfo: freezed == updateInfo ? _self.updateInfo : updateInfo // ignore: cast_nullable_to_non_nullable
as UpdateInfo?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VersionCheckState].
extension VersionCheckStatePatterns on VersionCheckState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionCheckState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionCheckState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionCheckState value)  $default,){
final _that = this;
switch (_that) {
case _VersionCheckState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionCheckState value)?  $default,){
final _that = this;
switch (_that) {
case _VersionCheckState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isChecking,  UpdateInfo? updateInfo,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionCheckState() when $default != null:
return $default(_that.isChecking,_that.updateInfo,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isChecking,  UpdateInfo? updateInfo,  String? error)  $default,) {final _that = this;
switch (_that) {
case _VersionCheckState():
return $default(_that.isChecking,_that.updateInfo,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isChecking,  UpdateInfo? updateInfo,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _VersionCheckState() when $default != null:
return $default(_that.isChecking,_that.updateInfo,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _VersionCheckState implements VersionCheckState {
  const _VersionCheckState({this.isChecking = false, this.updateInfo, this.error});


@override@JsonKey() final  bool isChecking;
@override final  UpdateInfo? updateInfo;
@override final  String? error;

/// Create a copy of VersionCheckState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionCheckStateCopyWith<_VersionCheckState> get copyWith => __$VersionCheckStateCopyWithImpl<_VersionCheckState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionCheckState&&(identical(other.isChecking, isChecking) || other.isChecking == isChecking)&&(identical(other.updateInfo, updateInfo) || other.updateInfo == updateInfo)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isChecking,updateInfo,error);

@override
String toString() {
  return 'VersionCheckState(isChecking: $isChecking, updateInfo: $updateInfo, error: $error)';
}


}

/// @nodoc
abstract mixin class _$VersionCheckStateCopyWith<$Res> implements $VersionCheckStateCopyWith<$Res> {
  factory _$VersionCheckStateCopyWith(_VersionCheckState value, $Res Function(_VersionCheckState) _then) = __$VersionCheckStateCopyWithImpl;
@override @useResult
$Res call({
 bool isChecking, UpdateInfo? updateInfo, String? error
});




}
/// @nodoc
class __$VersionCheckStateCopyWithImpl<$Res>
    implements _$VersionCheckStateCopyWith<$Res> {
  __$VersionCheckStateCopyWithImpl(this._self, this._then);

  final _VersionCheckState _self;
  final $Res Function(_VersionCheckState) _then;

/// Create a copy of VersionCheckState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isChecking = null,Object? updateInfo = freezed,Object? error = freezed,}) {
  return _then(_VersionCheckState(
isChecking: null == isChecking ? _self.isChecking : isChecking // ignore: cast_nullable_to_non_nullable
as bool,updateInfo: freezed == updateInfo ? _self.updateInfo : updateInfo // ignore: cast_nullable_to_non_nullable
as UpdateInfo?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
