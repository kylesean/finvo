// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessageAttachment implements DiagnosticableTreeMixin {

 String get id; String get filename;/// Server-side storage key for this attachment. Distinct from [filename]
/// (the display name); required to fetch a signed URL for the right object.
 String? get objectKey; String? get signedUrl; DateTime? get expiresAt; AttachmentLoadStatus get status; String? get errorMessage;
/// Create a copy of ChatMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageAttachmentCopyWith<ChatMessageAttachment> get copyWith => _$ChatMessageAttachmentCopyWithImpl<ChatMessageAttachment>(this as ChatMessageAttachment, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ChatMessageAttachment'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('objectKey', objectKey))..add(DiagnosticsProperty('signedUrl', signedUrl))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,objectKey,signedUrl,expiresAt,status,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ChatMessageAttachment(id: $id, filename: $filename, objectKey: $objectKey, signedUrl: $signedUrl, expiresAt: $expiresAt, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ChatMessageAttachmentCopyWith<$Res>  {
  factory $ChatMessageAttachmentCopyWith(ChatMessageAttachment value, $Res Function(ChatMessageAttachment) _then) = _$ChatMessageAttachmentCopyWithImpl;
@useResult
$Res call({
 String id, String filename, String? objectKey, String? signedUrl, DateTime? expiresAt, AttachmentLoadStatus status, String? errorMessage
});




}
/// @nodoc
class _$ChatMessageAttachmentCopyWithImpl<$Res>
    implements $ChatMessageAttachmentCopyWith<$Res> {
  _$ChatMessageAttachmentCopyWithImpl(this._self, this._then);

  final ChatMessageAttachment _self;
  final $Res Function(ChatMessageAttachment) _then;

/// Create a copy of ChatMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filename = null,Object? objectKey = freezed,Object? signedUrl = freezed,Object? expiresAt = freezed,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,objectKey: freezed == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentLoadStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageAttachment].
extension ChatMessageAttachmentPatterns on ChatMessageAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String filename,  String? objectKey,  String? signedUrl,  DateTime? expiresAt,  AttachmentLoadStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageAttachment() when $default != null:
return $default(_that.id,_that.filename,_that.objectKey,_that.signedUrl,_that.expiresAt,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String filename,  String? objectKey,  String? signedUrl,  DateTime? expiresAt,  AttachmentLoadStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageAttachment():
return $default(_that.id,_that.filename,_that.objectKey,_that.signedUrl,_that.expiresAt,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String filename,  String? objectKey,  String? signedUrl,  DateTime? expiresAt,  AttachmentLoadStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageAttachment() when $default != null:
return $default(_that.id,_that.filename,_that.objectKey,_that.signedUrl,_that.expiresAt,_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessageAttachment with DiagnosticableTreeMixin implements ChatMessageAttachment {
  const _ChatMessageAttachment({required this.id, required this.filename, this.objectKey, this.signedUrl, this.expiresAt, this.status = AttachmentLoadStatus.initial, this.errorMessage});


@override final  String id;
@override final  String filename;
/// Server-side storage key for this attachment. Distinct from [filename]
/// (the display name); required to fetch a signed URL for the right object.
@override final  String? objectKey;
@override final  String? signedUrl;
@override final  DateTime? expiresAt;
@override@JsonKey() final  AttachmentLoadStatus status;
@override final  String? errorMessage;

/// Create a copy of ChatMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageAttachmentCopyWith<_ChatMessageAttachment> get copyWith => __$ChatMessageAttachmentCopyWithImpl<_ChatMessageAttachment>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ChatMessageAttachment'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('filename', filename))..add(DiagnosticsProperty('objectKey', objectKey))..add(DiagnosticsProperty('signedUrl', signedUrl))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.signedUrl, signedUrl) || other.signedUrl == signedUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,filename,objectKey,signedUrl,expiresAt,status,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ChatMessageAttachment(id: $id, filename: $filename, objectKey: $objectKey, signedUrl: $signedUrl, expiresAt: $expiresAt, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageAttachmentCopyWith<$Res> implements $ChatMessageAttachmentCopyWith<$Res> {
  factory _$ChatMessageAttachmentCopyWith(_ChatMessageAttachment value, $Res Function(_ChatMessageAttachment) _then) = __$ChatMessageAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String filename, String? objectKey, String? signedUrl, DateTime? expiresAt, AttachmentLoadStatus status, String? errorMessage
});




}
/// @nodoc
class __$ChatMessageAttachmentCopyWithImpl<$Res>
    implements _$ChatMessageAttachmentCopyWith<$Res> {
  __$ChatMessageAttachmentCopyWithImpl(this._self, this._then);

  final _ChatMessageAttachment _self;
  final $Res Function(_ChatMessageAttachment) _then;

/// Create a copy of ChatMessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filename = null,Object? objectKey = freezed,Object? signedUrl = freezed,Object? expiresAt = freezed,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_ChatMessageAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,objectKey: freezed == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String?,signedUrl: freezed == signedUrl ? _self.signedUrl : signedUrl // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentLoadStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
