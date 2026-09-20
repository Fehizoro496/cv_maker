// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_certification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvCertification {

 String get id; String get name; String get issuer; CvMonthYear? get date; String get description;
/// Create a copy of CvCertification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvCertificationCopyWith<CvCertification> get copyWith => _$CvCertificationCopyWithImpl<CvCertification>(this as CvCertification, _$identity);

  /// Serializes this CvCertification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issuer,date,description);

@override
String toString() {
  return 'CvCertification(id: $id, name: $name, issuer: $issuer, date: $date, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvCertificationCopyWith<$Res>  {
  factory $CvCertificationCopyWith(CvCertification value, $Res Function(CvCertification) _then) = _$CvCertificationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String issuer, CvMonthYear? date, String description
});




}
/// @nodoc
class _$CvCertificationCopyWithImpl<$Res>
    implements $CvCertificationCopyWith<$Res> {
  _$CvCertificationCopyWithImpl(this._self, this._then);

  final CvCertification _self;
  final $Res Function(CvCertification) _then;

/// Create a copy of CvCertification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? issuer = null,Object? date = freezed,Object? description = null,}) {
  return _then(CvCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CvCertification].
extension CvCertificationPatterns on CvCertification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvCertification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvCertification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvCertification value)  $default,){
final _that = this;
switch (_that) {
case _CvCertification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvCertification value)?  $default,){
final _that = this;
switch (_that) {
case _CvCertification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String issuer,  CvMonthYear? date,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvCertification() when $default != null:
return $default(_that.id,_that.name,_that.issuer,_that.date,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String issuer,  CvMonthYear? date,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvCertification():
return $default(_that.id,_that.name,_that.issuer,_that.date,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String issuer,  CvMonthYear? date,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvCertification() when $default != null:
return $default(_that.id,_that.name,_that.issuer,_that.date,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvCertification implements CvCertification {
  const _CvCertification({required this.id, this.name = '', this.issuer = '', this.date, this.description = ''});
  factory _CvCertification.fromJson(Map<String, dynamic> json) => _$CvCertificationFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String issuer;
@override final  CvMonthYear? date;
@override@JsonKey() final  String description;

/// Create a copy of CvCertification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvCertificationCopyWith<_CvCertification> get copyWith => __$CvCertificationCopyWithImpl<_CvCertification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvCertificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issuer,date,description);

@override
String toString() {
  return 'CvCertification(id: $id, name: $name, issuer: $issuer, date: $date, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvCertificationCopyWith<$Res> implements $CvCertificationCopyWith<$Res> {
  factory _$CvCertificationCopyWith(_CvCertification value, $Res Function(_CvCertification) _then) = __$CvCertificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String issuer, CvMonthYear? date, String description
});




}
/// @nodoc
class __$CvCertificationCopyWithImpl<$Res>
    implements _$CvCertificationCopyWith<$Res> {
  __$CvCertificationCopyWithImpl(this._self, this._then);

  final _CvCertification _self;
  final $Res Function(_CvCertification) _then;

/// Create a copy of CvCertification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? issuer = null,Object? date = freezed,Object? description = null,}) {
  return _then(_CvCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
