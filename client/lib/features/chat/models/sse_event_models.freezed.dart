// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sse_event_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ToolCallStartEvent {

 String get id; String get name; Map<String, dynamic> get args; String? get timestamp;
/// Create a copy of ToolCallStartEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolCallStartEventCopyWith<ToolCallStartEvent> get copyWith => _$ToolCallStartEventCopyWithImpl<ToolCallStartEvent>(this as ToolCallStartEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolCallStartEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.args, args)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(args),timestamp);

@override
String toString() {
  return 'ToolCallStartEvent(id: $id, name: $name, args: $args, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ToolCallStartEventCopyWith<$Res>  {
  factory $ToolCallStartEventCopyWith(ToolCallStartEvent value, $Res Function(ToolCallStartEvent) _then) = _$ToolCallStartEventCopyWithImpl;
@useResult
$Res call({
 String id, String name, Map<String, dynamic> args, String? timestamp
});




}
/// @nodoc
class _$ToolCallStartEventCopyWithImpl<$Res>
    implements $ToolCallStartEventCopyWith<$Res> {
  _$ToolCallStartEventCopyWithImpl(this._self, this._then);

  final ToolCallStartEvent _self;
  final $Res Function(ToolCallStartEvent) _then;

/// Create a copy of ToolCallStartEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? args = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToolCallStartEvent].
extension ToolCallStartEventPatterns on ToolCallStartEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToolCallStartEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolCallStartEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToolCallStartEvent value)  $default,){
final _that = this;
switch (_that) {
case _ToolCallStartEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToolCallStartEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ToolCallStartEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> args,  String? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolCallStartEvent() when $default != null:
return $default(_that.id,_that.name,_that.args,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Map<String, dynamic> args,  String? timestamp)  $default,) {final _that = this;
switch (_that) {
case _ToolCallStartEvent():
return $default(_that.id,_that.name,_that.args,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Map<String, dynamic> args,  String? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _ToolCallStartEvent() when $default != null:
return $default(_that.id,_that.name,_that.args,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _ToolCallStartEvent implements ToolCallStartEvent {
  const _ToolCallStartEvent({this.id = '', this.name = 'unknown', final  Map<String, dynamic> args = const <String, dynamic>{}, this.timestamp}): _args = args;


@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
 final  Map<String, dynamic> _args;
@override@JsonKey() Map<String, dynamic> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}

@override final  String? timestamp;

/// Create a copy of ToolCallStartEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolCallStartEventCopyWith<_ToolCallStartEvent> get copyWith => __$ToolCallStartEventCopyWithImpl<_ToolCallStartEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolCallStartEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._args, _args)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_args),timestamp);

@override
String toString() {
  return 'ToolCallStartEvent(id: $id, name: $name, args: $args, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ToolCallStartEventCopyWith<$Res> implements $ToolCallStartEventCopyWith<$Res> {
  factory _$ToolCallStartEventCopyWith(_ToolCallStartEvent value, $Res Function(_ToolCallStartEvent) _then) = __$ToolCallStartEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Map<String, dynamic> args, String? timestamp
});




}
/// @nodoc
class __$ToolCallStartEventCopyWithImpl<$Res>
    implements _$ToolCallStartEventCopyWith<$Res> {
  __$ToolCallStartEventCopyWithImpl(this._self, this._then);

  final _ToolCallStartEvent _self;
  final $Res Function(_ToolCallStartEvent) _then;

/// Create a copy of ToolCallStartEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? args = null,Object? timestamp = freezed,}) {
  return _then(_ToolCallStartEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ToolCallEndEvent {

 String get id; String get name; String get status; int? get durationMs; String? get resultPreview; String? get error;
/// Create a copy of ToolCallEndEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolCallEndEventCopyWith<ToolCallEndEvent> get copyWith => _$ToolCallEndEventCopyWithImpl<ToolCallEndEvent>(this as ToolCallEndEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolCallEndEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.resultPreview, resultPreview) || other.resultPreview == resultPreview)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,durationMs,resultPreview,error);

@override
String toString() {
  return 'ToolCallEndEvent(id: $id, name: $name, status: $status, durationMs: $durationMs, resultPreview: $resultPreview, error: $error)';
}


}

/// @nodoc
abstract mixin class $ToolCallEndEventCopyWith<$Res>  {
  factory $ToolCallEndEventCopyWith(ToolCallEndEvent value, $Res Function(ToolCallEndEvent) _then) = _$ToolCallEndEventCopyWithImpl;
@useResult
$Res call({
 String id, String name, String status, int? durationMs, String? resultPreview, String? error
});




}
/// @nodoc
class _$ToolCallEndEventCopyWithImpl<$Res>
    implements $ToolCallEndEventCopyWith<$Res> {
  _$ToolCallEndEventCopyWithImpl(this._self, this._then);

  final ToolCallEndEvent _self;
  final $Res Function(ToolCallEndEvent) _then;

/// Create a copy of ToolCallEndEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? durationMs = freezed,Object? resultPreview = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,resultPreview: freezed == resultPreview ? _self.resultPreview : resultPreview // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToolCallEndEvent].
extension ToolCallEndEventPatterns on ToolCallEndEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToolCallEndEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolCallEndEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToolCallEndEvent value)  $default,){
final _that = this;
switch (_that) {
case _ToolCallEndEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToolCallEndEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ToolCallEndEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String status,  int? durationMs,  String? resultPreview,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolCallEndEvent() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.durationMs,_that.resultPreview,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String status,  int? durationMs,  String? resultPreview,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ToolCallEndEvent():
return $default(_that.id,_that.name,_that.status,_that.durationMs,_that.resultPreview,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String status,  int? durationMs,  String? resultPreview,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ToolCallEndEvent() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.durationMs,_that.resultPreview,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ToolCallEndEvent implements ToolCallEndEvent {
  const _ToolCallEndEvent({this.id = '', this.name = 'unknown', this.status = 'success', this.durationMs, this.resultPreview, this.error});


@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String status;
@override final  int? durationMs;
@override final  String? resultPreview;
@override final  String? error;

/// Create a copy of ToolCallEndEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolCallEndEventCopyWith<_ToolCallEndEvent> get copyWith => __$ToolCallEndEventCopyWithImpl<_ToolCallEndEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolCallEndEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.resultPreview, resultPreview) || other.resultPreview == resultPreview)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,durationMs,resultPreview,error);

@override
String toString() {
  return 'ToolCallEndEvent(id: $id, name: $name, status: $status, durationMs: $durationMs, resultPreview: $resultPreview, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ToolCallEndEventCopyWith<$Res> implements $ToolCallEndEventCopyWith<$Res> {
  factory _$ToolCallEndEventCopyWith(_ToolCallEndEvent value, $Res Function(_ToolCallEndEvent) _then) = __$ToolCallEndEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String status, int? durationMs, String? resultPreview, String? error
});




}
/// @nodoc
class __$ToolCallEndEventCopyWithImpl<$Res>
    implements _$ToolCallEndEventCopyWith<$Res> {
  __$ToolCallEndEventCopyWithImpl(this._self, this._then);

  final _ToolCallEndEvent _self;
  final $Res Function(_ToolCallEndEvent) _then;

/// Create a copy of ToolCallEndEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? durationMs = freezed,Object? resultPreview = freezed,Object? error = freezed,}) {
  return _then(_ToolCallEndEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,resultPreview: freezed == resultPreview ? _self.resultPreview : resultPreview // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ToolInfo {

 String get name; String get displayName; String get toolType; bool get cancellable; String? get warningOnCancel; String? get surfaceId;
/// Create a copy of ToolInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolInfoCopyWith<ToolInfo> get copyWith => _$ToolInfoCopyWithImpl<ToolInfo>(this as ToolInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.toolType, toolType) || other.toolType == toolType)&&(identical(other.cancellable, cancellable) || other.cancellable == cancellable)&&(identical(other.warningOnCancel, warningOnCancel) || other.warningOnCancel == warningOnCancel)&&(identical(other.surfaceId, surfaceId) || other.surfaceId == surfaceId));
}


@override
int get hashCode => Object.hash(runtimeType,name,displayName,toolType,cancellable,warningOnCancel,surfaceId);

@override
String toString() {
  return 'ToolInfo(name: $name, displayName: $displayName, toolType: $toolType, cancellable: $cancellable, warningOnCancel: $warningOnCancel, surfaceId: $surfaceId)';
}


}

/// @nodoc
abstract mixin class $ToolInfoCopyWith<$Res>  {
  factory $ToolInfoCopyWith(ToolInfo value, $Res Function(ToolInfo) _then) = _$ToolInfoCopyWithImpl;
@useResult
$Res call({
 String name, String displayName, String toolType, bool cancellable, String? warningOnCancel, String? surfaceId
});




}
/// @nodoc
class _$ToolInfoCopyWithImpl<$Res>
    implements $ToolInfoCopyWith<$Res> {
  _$ToolInfoCopyWithImpl(this._self, this._then);

  final ToolInfo _self;
  final $Res Function(ToolInfo) _then;

/// Create a copy of ToolInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? toolType = null,Object? cancellable = null,Object? warningOnCancel = freezed,Object? surfaceId = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,toolType: null == toolType ? _self.toolType : toolType // ignore: cast_nullable_to_non_nullable
as String,cancellable: null == cancellable ? _self.cancellable : cancellable // ignore: cast_nullable_to_non_nullable
as bool,warningOnCancel: freezed == warningOnCancel ? _self.warningOnCancel : warningOnCancel // ignore: cast_nullable_to_non_nullable
as String?,surfaceId: freezed == surfaceId ? _self.surfaceId : surfaceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ToolInfo].
extension ToolInfoPatterns on ToolInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToolInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToolInfo value)  $default,){
final _that = this;
switch (_that) {
case _ToolInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToolInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ToolInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String displayName,  String toolType,  bool cancellable,  String? warningOnCancel,  String? surfaceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolInfo() when $default != null:
return $default(_that.name,_that.displayName,_that.toolType,_that.cancellable,_that.warningOnCancel,_that.surfaceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String displayName,  String toolType,  bool cancellable,  String? warningOnCancel,  String? surfaceId)  $default,) {final _that = this;
switch (_that) {
case _ToolInfo():
return $default(_that.name,_that.displayName,_that.toolType,_that.cancellable,_that.warningOnCancel,_that.surfaceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String displayName,  String toolType,  bool cancellable,  String? warningOnCancel,  String? surfaceId)?  $default,) {final _that = this;
switch (_that) {
case _ToolInfo() when $default != null:
return $default(_that.name,_that.displayName,_that.toolType,_that.cancellable,_that.warningOnCancel,_that.surfaceId);case _:
  return null;

}
}

}

/// @nodoc


class _ToolInfo implements ToolInfo {
  const _ToolInfo({this.name = 'unknown', this.displayName = '', this.toolType = 'readonly', this.cancellable = true, this.warningOnCancel, this.surfaceId});


@override@JsonKey() final  String name;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String toolType;
@override@JsonKey() final  bool cancellable;
@override final  String? warningOnCancel;
@override final  String? surfaceId;

/// Create a copy of ToolInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolInfoCopyWith<_ToolInfo> get copyWith => __$ToolInfoCopyWithImpl<_ToolInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.toolType, toolType) || other.toolType == toolType)&&(identical(other.cancellable, cancellable) || other.cancellable == cancellable)&&(identical(other.warningOnCancel, warningOnCancel) || other.warningOnCancel == warningOnCancel)&&(identical(other.surfaceId, surfaceId) || other.surfaceId == surfaceId));
}


@override
int get hashCode => Object.hash(runtimeType,name,displayName,toolType,cancellable,warningOnCancel,surfaceId);

@override
String toString() {
  return 'ToolInfo(name: $name, displayName: $displayName, toolType: $toolType, cancellable: $cancellable, warningOnCancel: $warningOnCancel, surfaceId: $surfaceId)';
}


}

/// @nodoc
abstract mixin class _$ToolInfoCopyWith<$Res> implements $ToolInfoCopyWith<$Res> {
  factory _$ToolInfoCopyWith(_ToolInfo value, $Res Function(_ToolInfo) _then) = __$ToolInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String displayName, String toolType, bool cancellable, String? warningOnCancel, String? surfaceId
});




}
/// @nodoc
class __$ToolInfoCopyWithImpl<$Res>
    implements _$ToolInfoCopyWith<$Res> {
  __$ToolInfoCopyWithImpl(this._self, this._then);

  final _ToolInfo _self;
  final $Res Function(_ToolInfo) _then;

/// Create a copy of ToolInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? toolType = null,Object? cancellable = null,Object? warningOnCancel = freezed,Object? surfaceId = freezed,}) {
  return _then(_ToolInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,toolType: null == toolType ? _self.toolType : toolType // ignore: cast_nullable_to_non_nullable
as String,cancellable: null == cancellable ? _self.cancellable : cancellable // ignore: cast_nullable_to_non_nullable
as bool,warningOnCancel: freezed == warningOnCancel ? _self.warningOnCancel : warningOnCancel // ignore: cast_nullable_to_non_nullable
as String?,surfaceId: freezed == surfaceId ? _self.surfaceId : surfaceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SseEventCallbacks {

 void Function(String sessionId, String? messageId)? get onSessionInit; void Function(String text)? get onTextChunk; void Function()? get onStreamComplete; void Function(String title)? get onTitleUpdate; void Function(String error)? get onError; void Function(String localId, String serverId)? get onMessageIdUpdate; void Function(String surfaceId)? get onSurfaceCreated; void Function(ToolCallStartEvent event)? get onToolCallStart; void Function(ToolCallEndEvent event)? get onToolCallEnd; void Function(double amount, String type, String currency)? get onTransactionCreated;
/// Create a copy of SseEventCallbacks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SseEventCallbacksCopyWith<SseEventCallbacks> get copyWith => _$SseEventCallbacksCopyWithImpl<SseEventCallbacks>(this as SseEventCallbacks, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SseEventCallbacks&&(identical(other.onSessionInit, onSessionInit) || other.onSessionInit == onSessionInit)&&(identical(other.onTextChunk, onTextChunk) || other.onTextChunk == onTextChunk)&&(identical(other.onStreamComplete, onStreamComplete) || other.onStreamComplete == onStreamComplete)&&(identical(other.onTitleUpdate, onTitleUpdate) || other.onTitleUpdate == onTitleUpdate)&&(identical(other.onError, onError) || other.onError == onError)&&(identical(other.onMessageIdUpdate, onMessageIdUpdate) || other.onMessageIdUpdate == onMessageIdUpdate)&&(identical(other.onSurfaceCreated, onSurfaceCreated) || other.onSurfaceCreated == onSurfaceCreated)&&(identical(other.onToolCallStart, onToolCallStart) || other.onToolCallStart == onToolCallStart)&&(identical(other.onToolCallEnd, onToolCallEnd) || other.onToolCallEnd == onToolCallEnd)&&(identical(other.onTransactionCreated, onTransactionCreated) || other.onTransactionCreated == onTransactionCreated));
}


@override
int get hashCode => Object.hash(runtimeType,onSessionInit,onTextChunk,onStreamComplete,onTitleUpdate,onError,onMessageIdUpdate,onSurfaceCreated,onToolCallStart,onToolCallEnd,onTransactionCreated);

@override
String toString() {
  return 'SseEventCallbacks(onSessionInit: $onSessionInit, onTextChunk: $onTextChunk, onStreamComplete: $onStreamComplete, onTitleUpdate: $onTitleUpdate, onError: $onError, onMessageIdUpdate: $onMessageIdUpdate, onSurfaceCreated: $onSurfaceCreated, onToolCallStart: $onToolCallStart, onToolCallEnd: $onToolCallEnd, onTransactionCreated: $onTransactionCreated)';
}


}

/// @nodoc
abstract mixin class $SseEventCallbacksCopyWith<$Res>  {
  factory $SseEventCallbacksCopyWith(SseEventCallbacks value, $Res Function(SseEventCallbacks) _then) = _$SseEventCallbacksCopyWithImpl;
@useResult
$Res call({
 void Function(String sessionId, String? messageId)? onSessionInit, void Function(String text)? onTextChunk, void Function()? onStreamComplete, void Function(String title)? onTitleUpdate, void Function(String error)? onError, void Function(String localId, String serverId)? onMessageIdUpdate, void Function(String surfaceId)? onSurfaceCreated, void Function(ToolCallStartEvent event)? onToolCallStart, void Function(ToolCallEndEvent event)? onToolCallEnd, void Function(double amount, String type, String currency)? onTransactionCreated
});




}
/// @nodoc
class _$SseEventCallbacksCopyWithImpl<$Res>
    implements $SseEventCallbacksCopyWith<$Res> {
  _$SseEventCallbacksCopyWithImpl(this._self, this._then);

  final SseEventCallbacks _self;
  final $Res Function(SseEventCallbacks) _then;

/// Create a copy of SseEventCallbacks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onSessionInit = freezed,Object? onTextChunk = freezed,Object? onStreamComplete = freezed,Object? onTitleUpdate = freezed,Object? onError = freezed,Object? onMessageIdUpdate = freezed,Object? onSurfaceCreated = freezed,Object? onToolCallStart = freezed,Object? onToolCallEnd = freezed,Object? onTransactionCreated = freezed,}) {
  return _then(_self.copyWith(
onSessionInit: freezed == onSessionInit ? _self.onSessionInit : onSessionInit // ignore: cast_nullable_to_non_nullable
as void Function(String sessionId, String? messageId)?,onTextChunk: freezed == onTextChunk ? _self.onTextChunk : onTextChunk // ignore: cast_nullable_to_non_nullable
as void Function(String text)?,onStreamComplete: freezed == onStreamComplete ? _self.onStreamComplete : onStreamComplete // ignore: cast_nullable_to_non_nullable
as void Function()?,onTitleUpdate: freezed == onTitleUpdate ? _self.onTitleUpdate : onTitleUpdate // ignore: cast_nullable_to_non_nullable
as void Function(String title)?,onError: freezed == onError ? _self.onError : onError // ignore: cast_nullable_to_non_nullable
as void Function(String error)?,onMessageIdUpdate: freezed == onMessageIdUpdate ? _self.onMessageIdUpdate : onMessageIdUpdate // ignore: cast_nullable_to_non_nullable
as void Function(String localId, String serverId)?,onSurfaceCreated: freezed == onSurfaceCreated ? _self.onSurfaceCreated : onSurfaceCreated // ignore: cast_nullable_to_non_nullable
as void Function(String surfaceId)?,onToolCallStart: freezed == onToolCallStart ? _self.onToolCallStart : onToolCallStart // ignore: cast_nullable_to_non_nullable
as void Function(ToolCallStartEvent event)?,onToolCallEnd: freezed == onToolCallEnd ? _self.onToolCallEnd : onToolCallEnd // ignore: cast_nullable_to_non_nullable
as void Function(ToolCallEndEvent event)?,onTransactionCreated: freezed == onTransactionCreated ? _self.onTransactionCreated : onTransactionCreated // ignore: cast_nullable_to_non_nullable
as void Function(double amount, String type, String currency)?,
  ));
}

}


/// Adds pattern-matching-related methods to [SseEventCallbacks].
extension SseEventCallbacksPatterns on SseEventCallbacks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SseEventCallbacks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SseEventCallbacks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SseEventCallbacks value)  $default,){
final _that = this;
switch (_that) {
case _SseEventCallbacks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SseEventCallbacks value)?  $default,){
final _that = this;
switch (_that) {
case _SseEventCallbacks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( void Function(String sessionId, String? messageId)? onSessionInit,  void Function(String text)? onTextChunk,  void Function()? onStreamComplete,  void Function(String title)? onTitleUpdate,  void Function(String error)? onError,  void Function(String localId, String serverId)? onMessageIdUpdate,  void Function(String surfaceId)? onSurfaceCreated,  void Function(ToolCallStartEvent event)? onToolCallStart,  void Function(ToolCallEndEvent event)? onToolCallEnd,  void Function(double amount, String type, String currency)? onTransactionCreated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SseEventCallbacks() when $default != null:
return $default(_that.onSessionInit,_that.onTextChunk,_that.onStreamComplete,_that.onTitleUpdate,_that.onError,_that.onMessageIdUpdate,_that.onSurfaceCreated,_that.onToolCallStart,_that.onToolCallEnd,_that.onTransactionCreated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( void Function(String sessionId, String? messageId)? onSessionInit,  void Function(String text)? onTextChunk,  void Function()? onStreamComplete,  void Function(String title)? onTitleUpdate,  void Function(String error)? onError,  void Function(String localId, String serverId)? onMessageIdUpdate,  void Function(String surfaceId)? onSurfaceCreated,  void Function(ToolCallStartEvent event)? onToolCallStart,  void Function(ToolCallEndEvent event)? onToolCallEnd,  void Function(double amount, String type, String currency)? onTransactionCreated)  $default,) {final _that = this;
switch (_that) {
case _SseEventCallbacks():
return $default(_that.onSessionInit,_that.onTextChunk,_that.onStreamComplete,_that.onTitleUpdate,_that.onError,_that.onMessageIdUpdate,_that.onSurfaceCreated,_that.onToolCallStart,_that.onToolCallEnd,_that.onTransactionCreated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( void Function(String sessionId, String? messageId)? onSessionInit,  void Function(String text)? onTextChunk,  void Function()? onStreamComplete,  void Function(String title)? onTitleUpdate,  void Function(String error)? onError,  void Function(String localId, String serverId)? onMessageIdUpdate,  void Function(String surfaceId)? onSurfaceCreated,  void Function(ToolCallStartEvent event)? onToolCallStart,  void Function(ToolCallEndEvent event)? onToolCallEnd,  void Function(double amount, String type, String currency)? onTransactionCreated)?  $default,) {final _that = this;
switch (_that) {
case _SseEventCallbacks() when $default != null:
return $default(_that.onSessionInit,_that.onTextChunk,_that.onStreamComplete,_that.onTitleUpdate,_that.onError,_that.onMessageIdUpdate,_that.onSurfaceCreated,_that.onToolCallStart,_that.onToolCallEnd,_that.onTransactionCreated);case _:
  return null;

}
}

}

/// @nodoc


class _SseEventCallbacks implements SseEventCallbacks {
  const _SseEventCallbacks({this.onSessionInit, this.onTextChunk, this.onStreamComplete, this.onTitleUpdate, this.onError, this.onMessageIdUpdate, this.onSurfaceCreated, this.onToolCallStart, this.onToolCallEnd, this.onTransactionCreated});


@override final  void Function(String sessionId, String? messageId)? onSessionInit;
@override final  void Function(String text)? onTextChunk;
@override final  void Function()? onStreamComplete;
@override final  void Function(String title)? onTitleUpdate;
@override final  void Function(String error)? onError;
@override final  void Function(String localId, String serverId)? onMessageIdUpdate;
@override final  void Function(String surfaceId)? onSurfaceCreated;
@override final  void Function(ToolCallStartEvent event)? onToolCallStart;
@override final  void Function(ToolCallEndEvent event)? onToolCallEnd;
@override final  void Function(double amount, String type, String currency)? onTransactionCreated;

/// Create a copy of SseEventCallbacks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SseEventCallbacksCopyWith<_SseEventCallbacks> get copyWith => __$SseEventCallbacksCopyWithImpl<_SseEventCallbacks>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SseEventCallbacks&&(identical(other.onSessionInit, onSessionInit) || other.onSessionInit == onSessionInit)&&(identical(other.onTextChunk, onTextChunk) || other.onTextChunk == onTextChunk)&&(identical(other.onStreamComplete, onStreamComplete) || other.onStreamComplete == onStreamComplete)&&(identical(other.onTitleUpdate, onTitleUpdate) || other.onTitleUpdate == onTitleUpdate)&&(identical(other.onError, onError) || other.onError == onError)&&(identical(other.onMessageIdUpdate, onMessageIdUpdate) || other.onMessageIdUpdate == onMessageIdUpdate)&&(identical(other.onSurfaceCreated, onSurfaceCreated) || other.onSurfaceCreated == onSurfaceCreated)&&(identical(other.onToolCallStart, onToolCallStart) || other.onToolCallStart == onToolCallStart)&&(identical(other.onToolCallEnd, onToolCallEnd) || other.onToolCallEnd == onToolCallEnd)&&(identical(other.onTransactionCreated, onTransactionCreated) || other.onTransactionCreated == onTransactionCreated));
}


@override
int get hashCode => Object.hash(runtimeType,onSessionInit,onTextChunk,onStreamComplete,onTitleUpdate,onError,onMessageIdUpdate,onSurfaceCreated,onToolCallStart,onToolCallEnd,onTransactionCreated);

@override
String toString() {
  return 'SseEventCallbacks(onSessionInit: $onSessionInit, onTextChunk: $onTextChunk, onStreamComplete: $onStreamComplete, onTitleUpdate: $onTitleUpdate, onError: $onError, onMessageIdUpdate: $onMessageIdUpdate, onSurfaceCreated: $onSurfaceCreated, onToolCallStart: $onToolCallStart, onToolCallEnd: $onToolCallEnd, onTransactionCreated: $onTransactionCreated)';
}


}

/// @nodoc
abstract mixin class _$SseEventCallbacksCopyWith<$Res> implements $SseEventCallbacksCopyWith<$Res> {
  factory _$SseEventCallbacksCopyWith(_SseEventCallbacks value, $Res Function(_SseEventCallbacks) _then) = __$SseEventCallbacksCopyWithImpl;
@override @useResult
$Res call({
 void Function(String sessionId, String? messageId)? onSessionInit, void Function(String text)? onTextChunk, void Function()? onStreamComplete, void Function(String title)? onTitleUpdate, void Function(String error)? onError, void Function(String localId, String serverId)? onMessageIdUpdate, void Function(String surfaceId)? onSurfaceCreated, void Function(ToolCallStartEvent event)? onToolCallStart, void Function(ToolCallEndEvent event)? onToolCallEnd, void Function(double amount, String type, String currency)? onTransactionCreated
});




}
/// @nodoc
class __$SseEventCallbacksCopyWithImpl<$Res>
    implements _$SseEventCallbacksCopyWith<$Res> {
  __$SseEventCallbacksCopyWithImpl(this._self, this._then);

  final _SseEventCallbacks _self;
  final $Res Function(_SseEventCallbacks) _then;

/// Create a copy of SseEventCallbacks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onSessionInit = freezed,Object? onTextChunk = freezed,Object? onStreamComplete = freezed,Object? onTitleUpdate = freezed,Object? onError = freezed,Object? onMessageIdUpdate = freezed,Object? onSurfaceCreated = freezed,Object? onToolCallStart = freezed,Object? onToolCallEnd = freezed,Object? onTransactionCreated = freezed,}) {
  return _then(_SseEventCallbacks(
onSessionInit: freezed == onSessionInit ? _self.onSessionInit : onSessionInit // ignore: cast_nullable_to_non_nullable
as void Function(String sessionId, String? messageId)?,onTextChunk: freezed == onTextChunk ? _self.onTextChunk : onTextChunk // ignore: cast_nullable_to_non_nullable
as void Function(String text)?,onStreamComplete: freezed == onStreamComplete ? _self.onStreamComplete : onStreamComplete // ignore: cast_nullable_to_non_nullable
as void Function()?,onTitleUpdate: freezed == onTitleUpdate ? _self.onTitleUpdate : onTitleUpdate // ignore: cast_nullable_to_non_nullable
as void Function(String title)?,onError: freezed == onError ? _self.onError : onError // ignore: cast_nullable_to_non_nullable
as void Function(String error)?,onMessageIdUpdate: freezed == onMessageIdUpdate ? _self.onMessageIdUpdate : onMessageIdUpdate // ignore: cast_nullable_to_non_nullable
as void Function(String localId, String serverId)?,onSurfaceCreated: freezed == onSurfaceCreated ? _self.onSurfaceCreated : onSurfaceCreated // ignore: cast_nullable_to_non_nullable
as void Function(String surfaceId)?,onToolCallStart: freezed == onToolCallStart ? _self.onToolCallStart : onToolCallStart // ignore: cast_nullable_to_non_nullable
as void Function(ToolCallStartEvent event)?,onToolCallEnd: freezed == onToolCallEnd ? _self.onToolCallEnd : onToolCallEnd // ignore: cast_nullable_to_non_nullable
as void Function(ToolCallEndEvent event)?,onTransactionCreated: freezed == onTransactionCreated ? _self.onTransactionCreated : onTransactionCreated // ignore: cast_nullable_to_non_nullable
as void Function(double amount, String type, String currency)?,
  ));
}


}

// dart format on
