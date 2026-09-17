// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_education.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvEducation {

 String get id; String get degree; String get school; String get location; CvDateRange get period; String get description;
/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvEducationCopyWith<CvEducation> get copyWith => _$CvEducationCopyWithImpl<CvEducation>(this as CvEducation, _$identity);

  /// Serializes this CvEducation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvEducation&&(identical(other.id, id) || other.id == id)&&(identical(other.degree, degree) || other.degree == degree)&&(identical(other.school, school) || other.school == school)&&(identical(other.location, location) || other.location == location)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,degree,school,location,period,description);

@override
String toString() {
  return 'CvEducation(id: $id, degree: $degree, school: $school, location: $location, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvEducationCopyWith<$Res>  {
  factory $CvEducationCopyWith(CvEducation value, $Res Function(CvEducation) _then) = _$CvEducationCopyWithImpl;
@useResult
$Res call({
 String id, String degree, String school, String location, CvDateRange period, String description
});


$CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$CvEducationCopyWithImpl<$Res>
    implements $CvEducationCopyWith<$Res> {
  _$CvEducationCopyWithImpl(this._self, this._then);

  final CvEducation _self;
  final $Res Function(CvEducation) _then;

/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? degree = null,Object? school = null,Object? location = null,Object? period = null,Object? description = null,}) {
  return _then(CvEducation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvEducation].
extension CvEducationPatterns on CvEducation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvEducation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvEducation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvEducation value)  $default,){
final _that = this;
switch (_that) {
case _CvEducation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvEducation value)?  $default,){
final _that = this;
switch (_that) {
case _CvEducation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String degree,  String school,  String location,  CvDateRange period,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvEducation() when $default != null:
return $default(_that.id,_that.degree,_that.school,_that.location,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String degree,  String school,  String location,  CvDateRange period,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvEducation():
return $default(_that.id,_that.degree,_that.school,_that.location,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String degree,  String school,  String location,  CvDateRange period,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvEducation() when $default != null:
return $default(_that.id,_that.degree,_that.school,_that.location,_that.period,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvEducation implements CvEducation {
  const _CvEducation({required this.id, this.degree = '', this.school = '', this.location = '', this.period = const CvDateRange(), this.description = ''});
  factory _CvEducation.fromJson(Map<String, dynamic> json) => _$CvEducationFromJson(json);

@override final  String id;
@override@JsonKey() final  String degree;
@override@JsonKey() final  String school;
@override@JsonKey() final  String location;
@override@JsonKey() final  CvDateRange period;
@override@JsonKey() final  String description;

/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvEducationCopyWith<_CvEducation> get copyWith => __$CvEducationCopyWithImpl<_CvEducation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvEducationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvEducation&&(identical(other.id, id) || other.id == id)&&(identical(other.degree, degree) || other.degree == degree)&&(identical(other.school, school) || other.school == school)&&(identical(other.location, location) || other.location == location)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,degree,school,location,period,description);

@override
String toString() {
  return 'CvEducation(id: $id, degree: $degree, school: $school, location: $location, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvEducationCopyWith<$Res> implements $CvEducationCopyWith<$Res> {
  factory _$CvEducationCopyWith(_CvEducation value, $Res Function(_CvEducation) _then) = __$CvEducationCopyWithImpl;
@override @useResult
$Res call({
 String id, String degree, String school, String location, CvDateRange period, String description
});


@override $CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$CvEducationCopyWithImpl<$Res>
    implements _$CvEducationCopyWith<$Res> {
  __$CvEducationCopyWithImpl(this._self, this._then);

  final _CvEducation _self;
  final $Res Function(_CvEducation) _then;

/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? degree = null,Object? school = null,Object? location = null,Object? period = null,Object? description = null,}) {
  return _then(_CvEducation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CvEducation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}

// dart format on
