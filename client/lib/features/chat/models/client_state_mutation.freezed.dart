// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_state_mutation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClientStateMutation {

/// UI mode: Controls graph entry routing
/// - 'idle': Goes through agent node
/// - 'direct_execute': Skips LLM, executes tool_name directly
 String? get uiMode;/// Tool name to execute directly (must be registered in INTERNAL_TOOLS)
 String? get toolName;/// Tool parameters
 Map<String, dynamic>? get toolParams;
/// Create a copy of ClientStateMutation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientStateMutationCopyWith<ClientStateMutation> get copyWith => _$ClientStateMutationCopyWithImpl<ClientStateMutation>(this as ClientStateMutation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientStateMutation&&(identical(other.uiMode, uiMode) || other.uiMode == uiMode)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other.toolParams, toolParams));
}


@override
int get hashCode => Object.hash(runtimeType,uiMode,toolName,const DeepCollectionEquality().hash(toolParams));

@override
String toString() {
  return 'ClientStateMutation(uiMode: $uiMode, toolName: $toolName, toolParams: $toolParams)';
}


}

/// @nodoc
abstract mixin class $ClientStateMutationCopyWith<$Res>  {
  factory $ClientStateMutationCopyWith(ClientStateMutation value, $Res Function(ClientStateMutation) _then) = _$ClientStateMutationCopyWithImpl;
@useResult
$Res call({
 String? uiMode, String? toolName, Map<String, dynamic>? toolParams
});




}
/// @nodoc
class _$ClientStateMutationCopyWithImpl<$Res>
    implements $ClientStateMutationCopyWith<$Res> {
  _$ClientStateMutationCopyWithImpl(this._self, this._then);

  final ClientStateMutation _self;
  final $Res Function(ClientStateMutation) _then;

/// Create a copy of ClientStateMutation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiMode = freezed,Object? toolName = freezed,Object? toolParams = freezed,}) {
  return _then(_self.copyWith(
uiMode: freezed == uiMode ? _self.uiMode : uiMode // ignore: cast_nullable_to_non_nullable
as String?,toolName: freezed == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String?,toolParams: freezed == toolParams ? _self.toolParams : toolParams // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientStateMutation].
extension ClientStateMutationPatterns on ClientStateMutation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientStateMutation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientStateMutation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientStateMutation value)  $default,){
final _that = this;
switch (_that) {
case _ClientStateMutation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientStateMutation value)?  $default,){
final _that = this;
switch (_that) {
case _ClientStateMutation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? uiMode,  String? toolName,  Map<String, dynamic>? toolParams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientStateMutation() when $default != null:
return $default(_that.uiMode,_that.toolName,_that.toolParams);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? uiMode,  String? toolName,  Map<String, dynamic>? toolParams)  $default,) {final _that = this;
switch (_that) {
case _ClientStateMutation():
return $default(_that.uiMode,_that.toolName,_that.toolParams);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? uiMode,  String? toolName,  Map<String, dynamic>? toolParams)?  $default,) {final _that = this;
switch (_that) {
case _ClientStateMutation() when $default != null:
return $default(_that.uiMode,_that.toolName,_that.toolParams);case _:
  return null;

}
}

}

/// @nodoc


class _ClientStateMutation implements ClientStateMutation {
  const _ClientStateMutation({this.uiMode, this.toolName, final  Map<String, dynamic>? toolParams}): _toolParams = toolParams;


/// UI mode: Controls graph entry routing
/// - 'idle': Goes through agent node
/// - 'direct_execute': Skips LLM, executes tool_name directly
@override final  String? uiMode;
/// Tool name to execute directly (must be registered in INTERNAL_TOOLS)
@override final  String? toolName;
/// Tool parameters
 final  Map<String, dynamic>? _toolParams;
/// Tool parameters
@override Map<String, dynamic>? get toolParams {
  final value = _toolParams;
  if (value == null) return null;
  if (_toolParams is EqualUnmodifiableMapView) return _toolParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ClientStateMutation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientStateMutationCopyWith<_ClientStateMutation> get copyWith => __$ClientStateMutationCopyWithImpl<_ClientStateMutation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientStateMutation&&(identical(other.uiMode, uiMode) || other.uiMode == uiMode)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolParams, _toolParams));
}


@override
int get hashCode => Object.hash(runtimeType,uiMode,toolName,const DeepCollectionEquality().hash(_toolParams));

@override
String toString() {
  return 'ClientStateMutation(uiMode: $uiMode, toolName: $toolName, toolParams: $toolParams)';
}


}

/// @nodoc
abstract mixin class _$ClientStateMutationCopyWith<$Res> implements $ClientStateMutationCopyWith<$Res> {
  factory _$ClientStateMutationCopyWith(_ClientStateMutation value, $Res Function(_ClientStateMutation) _then) = __$ClientStateMutationCopyWithImpl;
@override @useResult
$Res call({
 String? uiMode, String? toolName, Map<String, dynamic>? toolParams
});




}
/// @nodoc
class __$ClientStateMutationCopyWithImpl<$Res>
    implements _$ClientStateMutationCopyWith<$Res> {
  __$ClientStateMutationCopyWithImpl(this._self, this._then);

  final _ClientStateMutation _self;
  final $Res Function(_ClientStateMutation) _then;

/// Create a copy of ClientStateMutation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiMode = freezed,Object? toolName = freezed,Object? toolParams = freezed,}) {
  return _then(_ClientStateMutation(
uiMode: freezed == uiMode ? _self.uiMode : uiMode // ignore: cast_nullable_to_non_nullable
as String?,toolName: freezed == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String?,toolParams: freezed == toolParams ? _self._toolParams : toolParams // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
