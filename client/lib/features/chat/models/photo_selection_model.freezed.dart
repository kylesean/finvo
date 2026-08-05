// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_selection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoSelectionItem {

 XFile get photo; int get selectionOrder; String get id;
/// Create a copy of PhotoSelectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoSelectionItemCopyWith<PhotoSelectionItem> get copyWith => _$PhotoSelectionItemCopyWithImpl<PhotoSelectionItem>(this as PhotoSelectionItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoSelectionItem&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.selectionOrder, selectionOrder) || other.selectionOrder == selectionOrder)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,photo,selectionOrder,id);

@override
String toString() {
  return 'PhotoSelectionItem(photo: $photo, selectionOrder: $selectionOrder, id: $id)';
}


}

/// @nodoc
abstract mixin class $PhotoSelectionItemCopyWith<$Res>  {
  factory $PhotoSelectionItemCopyWith(PhotoSelectionItem value, $Res Function(PhotoSelectionItem) _then) = _$PhotoSelectionItemCopyWithImpl;
@useResult
$Res call({
 XFile photo, int selectionOrder, String id
});




}
/// @nodoc
class _$PhotoSelectionItemCopyWithImpl<$Res>
    implements $PhotoSelectionItemCopyWith<$Res> {
  _$PhotoSelectionItemCopyWithImpl(this._self, this._then);

  final PhotoSelectionItem _self;
  final $Res Function(PhotoSelectionItem) _then;

/// Create a copy of PhotoSelectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photo = null,Object? selectionOrder = null,Object? id = null,}) {
  return _then(_self.copyWith(
photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as XFile,selectionOrder: null == selectionOrder ? _self.selectionOrder : selectionOrder // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoSelectionItem].
extension PhotoSelectionItemPatterns on PhotoSelectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoSelectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoSelectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoSelectionItem value)  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoSelectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( XFile photo,  int selectionOrder,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoSelectionItem() when $default != null:
return $default(_that.photo,_that.selectionOrder,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( XFile photo,  int selectionOrder,  String id)  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionItem():
return $default(_that.photo,_that.selectionOrder,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( XFile photo,  int selectionOrder,  String id)?  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionItem() when $default != null:
return $default(_that.photo,_that.selectionOrder,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoSelectionItem implements PhotoSelectionItem {
  const _PhotoSelectionItem({required this.photo, required this.selectionOrder, required this.id});


@override final  XFile photo;
@override final  int selectionOrder;
@override final  String id;

/// Create a copy of PhotoSelectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoSelectionItemCopyWith<_PhotoSelectionItem> get copyWith => __$PhotoSelectionItemCopyWithImpl<_PhotoSelectionItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoSelectionItem&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.selectionOrder, selectionOrder) || other.selectionOrder == selectionOrder)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,photo,selectionOrder,id);

@override
String toString() {
  return 'PhotoSelectionItem(photo: $photo, selectionOrder: $selectionOrder, id: $id)';
}


}

/// @nodoc
abstract mixin class _$PhotoSelectionItemCopyWith<$Res> implements $PhotoSelectionItemCopyWith<$Res> {
  factory _$PhotoSelectionItemCopyWith(_PhotoSelectionItem value, $Res Function(_PhotoSelectionItem) _then) = __$PhotoSelectionItemCopyWithImpl;
@override @useResult
$Res call({
 XFile photo, int selectionOrder, String id
});




}
/// @nodoc
class __$PhotoSelectionItemCopyWithImpl<$Res>
    implements _$PhotoSelectionItemCopyWith<$Res> {
  __$PhotoSelectionItemCopyWithImpl(this._self, this._then);

  final _PhotoSelectionItem _self;
  final $Res Function(_PhotoSelectionItem) _then;

/// Create a copy of PhotoSelectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photo = null,Object? selectionOrder = null,Object? id = null,}) {
  return _then(_PhotoSelectionItem(
photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as XFile,selectionOrder: null == selectionOrder ? _self.selectionOrder : selectionOrder // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PhotoSelectionState {

 List<XFile> get availablePhotos; Map<String, PhotoSelectionItem> get selectedPhotos; bool get isLoading; String? get errorMessage; bool get hasPermission; int get maxSelectionCount;
/// Create a copy of PhotoSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoSelectionStateCopyWith<PhotoSelectionState> get copyWith => _$PhotoSelectionStateCopyWithImpl<PhotoSelectionState>(this as PhotoSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoSelectionState&&const DeepCollectionEquality().equals(other.availablePhotos, availablePhotos)&&const DeepCollectionEquality().equals(other.selectedPhotos, selectedPhotos)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasPermission, hasPermission) || other.hasPermission == hasPermission)&&(identical(other.maxSelectionCount, maxSelectionCount) || other.maxSelectionCount == maxSelectionCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(availablePhotos),const DeepCollectionEquality().hash(selectedPhotos),isLoading,errorMessage,hasPermission,maxSelectionCount);

@override
String toString() {
  return 'PhotoSelectionState(availablePhotos: $availablePhotos, selectedPhotos: $selectedPhotos, isLoading: $isLoading, errorMessage: $errorMessage, hasPermission: $hasPermission, maxSelectionCount: $maxSelectionCount)';
}


}

/// @nodoc
abstract mixin class $PhotoSelectionStateCopyWith<$Res>  {
  factory $PhotoSelectionStateCopyWith(PhotoSelectionState value, $Res Function(PhotoSelectionState) _then) = _$PhotoSelectionStateCopyWithImpl;
@useResult
$Res call({
 List<XFile> availablePhotos, Map<String, PhotoSelectionItem> selectedPhotos, bool isLoading, String? errorMessage, bool hasPermission, int maxSelectionCount
});




}
/// @nodoc
class _$PhotoSelectionStateCopyWithImpl<$Res>
    implements $PhotoSelectionStateCopyWith<$Res> {
  _$PhotoSelectionStateCopyWithImpl(this._self, this._then);

  final PhotoSelectionState _self;
  final $Res Function(PhotoSelectionState) _then;

/// Create a copy of PhotoSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? availablePhotos = null,Object? selectedPhotos = null,Object? isLoading = null,Object? errorMessage = freezed,Object? hasPermission = null,Object? maxSelectionCount = null,}) {
  return _then(_self.copyWith(
availablePhotos: null == availablePhotos ? _self.availablePhotos : availablePhotos // ignore: cast_nullable_to_non_nullable
as List<XFile>,selectedPhotos: null == selectedPhotos ? _self.selectedPhotos : selectedPhotos // ignore: cast_nullable_to_non_nullable
as Map<String, PhotoSelectionItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasPermission: null == hasPermission ? _self.hasPermission : hasPermission // ignore: cast_nullable_to_non_nullable
as bool,maxSelectionCount: null == maxSelectionCount ? _self.maxSelectionCount : maxSelectionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoSelectionState].
extension PhotoSelectionStatePatterns on PhotoSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoSelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoSelectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoSelectionState value)  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoSelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<XFile> availablePhotos,  Map<String, PhotoSelectionItem> selectedPhotos,  bool isLoading,  String? errorMessage,  bool hasPermission,  int maxSelectionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoSelectionState() when $default != null:
return $default(_that.availablePhotos,_that.selectedPhotos,_that.isLoading,_that.errorMessage,_that.hasPermission,_that.maxSelectionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<XFile> availablePhotos,  Map<String, PhotoSelectionItem> selectedPhotos,  bool isLoading,  String? errorMessage,  bool hasPermission,  int maxSelectionCount)  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionState():
return $default(_that.availablePhotos,_that.selectedPhotos,_that.isLoading,_that.errorMessage,_that.hasPermission,_that.maxSelectionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<XFile> availablePhotos,  Map<String, PhotoSelectionItem> selectedPhotos,  bool isLoading,  String? errorMessage,  bool hasPermission,  int maxSelectionCount)?  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionState() when $default != null:
return $default(_that.availablePhotos,_that.selectedPhotos,_that.isLoading,_that.errorMessage,_that.hasPermission,_that.maxSelectionCount);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoSelectionState implements PhotoSelectionState {
  const _PhotoSelectionState({final  List<XFile> availablePhotos = const <XFile>[], final  Map<String, PhotoSelectionItem> selectedPhotos = const <String, PhotoSelectionItem>{}, this.isLoading = false, this.errorMessage, this.hasPermission = false, this.maxSelectionCount = 9}): _availablePhotos = availablePhotos,_selectedPhotos = selectedPhotos;


 final  List<XFile> _availablePhotos;
@override@JsonKey() List<XFile> get availablePhotos {
  if (_availablePhotos is EqualUnmodifiableListView) return _availablePhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availablePhotos);
}

 final  Map<String, PhotoSelectionItem> _selectedPhotos;
@override@JsonKey() Map<String, PhotoSelectionItem> get selectedPhotos {
  if (_selectedPhotos is EqualUnmodifiableMapView) return _selectedPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedPhotos);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override@JsonKey() final  bool hasPermission;
@override@JsonKey() final  int maxSelectionCount;

/// Create a copy of PhotoSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoSelectionStateCopyWith<_PhotoSelectionState> get copyWith => __$PhotoSelectionStateCopyWithImpl<_PhotoSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoSelectionState&&const DeepCollectionEquality().equals(other._availablePhotos, _availablePhotos)&&const DeepCollectionEquality().equals(other._selectedPhotos, _selectedPhotos)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasPermission, hasPermission) || other.hasPermission == hasPermission)&&(identical(other.maxSelectionCount, maxSelectionCount) || other.maxSelectionCount == maxSelectionCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_availablePhotos),const DeepCollectionEquality().hash(_selectedPhotos),isLoading,errorMessage,hasPermission,maxSelectionCount);

@override
String toString() {
  return 'PhotoSelectionState(availablePhotos: $availablePhotos, selectedPhotos: $selectedPhotos, isLoading: $isLoading, errorMessage: $errorMessage, hasPermission: $hasPermission, maxSelectionCount: $maxSelectionCount)';
}


}

/// @nodoc
abstract mixin class _$PhotoSelectionStateCopyWith<$Res> implements $PhotoSelectionStateCopyWith<$Res> {
  factory _$PhotoSelectionStateCopyWith(_PhotoSelectionState value, $Res Function(_PhotoSelectionState) _then) = __$PhotoSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 List<XFile> availablePhotos, Map<String, PhotoSelectionItem> selectedPhotos, bool isLoading, String? errorMessage, bool hasPermission, int maxSelectionCount
});




}
/// @nodoc
class __$PhotoSelectionStateCopyWithImpl<$Res>
    implements _$PhotoSelectionStateCopyWith<$Res> {
  __$PhotoSelectionStateCopyWithImpl(this._self, this._then);

  final _PhotoSelectionState _self;
  final $Res Function(_PhotoSelectionState) _then;

/// Create a copy of PhotoSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? availablePhotos = null,Object? selectedPhotos = null,Object? isLoading = null,Object? errorMessage = freezed,Object? hasPermission = null,Object? maxSelectionCount = null,}) {
  return _then(_PhotoSelectionState(
availablePhotos: null == availablePhotos ? _self._availablePhotos : availablePhotos // ignore: cast_nullable_to_non_nullable
as List<XFile>,selectedPhotos: null == selectedPhotos ? _self._selectedPhotos : selectedPhotos // ignore: cast_nullable_to_non_nullable
as Map<String, PhotoSelectionItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasPermission: null == hasPermission ? _self.hasPermission : hasPermission // ignore: cast_nullable_to_non_nullable
as bool,maxSelectionCount: null == maxSelectionCount ? _self.maxSelectionCount : maxSelectionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
