// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_date_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvDateRange {

 CvMonthYear? get start; CvMonthYear? get end; bool get isCurrent;
/// Create a copy of CvDateRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<CvDateRange> get copyWith => _$CvDateRangeCopyWithImpl<CvDateRange>(this as CvDateRange, _$identity);

  /// Serializes this CvDateRange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvDateRange&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCurrent);

@override
String toString() {
  return 'CvDateRange(start: $start, end: $end, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $CvDateRangeCopyWith<$Res>  {
  factory $CvDateRangeCopyWith(CvDateRange value, $Res Function(CvDateRange) _then) = _$CvDateRangeCopyWithImpl;
@useResult
$Res call({
 CvMonthYear? start, CvMonthYear? end, bool isCurrent
});




}
/// @nodoc
class _$CvDateRangeCopyWithImpl<$Res>
    implements $CvDateRangeCopyWith<$Res> {
  _$CvDateRangeCopyWithImpl(this._self, this._then);

  final CvDateRange _self;
  final $Res Function(CvDateRange) _then;

/// Create a copy of CvDateRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = freezed,Object? end = freezed,Object? isCurrent = null,}) {
  return _then(CvDateRange(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CvDateRange].
extension CvDateRangePatterns on CvDateRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvDateRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvDateRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvDateRange value)  $default,){
final _that = this;
switch (_that) {
case _CvDateRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvDateRange value)?  $default,){
final _that = this;
switch (_that) {
case _CvDateRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CvMonthYear? start,  CvMonthYear? end,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvDateRange() when $default != null:
return $default(_that.start,_that.end,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CvMonthYear? start,  CvMonthYear? end,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _CvDateRange():
return $default(_that.start,_that.end,_that.isCurrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CvMonthYear? start,  CvMonthYear? end,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _CvDateRange() when $default != null:
return $default(_that.start,_that.end,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvDateRange extends CvDateRange {
  const _CvDateRange({this.start, this.end, this.isCurrent = false}): super._();
  factory _CvDateRange.fromJson(Map<String, dynamic> json) => _$CvDateRangeFromJson(json);

@override final  CvMonthYear? start;
@override final  CvMonthYear? end;
@override@JsonKey() final  bool isCurrent;

/// Create a copy of CvDateRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvDateRangeCopyWith<_CvDateRange> get copyWith => __$CvDateRangeCopyWithImpl<_CvDateRange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvDateRangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvDateRange&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCurrent);

@override
String toString() {
  return 'CvDateRange(start: $start, end: $end, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$CvDateRangeCopyWith<$Res> implements $CvDateRangeCopyWith<$Res> {
  factory _$CvDateRangeCopyWith(_CvDateRange value, $Res Function(_CvDateRange) _then) = __$CvDateRangeCopyWithImpl;
@override @useResult
$Res call({
 CvMonthYear? start, CvMonthYear? end, bool isCurrent
});




}
/// @nodoc
class __$CvDateRangeCopyWithImpl<$Res>
    implements _$CvDateRangeCopyWith<$Res> {
  __$CvDateRangeCopyWithImpl(this._self, this._then);

  final _CvDateRange _self;
  final $Res Function(_CvDateRange) _then;

/// Create a copy of CvDateRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = freezed,Object? end = freezed,Object? isCurrent = null,}) {
  return _then(_CvDateRange(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as CvMonthYear?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
