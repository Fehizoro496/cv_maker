// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_presentation_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvPresentationPreferences {

 String get designId; int get accentArgb; bool get showPhoto; List<CvSection> get sectionOrder; List<CvSection> get hiddenSections;
/// Create a copy of CvPresentationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvPresentationPreferencesCopyWith<CvPresentationPreferences> get copyWith => _$CvPresentationPreferencesCopyWithImpl<CvPresentationPreferences>(this as CvPresentationPreferences, _$identity);

  /// Serializes this CvPresentationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvPresentationPreferences&&(identical(other.designId, designId) || other.designId == designId)&&(identical(other.accentArgb, accentArgb) || other.accentArgb == accentArgb)&&(identical(other.showPhoto, showPhoto) || other.showPhoto == showPhoto)&&const DeepCollectionEquality().equals(other.sectionOrder, sectionOrder)&&const DeepCollectionEquality().equals(other.hiddenSections, hiddenSections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,designId,accentArgb,showPhoto,const DeepCollectionEquality().hash(sectionOrder),const DeepCollectionEquality().hash(hiddenSections));

@override
String toString() {
  return 'CvPresentationPreferences(designId: $designId, accentArgb: $accentArgb, showPhoto: $showPhoto, sectionOrder: $sectionOrder, hiddenSections: $hiddenSections)';
}


}

/// @nodoc
abstract mixin class $CvPresentationPreferencesCopyWith<$Res>  {
  factory $CvPresentationPreferencesCopyWith(CvPresentationPreferences value, $Res Function(CvPresentationPreferences) _then) = _$CvPresentationPreferencesCopyWithImpl;
@useResult
$Res call({
 String designId, int accentArgb, bool showPhoto, List<CvSection> sectionOrder, List<CvSection> hiddenSections
});




}
/// @nodoc
class _$CvPresentationPreferencesCopyWithImpl<$Res>
    implements $CvPresentationPreferencesCopyWith<$Res> {
  _$CvPresentationPreferencesCopyWithImpl(this._self, this._then);

  final CvPresentationPreferences _self;
  final $Res Function(CvPresentationPreferences) _then;

/// Create a copy of CvPresentationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? designId = null,Object? accentArgb = null,Object? showPhoto = null,Object? sectionOrder = null,Object? hiddenSections = null,}) {
  return _then(CvPresentationPreferences(
designId: null == designId ? _self.designId : designId // ignore: cast_nullable_to_non_nullable
as String,accentArgb: null == accentArgb ? _self.accentArgb : accentArgb // ignore: cast_nullable_to_non_nullable
as int,showPhoto: null == showPhoto ? _self.showPhoto : showPhoto // ignore: cast_nullable_to_non_nullable
as bool,sectionOrder: null == sectionOrder ? _self.sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSection>,hiddenSections: null == hiddenSections ? _self.hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as List<CvSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [CvPresentationPreferences].
extension CvPresentationPreferencesPatterns on CvPresentationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvPresentationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvPresentationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvPresentationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _CvPresentationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvPresentationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _CvPresentationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String designId,  int accentArgb,  bool showPhoto,  List<CvSection> sectionOrder,  List<CvSection> hiddenSections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvPresentationPreferences() when $default != null:
return $default(_that.designId,_that.accentArgb,_that.showPhoto,_that.sectionOrder,_that.hiddenSections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String designId,  int accentArgb,  bool showPhoto,  List<CvSection> sectionOrder,  List<CvSection> hiddenSections)  $default,) {final _that = this;
switch (_that) {
case _CvPresentationPreferences():
return $default(_that.designId,_that.accentArgb,_that.showPhoto,_that.sectionOrder,_that.hiddenSections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String designId,  int accentArgb,  bool showPhoto,  List<CvSection> sectionOrder,  List<CvSection> hiddenSections)?  $default,) {final _that = this;
switch (_that) {
case _CvPresentationPreferences() when $default != null:
return $default(_that.designId,_that.accentArgb,_that.showPhoto,_that.sectionOrder,_that.hiddenSections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvPresentationPreferences extends CvPresentationPreferences {
  const _CvPresentationPreferences({this.designId = 'classic', this.accentArgb = CvAccent.defaultColor, this.showPhoto = true,  List<CvSection> sectionOrder = const <CvSection>[],  List<CvSection> hiddenSections = const <CvSection>[]}): _sectionOrder = sectionOrder,_hiddenSections = hiddenSections,super._();
  factory _CvPresentationPreferences.fromJson(Map<String, dynamic> json) => _$CvPresentationPreferencesFromJson(json);

@override@JsonKey() final  String designId;
@override@JsonKey() final  int accentArgb;
@override@JsonKey() final  bool showPhoto;
 final  List<CvSection> _sectionOrder;
@override@JsonKey() List<CvSection> get sectionOrder {
  if (_sectionOrder is EqualUnmodifiableListView) return _sectionOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sectionOrder);
}

 final  List<CvSection> _hiddenSections;
@override@JsonKey() List<CvSection> get hiddenSections {
  if (_hiddenSections is EqualUnmodifiableListView) return _hiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hiddenSections);
}


/// Create a copy of CvPresentationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvPresentationPreferencesCopyWith<_CvPresentationPreferences> get copyWith => __$CvPresentationPreferencesCopyWithImpl<_CvPresentationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvPresentationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvPresentationPreferences&&(identical(other.designId, designId) || other.designId == designId)&&(identical(other.accentArgb, accentArgb) || other.accentArgb == accentArgb)&&(identical(other.showPhoto, showPhoto) || other.showPhoto == showPhoto)&&const DeepCollectionEquality().equals(other._sectionOrder, _sectionOrder)&&const DeepCollectionEquality().equals(other._hiddenSections, _hiddenSections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,designId,accentArgb,showPhoto,const DeepCollectionEquality().hash(_sectionOrder),const DeepCollectionEquality().hash(_hiddenSections));

@override
String toString() {
  return 'CvPresentationPreferences(designId: $designId, accentArgb: $accentArgb, showPhoto: $showPhoto, sectionOrder: $sectionOrder, hiddenSections: $hiddenSections)';
}


}

/// @nodoc
abstract mixin class _$CvPresentationPreferencesCopyWith<$Res> implements $CvPresentationPreferencesCopyWith<$Res> {
  factory _$CvPresentationPreferencesCopyWith(_CvPresentationPreferences value, $Res Function(_CvPresentationPreferences) _then) = __$CvPresentationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String designId, int accentArgb, bool showPhoto, List<CvSection> sectionOrder, List<CvSection> hiddenSections
});




}
/// @nodoc
class __$CvPresentationPreferencesCopyWithImpl<$Res>
    implements _$CvPresentationPreferencesCopyWith<$Res> {
  __$CvPresentationPreferencesCopyWithImpl(this._self, this._then);

  final _CvPresentationPreferences _self;
  final $Res Function(_CvPresentationPreferences) _then;

/// Create a copy of CvPresentationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? designId = null,Object? accentArgb = null,Object? showPhoto = null,Object? sectionOrder = null,Object? hiddenSections = null,}) {
  return _then(_CvPresentationPreferences(
designId: null == designId ? _self.designId : designId // ignore: cast_nullable_to_non_nullable
as String,accentArgb: null == accentArgb ? _self.accentArgb : accentArgb // ignore: cast_nullable_to_non_nullable
as int,showPhoto: null == showPhoto ? _self.showPhoto : showPhoto // ignore: cast_nullable_to_non_nullable
as bool,sectionOrder: null == sectionOrder ? _self._sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSection>,hiddenSections: null == hiddenSections ? _self._hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as List<CvSection>,
  ));
}


}

// dart format on
