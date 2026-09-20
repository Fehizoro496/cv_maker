// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_skill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvSkill {

 String get id; String get name; String get category; String get level;
/// Create a copy of CvSkill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvSkillCopyWith<CvSkill> get copyWith => _$CvSkillCopyWithImpl<CvSkill>(this as CvSkill, _$identity);

  /// Serializes this CvSkill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,level);

@override
String toString() {
  return 'CvSkill(id: $id, name: $name, category: $category, level: $level)';
}


}

/// @nodoc
abstract mixin class $CvSkillCopyWith<$Res>  {
  factory $CvSkillCopyWith(CvSkill value, $Res Function(CvSkill) _then) = _$CvSkillCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, String level
});




}
/// @nodoc
class _$CvSkillCopyWithImpl<$Res>
    implements $CvSkillCopyWith<$Res> {
  _$CvSkillCopyWithImpl(this._self, this._then);

  final CvSkill _self;
  final $Res Function(CvSkill) _then;

/// Create a copy of CvSkill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? level = null,}) {
  return _then(CvSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CvSkill].
extension CvSkillPatterns on CvSkill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvSkill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvSkill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvSkill value)  $default,){
final _that = this;
switch (_that) {
case _CvSkill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvSkill value)?  $default,){
final _that = this;
switch (_that) {
case _CvSkill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvSkill() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String level)  $default,) {final _that = this;
switch (_that) {
case _CvSkill():
return $default(_that.id,_that.name,_that.category,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  String level)?  $default,) {final _that = this;
switch (_that) {
case _CvSkill() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvSkill implements CvSkill {
  const _CvSkill({required this.id, this.name = '', this.category = '', this.level = ''});
  factory _CvSkill.fromJson(Map<String, dynamic> json) => _$CvSkillFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String category;
@override@JsonKey() final  String level;

/// Create a copy of CvSkill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvSkillCopyWith<_CvSkill> get copyWith => __$CvSkillCopyWithImpl<_CvSkill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvSkillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvSkill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,level);

@override
String toString() {
  return 'CvSkill(id: $id, name: $name, category: $category, level: $level)';
}


}

/// @nodoc
abstract mixin class _$CvSkillCopyWith<$Res> implements $CvSkillCopyWith<$Res> {
  factory _$CvSkillCopyWith(_CvSkill value, $Res Function(_CvSkill) _then) = __$CvSkillCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, String level
});




}
/// @nodoc
class __$CvSkillCopyWithImpl<$Res>
    implements _$CvSkillCopyWith<$Res> {
  __$CvSkillCopyWithImpl(this._self, this._then);

  final _CvSkill _self;
  final $Res Function(_CvSkill) _then;

/// Create a copy of CvSkill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? level = null,}) {
  return _then(_CvSkill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
