// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_attachments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadedAttachmentInfo {

 String get id; String get attachmentId; String get originalName; String get objectKey; String get uri; String get mimeType; double get size; String? get hash;
/// Create a copy of UploadedAttachmentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadedAttachmentInfoCopyWith<UploadedAttachmentInfo> get copyWith => _$UploadedAttachmentInfoCopyWithImpl<UploadedAttachmentInfo>(this as UploadedAttachmentInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadedAttachmentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.attachmentId, attachmentId) || other.attachmentId == attachmentId)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size)&&(identical(other.hash, hash) || other.hash == hash));
}


@override
int get hashCode => Object.hash(runtimeType,id,attachmentId,originalName,objectKey,uri,mimeType,size,hash);

@override
String toString() {
  return 'UploadedAttachmentInfo(id: $id, attachmentId: $attachmentId, originalName: $originalName, objectKey: $objectKey, uri: $uri, mimeType: $mimeType, size: $size, hash: $hash)';
}


}

/// @nodoc
abstract mixin class $UploadedAttachmentInfoCopyWith<$Res>  {
  factory $UploadedAttachmentInfoCopyWith(UploadedAttachmentInfo value, $Res Function(UploadedAttachmentInfo) _then) = _$UploadedAttachmentInfoCopyWithImpl;
@useResult
$Res call({
 String id, String attachmentId, String originalName, String objectKey, String uri, String mimeType, double size, String? hash
});




}
/// @nodoc
class _$UploadedAttachmentInfoCopyWithImpl<$Res>
    implements $UploadedAttachmentInfoCopyWith<$Res> {
  _$UploadedAttachmentInfoCopyWithImpl(this._self, this._then);

  final UploadedAttachmentInfo _self;
  final $Res Function(UploadedAttachmentInfo) _then;

/// Create a copy of UploadedAttachmentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attachmentId = null,Object? originalName = null,Object? objectKey = null,Object? uri = null,Object? mimeType = null,Object? size = null,Object? hash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attachmentId: null == attachmentId ? _self.attachmentId : attachmentId // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadedAttachmentInfo].
extension UploadedAttachmentInfoPatterns on UploadedAttachmentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadedAttachmentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadedAttachmentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadedAttachmentInfo value)  $default,){
final _that = this;
switch (_that) {
case _UploadedAttachmentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadedAttachmentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UploadedAttachmentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String attachmentId,  String originalName,  String objectKey,  String uri,  String mimeType,  double size,  String? hash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadedAttachmentInfo() when $default != null:
return $default(_that.id,_that.attachmentId,_that.originalName,_that.objectKey,_that.uri,_that.mimeType,_that.size,_that.hash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String attachmentId,  String originalName,  String objectKey,  String uri,  String mimeType,  double size,  String? hash)  $default,) {final _that = this;
switch (_that) {
case _UploadedAttachmentInfo():
return $default(_that.id,_that.attachmentId,_that.originalName,_that.objectKey,_that.uri,_that.mimeType,_that.size,_that.hash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String attachmentId,  String originalName,  String objectKey,  String uri,  String mimeType,  double size,  String? hash)?  $default,) {final _that = this;
switch (_that) {
case _UploadedAttachmentInfo() when $default != null:
return $default(_that.id,_that.attachmentId,_that.originalName,_that.objectKey,_that.uri,_that.mimeType,_that.size,_that.hash);case _:
  return null;

}
}

}

/// @nodoc


class _UploadedAttachmentInfo implements UploadedAttachmentInfo {
  const _UploadedAttachmentInfo({required this.id, required this.attachmentId, required this.originalName, required this.objectKey, required this.uri, required this.mimeType, required this.size, this.hash});


@override final  String id;
@override final  String attachmentId;
@override final  String originalName;
@override final  String objectKey;
@override final  String uri;
@override final  String mimeType;
@override final  double size;
@override final  String? hash;

/// Create a copy of UploadedAttachmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadedAttachmentInfoCopyWith<_UploadedAttachmentInfo> get copyWith => __$UploadedAttachmentInfoCopyWithImpl<_UploadedAttachmentInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadedAttachmentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.attachmentId, attachmentId) || other.attachmentId == attachmentId)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.size, size) || other.size == size)&&(identical(other.hash, hash) || other.hash == hash));
}


@override
int get hashCode => Object.hash(runtimeType,id,attachmentId,originalName,objectKey,uri,mimeType,size,hash);

@override
String toString() {
  return 'UploadedAttachmentInfo(id: $id, attachmentId: $attachmentId, originalName: $originalName, objectKey: $objectKey, uri: $uri, mimeType: $mimeType, size: $size, hash: $hash)';
}


}

/// @nodoc
abstract mixin class _$UploadedAttachmentInfoCopyWith<$Res> implements $UploadedAttachmentInfoCopyWith<$Res> {
  factory _$UploadedAttachmentInfoCopyWith(_UploadedAttachmentInfo value, $Res Function(_UploadedAttachmentInfo) _then) = __$UploadedAttachmentInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String attachmentId, String originalName, String objectKey, String uri, String mimeType, double size, String? hash
});




}
/// @nodoc
class __$UploadedAttachmentInfoCopyWithImpl<$Res>
    implements _$UploadedAttachmentInfoCopyWith<$Res> {
  __$UploadedAttachmentInfoCopyWithImpl(this._self, this._then);

  final _UploadedAttachmentInfo _self;
  final $Res Function(_UploadedAttachmentInfo) _then;

/// Create a copy of UploadedAttachmentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attachmentId = null,Object? originalName = null,Object? objectKey = null,Object? uri = null,Object? mimeType = null,Object? size = null,Object? hash = freezed,}) {
  return _then(_UploadedAttachmentInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attachmentId: null == attachmentId ? _self.attachmentId : attachmentId // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$PendingMessageAttachment {

 XFile get file; UploadedAttachmentInfo get uploadInfo;
/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMessageAttachmentCopyWith<PendingMessageAttachment> get copyWith => _$PendingMessageAttachmentCopyWithImpl<PendingMessageAttachment>(this as PendingMessageAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMessageAttachment&&(identical(other.file, file) || other.file == file)&&(identical(other.uploadInfo, uploadInfo) || other.uploadInfo == uploadInfo));
}


@override
int get hashCode => Object.hash(runtimeType,file,uploadInfo);

@override
String toString() {
  return 'PendingMessageAttachment(file: $file, uploadInfo: $uploadInfo)';
}


}

/// @nodoc
abstract mixin class $PendingMessageAttachmentCopyWith<$Res>  {
  factory $PendingMessageAttachmentCopyWith(PendingMessageAttachment value, $Res Function(PendingMessageAttachment) _then) = _$PendingMessageAttachmentCopyWithImpl;
@useResult
$Res call({
 XFile file, UploadedAttachmentInfo uploadInfo
});


$UploadedAttachmentInfoCopyWith<$Res> get uploadInfo;

}
/// @nodoc
class _$PendingMessageAttachmentCopyWithImpl<$Res>
    implements $PendingMessageAttachmentCopyWith<$Res> {
  _$PendingMessageAttachmentCopyWithImpl(this._self, this._then);

  final PendingMessageAttachment _self;
  final $Res Function(PendingMessageAttachment) _then;

/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? file = null,Object? uploadInfo = null,}) {
  return _then(_self.copyWith(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as XFile,uploadInfo: null == uploadInfo ? _self.uploadInfo : uploadInfo // ignore: cast_nullable_to_non_nullable
as UploadedAttachmentInfo,
  ));
}
/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadedAttachmentInfoCopyWith<$Res> get uploadInfo {

  return $UploadedAttachmentInfoCopyWith<$Res>(_self.uploadInfo, (value) {
    return _then(_self.copyWith(uploadInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [PendingMessageAttachment].
extension PendingMessageAttachmentPatterns on PendingMessageAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingMessageAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingMessageAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingMessageAttachment value)  $default,){
final _that = this;
switch (_that) {
case _PendingMessageAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingMessageAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _PendingMessageAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( XFile file,  UploadedAttachmentInfo uploadInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMessageAttachment() when $default != null:
return $default(_that.file,_that.uploadInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( XFile file,  UploadedAttachmentInfo uploadInfo)  $default,) {final _that = this;
switch (_that) {
case _PendingMessageAttachment():
return $default(_that.file,_that.uploadInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( XFile file,  UploadedAttachmentInfo uploadInfo)?  $default,) {final _that = this;
switch (_that) {
case _PendingMessageAttachment() when $default != null:
return $default(_that.file,_that.uploadInfo);case _:
  return null;

}
}

}

/// @nodoc


class _PendingMessageAttachment implements PendingMessageAttachment {
  const _PendingMessageAttachment({required this.file, required this.uploadInfo});


@override final  XFile file;
@override final  UploadedAttachmentInfo uploadInfo;

/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingMessageAttachmentCopyWith<_PendingMessageAttachment> get copyWith => __$PendingMessageAttachmentCopyWithImpl<_PendingMessageAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMessageAttachment&&(identical(other.file, file) || other.file == file)&&(identical(other.uploadInfo, uploadInfo) || other.uploadInfo == uploadInfo));
}


@override
int get hashCode => Object.hash(runtimeType,file,uploadInfo);

@override
String toString() {
  return 'PendingMessageAttachment(file: $file, uploadInfo: $uploadInfo)';
}


}

/// @nodoc
abstract mixin class _$PendingMessageAttachmentCopyWith<$Res> implements $PendingMessageAttachmentCopyWith<$Res> {
  factory _$PendingMessageAttachmentCopyWith(_PendingMessageAttachment value, $Res Function(_PendingMessageAttachment) _then) = __$PendingMessageAttachmentCopyWithImpl;
@override @useResult
$Res call({
 XFile file, UploadedAttachmentInfo uploadInfo
});


@override $UploadedAttachmentInfoCopyWith<$Res> get uploadInfo;

}
/// @nodoc
class __$PendingMessageAttachmentCopyWithImpl<$Res>
    implements _$PendingMessageAttachmentCopyWith<$Res> {
  __$PendingMessageAttachmentCopyWithImpl(this._self, this._then);

  final _PendingMessageAttachment _self;
  final $Res Function(_PendingMessageAttachment) _then;

/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = null,Object? uploadInfo = null,}) {
  return _then(_PendingMessageAttachment(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as XFile,uploadInfo: null == uploadInfo ? _self.uploadInfo : uploadInfo // ignore: cast_nullable_to_non_nullable
as UploadedAttachmentInfo,
  ));
}

/// Create a copy of PendingMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadedAttachmentInfoCopyWith<$Res> get uploadInfo {

  return $UploadedAttachmentInfoCopyWith<$Res>(_self.uploadInfo, (value) {
    return _then(_self.copyWith(uploadInfo: value));
  });
}
}

// dart format on
