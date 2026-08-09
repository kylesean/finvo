// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfileState {

 UserInfo? get user; bool get isLoading; bool get isSaving; bool get isUploadingAvatar; String? get error;/// Cache-busting value bumped each time the avatar is re-uploaded, so the
/// profile page's [UserAvatar] fetches a fresh image instead of serving
/// the stale one from Flutter's image cache.
 String? get avatarCacheBuster;
/// Create a copy of UserProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileStateCopyWith<UserProfileState> get copyWith => _$UserProfileStateCopyWithImpl<UserProfileState>(this as UserProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileState&&(identical(other.user, user) || other.user == user)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isUploadingAvatar, isUploadingAvatar) || other.isUploadingAvatar == isUploadingAvatar)&&(identical(other.error, error) || other.error == error)&&(identical(other.avatarCacheBuster, avatarCacheBuster) || other.avatarCacheBuster == avatarCacheBuster));
}


@override
int get hashCode => Object.hash(runtimeType,user,isLoading,isSaving,isUploadingAvatar,error,avatarCacheBuster);

@override
String toString() {
  return 'UserProfileState(user: $user, isLoading: $isLoading, isSaving: $isSaving, isUploadingAvatar: $isUploadingAvatar, error: $error, avatarCacheBuster: $avatarCacheBuster)';
}


}

/// @nodoc
abstract mixin class $UserProfileStateCopyWith<$Res>  {
  factory $UserProfileStateCopyWith(UserProfileState value, $Res Function(UserProfileState) _then) = _$UserProfileStateCopyWithImpl;
@useResult
$Res call({
 UserInfo? user, bool isLoading, bool isSaving, bool isUploadingAvatar, String? error, String? avatarCacheBuster
});




}
/// @nodoc
class _$UserProfileStateCopyWithImpl<$Res>
    implements $UserProfileStateCopyWith<$Res> {
  _$UserProfileStateCopyWithImpl(this._self, this._then);

  final UserProfileState _self;
  final $Res Function(UserProfileState) _then;

/// Create a copy of UserProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = freezed,Object? isLoading = null,Object? isSaving = null,Object? isUploadingAvatar = null,Object? error = freezed,Object? avatarCacheBuster = freezed,}) {
  return _then(_self.copyWith(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfo?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isUploadingAvatar: null == isUploadingAvatar ? _self.isUploadingAvatar : isUploadingAvatar // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,avatarCacheBuster: freezed == avatarCacheBuster ? _self.avatarCacheBuster : avatarCacheBuster // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileState].
extension UserProfileStatePatterns on UserProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileState value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserInfo? user,  bool isLoading,  bool isSaving,  bool isUploadingAvatar,  String? error,  String? avatarCacheBuster)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileState() when $default != null:
return $default(_that.user,_that.isLoading,_that.isSaving,_that.isUploadingAvatar,_that.error,_that.avatarCacheBuster);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserInfo? user,  bool isLoading,  bool isSaving,  bool isUploadingAvatar,  String? error,  String? avatarCacheBuster)  $default,) {final _that = this;
switch (_that) {
case _UserProfileState():
return $default(_that.user,_that.isLoading,_that.isSaving,_that.isUploadingAvatar,_that.error,_that.avatarCacheBuster);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserInfo? user,  bool isLoading,  bool isSaving,  bool isUploadingAvatar,  String? error,  String? avatarCacheBuster)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileState() when $default != null:
return $default(_that.user,_that.isLoading,_that.isSaving,_that.isUploadingAvatar,_that.error,_that.avatarCacheBuster);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfileState implements UserProfileState {
  const _UserProfileState({this.user, this.isLoading = false, this.isSaving = false, this.isUploadingAvatar = false, this.error, this.avatarCacheBuster});


@override final  UserInfo? user;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isUploadingAvatar;
@override final  String? error;
/// Cache-busting value bumped each time the avatar is re-uploaded, so the
/// profile page's [UserAvatar] fetches a fresh image instead of serving
/// the stale one from Flutter's image cache.
@override final  String? avatarCacheBuster;

/// Create a copy of UserProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileStateCopyWith<_UserProfileState> get copyWith => __$UserProfileStateCopyWithImpl<_UserProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileState&&(identical(other.user, user) || other.user == user)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isUploadingAvatar, isUploadingAvatar) || other.isUploadingAvatar == isUploadingAvatar)&&(identical(other.error, error) || other.error == error)&&(identical(other.avatarCacheBuster, avatarCacheBuster) || other.avatarCacheBuster == avatarCacheBuster));
}


@override
int get hashCode => Object.hash(runtimeType,user,isLoading,isSaving,isUploadingAvatar,error,avatarCacheBuster);

@override
String toString() {
  return 'UserProfileState(user: $user, isLoading: $isLoading, isSaving: $isSaving, isUploadingAvatar: $isUploadingAvatar, error: $error, avatarCacheBuster: $avatarCacheBuster)';
}


}

/// @nodoc
abstract mixin class _$UserProfileStateCopyWith<$Res> implements $UserProfileStateCopyWith<$Res> {
  factory _$UserProfileStateCopyWith(_UserProfileState value, $Res Function(_UserProfileState) _then) = __$UserProfileStateCopyWithImpl;
@override @useResult
$Res call({
 UserInfo? user, bool isLoading, bool isSaving, bool isUploadingAvatar, String? error, String? avatarCacheBuster
});




}
/// @nodoc
class __$UserProfileStateCopyWithImpl<$Res>
    implements _$UserProfileStateCopyWith<$Res> {
  __$UserProfileStateCopyWithImpl(this._self, this._then);

  final _UserProfileState _self;
  final $Res Function(_UserProfileState) _then;

/// Create a copy of UserProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = freezed,Object? isLoading = null,Object? isSaving = null,Object? isUploadingAvatar = null,Object? error = freezed,Object? avatarCacheBuster = freezed,}) {
  return _then(_UserProfileState(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfo?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isUploadingAvatar: null == isUploadingAvatar ? _self.isUploadingAvatar : isUploadingAvatar // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,avatarCacheBuster: freezed == avatarCacheBuster ? _self.avatarCacheBuster : avatarCacheBuster // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
