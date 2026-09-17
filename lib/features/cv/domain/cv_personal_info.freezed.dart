// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_personal_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvLink {

 String get id; String get label; String get url;
/// Create a copy of CvLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvLinkCopyWith<CvLink> get copyWith => _$CvLinkCopyWithImpl<CvLink>(this as CvLink, _$identity);

  /// Serializes this CvLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvLink&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,url);

@override
String toString() {
  return 'CvLink(id: $id, label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $CvLinkCopyWith<$Res>  {
  factory $CvLinkCopyWith(CvLink value, $Res Function(CvLink) _then) = _$CvLinkCopyWithImpl;
@useResult
$Res call({
 String id, String label, String url
});




}
/// @nodoc
class _$CvLinkCopyWithImpl<$Res>
    implements $CvLinkCopyWith<$Res> {
  _$CvLinkCopyWithImpl(this._self, this._then);

  final CvLink _self;
  final $Res Function(CvLink) _then;

/// Create a copy of CvLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? url = null,}) {
  return _then(CvLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CvLink].
extension CvLinkPatterns on CvLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvLink value)  $default,){
final _that = this;
switch (_that) {
case _CvLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvLink value)?  $default,){
final _that = this;
switch (_that) {
case _CvLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvLink() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String url)  $default,) {final _that = this;
switch (_that) {
case _CvLink():
return $default(_that.id,_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CvLink() when $default != null:
return $default(_that.id,_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvLink implements CvLink {
  const _CvLink({required this.id, this.label = '', this.url = ''});
  factory _CvLink.fromJson(Map<String, dynamic> json) => _$CvLinkFromJson(json);

@override final  String id;
@override@JsonKey() final  String label;
@override@JsonKey() final  String url;

/// Create a copy of CvLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvLinkCopyWith<_CvLink> get copyWith => __$CvLinkCopyWithImpl<_CvLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvLink&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,url);

@override
String toString() {
  return 'CvLink(id: $id, label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CvLinkCopyWith<$Res> implements $CvLinkCopyWith<$Res> {
  factory _$CvLinkCopyWith(_CvLink value, $Res Function(_CvLink) _then) = __$CvLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String url
});




}
/// @nodoc
class __$CvLinkCopyWithImpl<$Res>
    implements _$CvLinkCopyWith<$Res> {
  __$CvLinkCopyWithImpl(this._self, this._then);

  final _CvLink _self;
  final $Res Function(_CvLink) _then;

/// Create a copy of CvLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? url = null,}) {
  return _then(_CvLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CvPersonalInfo {

 String get firstName; String get lastName; String get headline; String get location; String get phone; String get email; String get website; List<CvLink> get links;
/// Create a copy of CvPersonalInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvPersonalInfoCopyWith<CvPersonalInfo> get copyWith => _$CvPersonalInfoCopyWithImpl<CvPersonalInfo>(this as CvPersonalInfo, _$identity);

  /// Serializes this CvPersonalInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvPersonalInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.location, location) || other.location == location)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other.links, links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,headline,location,phone,email,website,const DeepCollectionEquality().hash(links));

@override
String toString() {
  return 'CvPersonalInfo(firstName: $firstName, lastName: $lastName, headline: $headline, location: $location, phone: $phone, email: $email, website: $website, links: $links)';
}


}

/// @nodoc
abstract mixin class $CvPersonalInfoCopyWith<$Res>  {
  factory $CvPersonalInfoCopyWith(CvPersonalInfo value, $Res Function(CvPersonalInfo) _then) = _$CvPersonalInfoCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, String headline, String location, String phone, String email, String website, List<CvLink> links
});




}
/// @nodoc
class _$CvPersonalInfoCopyWithImpl<$Res>
    implements $CvPersonalInfoCopyWith<$Res> {
  _$CvPersonalInfoCopyWithImpl(this._self, this._then);

  final CvPersonalInfo _self;
  final $Res Function(CvPersonalInfo) _then;

/// Create a copy of CvPersonalInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? headline = null,Object? location = null,Object? phone = null,Object? email = null,Object? website = null,Object? links = null,}) {
  return _then(CvPersonalInfo(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: null == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<CvLink>,
  ));
}

}


/// Adds pattern-matching-related methods to [CvPersonalInfo].
extension CvPersonalInfoPatterns on CvPersonalInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvPersonalInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvPersonalInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvPersonalInfo value)  $default,){
final _that = this;
switch (_that) {
case _CvPersonalInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvPersonalInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CvPersonalInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String headline,  String location,  String phone,  String email,  String website,  List<CvLink> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvPersonalInfo() when $default != null:
return $default(_that.firstName,_that.lastName,_that.headline,_that.location,_that.phone,_that.email,_that.website,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String headline,  String location,  String phone,  String email,  String website,  List<CvLink> links)  $default,) {final _that = this;
switch (_that) {
case _CvPersonalInfo():
return $default(_that.firstName,_that.lastName,_that.headline,_that.location,_that.phone,_that.email,_that.website,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String lastName,  String headline,  String location,  String phone,  String email,  String website,  List<CvLink> links)?  $default,) {final _that = this;
switch (_that) {
case _CvPersonalInfo() when $default != null:
return $default(_that.firstName,_that.lastName,_that.headline,_that.location,_that.phone,_that.email,_that.website,_that.links);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvPersonalInfo extends CvPersonalInfo {
  const _CvPersonalInfo({this.firstName = '', this.lastName = '', this.headline = '', this.location = '', this.phone = '', this.email = '', this.website = '',  List<CvLink> links = const <CvLink>[]}): _links = links,super._();
  factory _CvPersonalInfo.fromJson(Map<String, dynamic> json) => _$CvPersonalInfoFromJson(json);

@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String headline;
@override@JsonKey() final  String location;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String website;
 final  List<CvLink> _links;
@override@JsonKey() List<CvLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of CvPersonalInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvPersonalInfoCopyWith<_CvPersonalInfo> get copyWith => __$CvPersonalInfoCopyWithImpl<_CvPersonalInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvPersonalInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvPersonalInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.location, location) || other.location == location)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other._links, _links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,headline,location,phone,email,website,const DeepCollectionEquality().hash(_links));

@override
String toString() {
  return 'CvPersonalInfo(firstName: $firstName, lastName: $lastName, headline: $headline, location: $location, phone: $phone, email: $email, website: $website, links: $links)';
}


}

/// @nodoc
abstract mixin class _$CvPersonalInfoCopyWith<$Res> implements $CvPersonalInfoCopyWith<$Res> {
  factory _$CvPersonalInfoCopyWith(_CvPersonalInfo value, $Res Function(_CvPersonalInfo) _then) = __$CvPersonalInfoCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String lastName, String headline, String location, String phone, String email, String website, List<CvLink> links
});




}
/// @nodoc
class __$CvPersonalInfoCopyWithImpl<$Res>
    implements _$CvPersonalInfoCopyWith<$Res> {
  __$CvPersonalInfoCopyWithImpl(this._self, this._then);

  final _CvPersonalInfo _self;
  final $Res Function(_CvPersonalInfo) _then;

/// Create a copy of CvPersonalInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? headline = null,Object? location = null,Object? phone = null,Object? email = null,Object? website = null,Object? links = null,}) {
  return _then(_CvPersonalInfo(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,website: null == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<CvLink>,
  ));
}


}

// dart format on
