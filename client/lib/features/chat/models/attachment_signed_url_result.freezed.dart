// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_signed_url_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttachmentSignedUrlResult implements DiagnosticableTreeMixin {

 List<AttachmentSignedUrlInfo> get successful; List<AttachmentSignedUrlFailure> get failed;
/// Create a copy of AttachmentSignedUrlResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentSignedUrlResultCopyWith<AttachmentSignedUrlResult> get copyWith => _$AttachmentSignedUrlResultCopyWithImpl<AttachmentSignedUrlResult>(this as AttachmentSignedUrlResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlResult'))
    ..add(DiagnosticsProperty('successful', successful))..add(DiagnosticsProperty('failed', failed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentSignedUrlResult&&const DeepCollectionEquality().equals(other.successful, successful)&&const DeepCollectionEquality().equals(other.failed, failed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(successful),const DeepCollectionEquality().hash(failed));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlResult(successful: $successful, failed: $failed)';
}


}

/// @nodoc
abstract mixin class $AttachmentSignedUrlResultCopyWith<$Res>  {
  factory $AttachmentSignedUrlResultCopyWith(AttachmentSignedUrlResult value, $Res Function(AttachmentSignedUrlResult) _then) = _$AttachmentSignedUrlResultCopyWithImpl;
@useResult
$Res call({
 List<AttachmentSignedUrlInfo> successful, List<AttachmentSignedUrlFailure> failed
});




}
/// @nodoc
class _$AttachmentSignedUrlResultCopyWithImpl<$Res>
    implements $AttachmentSignedUrlResultCopyWith<$Res> {
  _$AttachmentSignedUrlResultCopyWithImpl(this._self, this._then);

  final AttachmentSignedUrlResult _self;
  final $Res Function(AttachmentSignedUrlResult) _then;

/// Create a copy of AttachmentSignedUrlResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? successful = null,Object? failed = null,}) {
  return _then(_self.copyWith(
successful: null == successful ? _self.successful : successful // ignore: cast_nullable_to_non_nullable
as List<AttachmentSignedUrlInfo>,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as List<AttachmentSignedUrlFailure>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentSignedUrlResult].
extension AttachmentSignedUrlResultPatterns on AttachmentSignedUrlResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentSignedUrlResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentSignedUrlResult value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentSignedUrlResult value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttachmentSignedUrlInfo> successful,  List<AttachmentSignedUrlFailure> failed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult() when $default != null:
return $default(_that.successful,_that.failed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttachmentSignedUrlInfo> successful,  List<AttachmentSignedUrlFailure> failed)  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult():
return $default(_that.successful,_that.failed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttachmentSignedUrlInfo> successful,  List<AttachmentSignedUrlFailure> failed)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlResult() when $default != null:
return $default(_that.successful,_that.failed);case _:
  return null;

}
}

}

/// @nodoc


class _AttachmentSignedUrlResult with DiagnosticableTreeMixin implements AttachmentSignedUrlResult {
  const _AttachmentSignedUrlResult({final  List<AttachmentSignedUrlInfo> successful = const <AttachmentSignedUrlInfo>[], final  List<AttachmentSignedUrlFailure> failed = const <AttachmentSignedUrlFailure>[]}): _successful = successful,_failed = failed;


 final  List<AttachmentSignedUrlInfo> _successful;
@override@JsonKey() List<AttachmentSignedUrlInfo> get successful {
  if (_successful is EqualUnmodifiableListView) return _successful;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_successful);
}

 final  List<AttachmentSignedUrlFailure> _failed;
@override@JsonKey() List<AttachmentSignedUrlFailure> get failed {
  if (_failed is EqualUnmodifiableListView) return _failed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failed);
}


/// Create a copy of AttachmentSignedUrlResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentSignedUrlResultCopyWith<_AttachmentSignedUrlResult> get copyWith => __$AttachmentSignedUrlResultCopyWithImpl<_AttachmentSignedUrlResult>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlResult'))
    ..add(DiagnosticsProperty('successful', successful))..add(DiagnosticsProperty('failed', failed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentSignedUrlResult&&const DeepCollectionEquality().equals(other._successful, _successful)&&const DeepCollectionEquality().equals(other._failed, _failed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_successful),const DeepCollectionEquality().hash(_failed));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlResult(successful: $successful, failed: $failed)';
}


}

/// @nodoc
abstract mixin class _$AttachmentSignedUrlResultCopyWith<$Res> implements $AttachmentSignedUrlResultCopyWith<$Res> {
  factory _$AttachmentSignedUrlResultCopyWith(_AttachmentSignedUrlResult value, $Res Function(_AttachmentSignedUrlResult) _then) = __$AttachmentSignedUrlResultCopyWithImpl;
@override @useResult
$Res call({
 List<AttachmentSignedUrlInfo> successful, List<AttachmentSignedUrlFailure> failed
});




}
/// @nodoc
class __$AttachmentSignedUrlResultCopyWithImpl<$Res>
    implements _$AttachmentSignedUrlResultCopyWith<$Res> {
  __$AttachmentSignedUrlResultCopyWithImpl(this._self, this._then);

  final _AttachmentSignedUrlResult _self;
  final $Res Function(_AttachmentSignedUrlResult) _then;

/// Create a copy of AttachmentSignedUrlResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? successful = null,Object? failed = null,}) {
  return _then(_AttachmentSignedUrlResult(
successful: null == successful ? _self._successful : successful // ignore: cast_nullable_to_non_nullable
as List<AttachmentSignedUrlInfo>,failed: null == failed ? _self._failed : failed // ignore: cast_nullable_to_non_nullable
as List<AttachmentSignedUrlFailure>,
  ));
}


}

/// @nodoc
mixin _$AttachmentSignedUrlInfo implements DiagnosticableTreeMixin {

 String get id; String get filename; String get signedUrl; DateTime? get expiresAt;
/// Create a copy of AttachmentSignedUrlInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentSignedUrlInfoCopyWith<AttachmentSignedUrlInfo> get copyWith => _$AttachmentSignedUrlInfoCopyWithImpl<AttachmentSignedUrlInfo>(this as AttachmentSignedUrlInfo, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlInfo'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('signedUrl', signedUrl))..add(DiagnosticsProperty('expiresAt', expiresAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentSignedUrlInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,signedUrl,expiresAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlInfo(id: $id, filename: $filename, signedUrl: $signedUrl, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $AttachmentSignedUrlInfoCopyWith<$Res>  {
  factory $AttachmentSignedUrlInfoCopyWith(AttachmentSignedUrlInfo value, $Res Function(AttachmentSignedUrlInfo) _then) = _$AttachmentSignedUrlInfoCopyWithImpl;
@useResult
$Res call({
 String id, String filename, String signedUrl, DateTime? expiresAt
});




}
/// @nodoc
class _$AttachmentSignedUrlInfoCopyWithImpl<$Res>
    implements $AttachmentSignedUrlInfoCopyWith<$Res> {
  _$AttachmentSignedUrlInfoCopyWithImpl(this._self, this._then);

  final AttachmentSignedUrlInfo _self;
  final $Res Function(AttachmentSignedUrlInfo) _then;

/// Create a copy of AttachmentSignedUrlInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filename = null,Object? signedUrl = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,signedUrl: null == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentSignedUrlInfo].
extension AttachmentSignedUrlInfoPatterns on AttachmentSignedUrlInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentSignedUrlInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentSignedUrlInfo value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentSignedUrlInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String filename,  String signedUrl,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo() when $default != null:
return $default(_that.id,_that.filename,_that.signedUrl,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String filename,  String signedUrl,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo():
return $default(_that.id,_that.filename,_that.signedUrl,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String filename,  String signedUrl,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlInfo() when $default != null:
return $default(_that.id,_that.filename,_that.signedUrl,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _AttachmentSignedUrlInfo with DiagnosticableTreeMixin implements AttachmentSignedUrlInfo {
  const _AttachmentSignedUrlInfo({required this.id, required this.filename, required this.signedUrl, this.expiresAt});


@override final  String id;
@override final  String filename;
@override final  String signedUrl;
@override final  DateTime? expiresAt;

/// Create a copy of AttachmentSignedUrlInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentSignedUrlInfoCopyWith<_AttachmentSignedUrlInfo> get copyWith => __$AttachmentSignedUrlInfoCopyWithImpl<_AttachmentSignedUrlInfo>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlInfo'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('signedUrl', signedUrl))..add(DiagnosticsProperty('expiresAt', expiresAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentSignedUrlInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,signedUrl,expiresAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlInfo(id: $id, filename: $filename, signedUrl: $signedUrl, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$AttachmentSignedUrlInfoCopyWith<$Res> implements $AttachmentSignedUrlInfoCopyWith<$Res> {
  factory _$AttachmentSignedUrlInfoCopyWith(_AttachmentSignedUrlInfo value, $Res Function(_AttachmentSignedUrlInfo) _then) = __$AttachmentSignedUrlInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String filename, String signedUrl, DateTime? expiresAt
});




}
/// @nodoc
class __$AttachmentSignedUrlInfoCopyWithImpl<$Res>
    implements _$AttachmentSignedUrlInfoCopyWith<$Res> {
  __$AttachmentSignedUrlInfoCopyWithImpl(this._self, this._then);

  final _AttachmentSignedUrlInfo _self;
  final $Res Function(_AttachmentSignedUrlInfo) _then;

/// Create a copy of AttachmentSignedUrlInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filename = null,Object? signedUrl = null,Object? expiresAt = freezed,}) {
  return _then(_AttachmentSignedUrlInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,signedUrl: null == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$AttachmentSignedUrlFailure implements DiagnosticableTreeMixin {

 String? get id; String? get filename; String? get error; int? get errorCode; String? get message;
/// Create a copy of AttachmentSignedUrlFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentSignedUrlFailureCopyWith<AttachmentSignedUrlFailure> get copyWith => _$AttachmentSignedUrlFailureCopyWithImpl<AttachmentSignedUrlFailure>(this as AttachmentSignedUrlFailure, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlFailure'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('errorCode', errorCode))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentSignedUrlFailure&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,error,errorCode,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlFailure(id: $id, filename: $filename, error: $error, errorCode: $errorCode, message: $message)';
}


}

/// @nodoc
abstract mixin class $AttachmentSignedUrlFailureCopyWith<$Res>  {
  factory $AttachmentSignedUrlFailureCopyWith(AttachmentSignedUrlFailure value, $Res Function(AttachmentSignedUrlFailure) _then) = _$AttachmentSignedUrlFailureCopyWithImpl;
@useResult
$Res call({
 String? id, String? filename, String? error, int? errorCode, String? message
});




}
/// @nodoc
class _$AttachmentSignedUrlFailureCopyWithImpl<$Res>
    implements $AttachmentSignedUrlFailureCopyWith<$Res> {
  _$AttachmentSignedUrlFailureCopyWithImpl(this._self, this._then);

  final AttachmentSignedUrlFailure _self;
  final $Res Function(AttachmentSignedUrlFailure) _then;

/// Create a copy of AttachmentSignedUrlFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? filename = freezed,Object? error = freezed,Object? errorCode = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentSignedUrlFailure].
extension AttachmentSignedUrlFailurePatterns on AttachmentSignedUrlFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentSignedUrlFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentSignedUrlFailure value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentSignedUrlFailure value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? filename,  String? error,  int? errorCode,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure() when $default != null:
return $default(_that.id,_that.filename,_that.error,_that.errorCode,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? filename,  String? error,  int? errorCode,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure():
return $default(_that.id,_that.filename,_that.error,_that.errorCode,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? filename,  String? error,  int? errorCode,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentSignedUrlFailure() when $default != null:
return $default(_that.id,_that.filename,_that.error,_that.errorCode,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _AttachmentSignedUrlFailure with DiagnosticableTreeMixin implements AttachmentSignedUrlFailure {
  const _AttachmentSignedUrlFailure({this.id, this.filename, this.error, this.errorCode, this.message});


@override final  String? id;
@override final  String? filename;
@override final  String? error;
@override final  int? errorCode;
@override final  String? message;

/// Create a copy of AttachmentSignedUrlFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentSignedUrlFailureCopyWith<_AttachmentSignedUrlFailure> get copyWith => __$AttachmentSignedUrlFailureCopyWithImpl<_AttachmentSignedUrlFailure>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AttachmentSignedUrlFailure'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('errorCode', errorCode))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentSignedUrlFailure&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,error,errorCode,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AttachmentSignedUrlFailure(id: $id, filename: $filename, error: $error, errorCode: $errorCode, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AttachmentSignedUrlFailureCopyWith<$Res> implements $AttachmentSignedUrlFailureCopyWith<$Res> {
  factory _$AttachmentSignedUrlFailureCopyWith(_AttachmentSignedUrlFailure value, $Res Function(_AttachmentSignedUrlFailure) _then) = __$AttachmentSignedUrlFailureCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? filename, String? error, int? errorCode, String? message
});




}
/// @nodoc
class __$AttachmentSignedUrlFailureCopyWithImpl<$Res>
    implements _$AttachmentSignedUrlFailureCopyWith<$Res> {
  __$AttachmentSignedUrlFailureCopyWithImpl(this._self, this._then);

  final _AttachmentSignedUrlFailure _self;
  final $Res Function(_AttachmentSignedUrlFailure) _then;

/// Create a copy of AttachmentSignedUrlFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? filename = freezed,Object? error = freezed,Object? errorCode = freezed,Object? message = freezed,}) {
  return _then(_AttachmentSignedUrlFailure(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
