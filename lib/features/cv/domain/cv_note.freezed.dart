// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvNote {

 String get id; String get label; String get description;
/// Create a copy of CvNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvNoteCopyWith<CvNote> get copyWith => _$CvNoteCopyWithImpl<CvNote>(this as CvNote, _$identity);

  /// Serializes this CvNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvNote&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description);

@override
String toString() {
  return 'CvNote(id: $id, label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvNoteCopyWith<$Res>  {
  factory $CvNoteCopyWith(CvNote value, $Res Function(CvNote) _then) = _$CvNoteCopyWithImpl;
@useResult
$Res call({
 String id, String label, String description
});




}
/// @nodoc
class _$CvNoteCopyWithImpl<$Res>
    implements $CvNoteCopyWith<$Res> {
  _$CvNoteCopyWithImpl(this._self, this._then);

  final CvNote _self;
  final $Res Function(CvNote) _then;

/// Create a copy of CvNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? description = null,}) {
  return _then(CvNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CvNote].
extension CvNotePatterns on CvNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvNote value)  $default,){
final _that = this;
switch (_that) {
case _CvNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvNote value)?  $default,){
final _that = this;
switch (_that) {
case _CvNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvNote() when $default != null:
return $default(_that.id,_that.label,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvNote():
return $default(_that.id,_that.label,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvNote() when $default != null:
return $default(_that.id,_that.label,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvNote implements CvNote {
  const _CvNote({required this.id, this.label = '', this.description = ''});
  factory _CvNote.fromJson(Map<String, dynamic> json) => _$CvNoteFromJson(json);

@override final  String id;
@override@JsonKey() final  String label;
@override@JsonKey() final  String description;

/// Create a copy of CvNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvNoteCopyWith<_CvNote> get copyWith => __$CvNoteCopyWithImpl<_CvNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvNote&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description);

@override
String toString() {
  return 'CvNote(id: $id, label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvNoteCopyWith<$Res> implements $CvNoteCopyWith<$Res> {
  factory _$CvNoteCopyWith(_CvNote value, $Res Function(_CvNote) _then) = __$CvNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String description
});




}
/// @nodoc
class __$CvNoteCopyWithImpl<$Res>
    implements _$CvNoteCopyWith<$Res> {
  __$CvNoteCopyWithImpl(this._self, this._then);

  final _CvNote _self;
  final $Res Function(_CvNote) _then;

/// Create a copy of CvNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? description = null,}) {
  return _then(_CvNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
