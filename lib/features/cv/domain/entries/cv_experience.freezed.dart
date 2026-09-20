// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_experience.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvExperience {

 String get id; String get position; String get company; String get location; CvDateRange get period; String get description;
/// Create a copy of CvExperience
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvExperienceCopyWith<CvExperience> get copyWith => _$CvExperienceCopyWithImpl<CvExperience>(this as CvExperience, _$identity);

  /// Serializes this CvExperience to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvExperience&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,position,company,location,period,description);

@override
String toString() {
  return 'CvExperience(id: $id, position: $position, company: $company, location: $location, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvExperienceCopyWith<$Res>  {
  factory $CvExperienceCopyWith(CvExperience value, $Res Function(CvExperience) _then) = _$CvExperienceCopyWithImpl;
@useResult
$Res call({
 String id, String position, String company, String location, CvDateRange period, String description
});


$CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$CvExperienceCopyWithImpl<$Res>
    implements $CvExperienceCopyWith<$Res> {
  _$CvExperienceCopyWithImpl(this._self, this._then);

  final CvExperience _self;
  final $Res Function(CvExperience) _then;

/// Create a copy of CvExperience
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? company = null,Object? location = null,Object? period = null,Object? description = null,}) {
  return _then(CvExperience(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CvExperience
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvExperience].
extension CvExperiencePatterns on CvExperience {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvExperience value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvExperience() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvExperience value)  $default,){
final _that = this;
switch (_that) {
case _CvExperience():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvExperience value)?  $default,){
final _that = this;
switch (_that) {
case _CvExperience() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String position,  String company,  String location,  CvDateRange period,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvExperience() when $default != null:
return $default(_that.id,_that.position,_that.company,_that.location,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String position,  String company,  String location,  CvDateRange period,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvExperience():
return $default(_that.id,_that.position,_that.company,_that.location,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String position,  String company,  String location,  CvDateRange period,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvExperience() when $default != null:
return $default(_that.id,_that.position,_that.company,_that.location,_that.period,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvExperience implements CvExperience {
  const _CvExperience({required this.id, this.position = '', this.company = '', this.location = '', this.period = const CvDateRange(), this.description = ''});
  factory _CvExperience.fromJson(Map<String, dynamic> json) => _$CvExperienceFromJson(json);

@override final  String id;
@override@JsonKey() final  String position;
@override@JsonKey() final  String company;
@override@JsonKey() final  String location;
@override@JsonKey() final  CvDateRange period;
@override@JsonKey() final  String description;

/// Create a copy of CvExperience
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvExperienceCopyWith<_CvExperience> get copyWith => __$CvExperienceCopyWithImpl<_CvExperience>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvExperienceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvExperience&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,position,company,location,period,description);

@override
String toString() {
  return 'CvExperience(id: $id, position: $position, company: $company, location: $location, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvExperienceCopyWith<$Res> implements $CvExperienceCopyWith<$Res> {
  factory _$CvExperienceCopyWith(_CvExperience value, $Res Function(_CvExperience) _then) = __$CvExperienceCopyWithImpl;
@override @useResult
$Res call({
 String id, String position, String company, String location, CvDateRange period, String description
});


@override $CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$CvExperienceCopyWithImpl<$Res>
    implements _$CvExperienceCopyWith<$Res> {
  __$CvExperienceCopyWithImpl(this._self, this._then);

  final _CvExperience _self;
  final $Res Function(_CvExperience) _then;

/// Create a copy of CvExperience
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? company = null,Object? location = null,Object? period = null,Object? description = null,}) {
  return _then(_CvExperience(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CvExperience
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
