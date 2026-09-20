// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvProject {

 String get id; String get name; String get role; String get url; CvDateRange get period; String get description;
/// Create a copy of CvProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvProjectCopyWith<CvProject> get copyWith => _$CvProjectCopyWithImpl<CvProject>(this as CvProject, _$identity);

  /// Serializes this CvProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvProject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.url, url) || other.url == url)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,url,period,description);

@override
String toString() {
  return 'CvProject(id: $id, name: $name, role: $role, url: $url, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvProjectCopyWith<$Res>  {
  factory $CvProjectCopyWith(CvProject value, $Res Function(CvProject) _then) = _$CvProjectCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, String url, CvDateRange period, String description
});


$CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$CvProjectCopyWithImpl<$Res>
    implements $CvProjectCopyWith<$Res> {
  _$CvProjectCopyWithImpl(this._self, this._then);

  final CvProject _self;
  final $Res Function(CvProject) _then;

/// Create a copy of CvProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? url = null,Object? period = null,Object? description = null,}) {
  return _then(CvProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CvProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvProject].
extension CvProjectPatterns on CvProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvProject value)  $default,){
final _that = this;
switch (_that) {
case _CvProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvProject value)?  $default,){
final _that = this;
switch (_that) {
case _CvProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String url,  CvDateRange period,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvProject() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.url,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String url,  CvDateRange period,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvProject():
return $default(_that.id,_that.name,_that.role,_that.url,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  String url,  CvDateRange period,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvProject() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.url,_that.period,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvProject implements CvProject {
  const _CvProject({required this.id, this.name = '', this.role = '', this.url = '', this.period = const CvDateRange(), this.description = ''});
  factory _CvProject.fromJson(Map<String, dynamic> json) => _$CvProjectFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String role;
@override@JsonKey() final  String url;
@override@JsonKey() final  CvDateRange period;
@override@JsonKey() final  String description;

/// Create a copy of CvProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvProjectCopyWith<_CvProject> get copyWith => __$CvProjectCopyWithImpl<_CvProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvProject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.url, url) || other.url == url)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,url,period,description);

@override
String toString() {
  return 'CvProject(id: $id, name: $name, role: $role, url: $url, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvProjectCopyWith<$Res> implements $CvProjectCopyWith<$Res> {
  factory _$CvProjectCopyWith(_CvProject value, $Res Function(_CvProject) _then) = __$CvProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, String url, CvDateRange period, String description
});


@override $CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$CvProjectCopyWithImpl<$Res>
    implements _$CvProjectCopyWith<$Res> {
  __$CvProjectCopyWithImpl(this._self, this._then);

  final _CvProject _self;
  final $Res Function(_CvProject) _then;

/// Create a copy of CvProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? url = null,Object? period = null,Object? description = null,}) {
  return _then(_CvProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CvProject
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
