// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_custom_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvCustomItem {

 String get id; String get title; String get subtitle; CvDateRange get period; String get description;
/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvCustomItemCopyWith<CvCustomItem> get copyWith => _$CvCustomItemCopyWithImpl<CvCustomItem>(this as CvCustomItem, _$identity);

  /// Serializes this CvCustomItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvCustomItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,period,description);

@override
String toString() {
  return 'CvCustomItem(id: $id, title: $title, subtitle: $subtitle, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class $CvCustomItemCopyWith<$Res>  {
  factory $CvCustomItemCopyWith(CvCustomItem value, $Res Function(CvCustomItem) _then) = _$CvCustomItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, CvDateRange period, String description
});


$CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class _$CvCustomItemCopyWithImpl<$Res>
    implements $CvCustomItemCopyWith<$Res> {
  _$CvCustomItemCopyWithImpl(this._self, this._then);

  final CvCustomItem _self;
  final $Res Function(CvCustomItem) _then;

/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? period = null,Object? description = null,}) {
  return _then(CvCustomItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvCustomItem].
extension CvCustomItemPatterns on CvCustomItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvCustomItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvCustomItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvCustomItem value)  $default,){
final _that = this;
switch (_that) {
case _CvCustomItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvCustomItem value)?  $default,){
final _that = this;
switch (_that) {
case _CvCustomItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  CvDateRange period,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvCustomItem() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  CvDateRange period,  String description)  $default,) {final _that = this;
switch (_that) {
case _CvCustomItem():
return $default(_that.id,_that.title,_that.subtitle,_that.period,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  CvDateRange period,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CvCustomItem() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.period,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvCustomItem implements CvCustomItem {
  const _CvCustomItem({required this.id, this.title = '', this.subtitle = '', this.period = const CvDateRange(), this.description = ''});
  factory _CvCustomItem.fromJson(Map<String, dynamic> json) => _$CvCustomItemFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  CvDateRange period;
@override@JsonKey() final  String description;

/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvCustomItemCopyWith<_CvCustomItem> get copyWith => __$CvCustomItemCopyWithImpl<_CvCustomItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvCustomItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvCustomItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.period, period) || other.period == period)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,period,description);

@override
String toString() {
  return 'CvCustomItem(id: $id, title: $title, subtitle: $subtitle, period: $period, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CvCustomItemCopyWith<$Res> implements $CvCustomItemCopyWith<$Res> {
  factory _$CvCustomItemCopyWith(_CvCustomItem value, $Res Function(_CvCustomItem) _then) = __$CvCustomItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, CvDateRange period, String description
});


@override $CvDateRangeCopyWith<$Res> get period;

}
/// @nodoc
class __$CvCustomItemCopyWithImpl<$Res>
    implements _$CvCustomItemCopyWith<$Res> {
  __$CvCustomItemCopyWithImpl(this._self, this._then);

  final _CvCustomItem _self;
  final $Res Function(_CvCustomItem) _then;

/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? period = null,Object? description = null,}) {
  return _then(_CvCustomItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as CvDateRange,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CvCustomItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDateRangeCopyWith<$Res> get period {
  
  return $CvDateRangeCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// @nodoc
mixin _$CvCustomSection {

 String get id; String get name; CvCustomSectionType get type; bool get visible; String get text; List<CvCustomItem> get items;
/// Create a copy of CvCustomSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvCustomSectionCopyWith<CvCustomSection> get copyWith => _$CvCustomSectionCopyWithImpl<CvCustomSection>(this as CvCustomSection, _$identity);

  /// Serializes this CvCustomSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvCustomSection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,visible,text,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CvCustomSection(id: $id, name: $name, type: $type, visible: $visible, text: $text, items: $items)';
}


}

/// @nodoc
abstract mixin class $CvCustomSectionCopyWith<$Res>  {
  factory $CvCustomSectionCopyWith(CvCustomSection value, $Res Function(CvCustomSection) _then) = _$CvCustomSectionCopyWithImpl;
@useResult
$Res call({
 String id, String name, CvCustomSectionType type, bool visible, String text, List<CvCustomItem> items
});




}
/// @nodoc
class _$CvCustomSectionCopyWithImpl<$Res>
    implements $CvCustomSectionCopyWith<$Res> {
  _$CvCustomSectionCopyWithImpl(this._self, this._then);

  final CvCustomSection _self;
  final $Res Function(CvCustomSection) _then;

/// Create a copy of CvCustomSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? visible = null,Object? text = null,Object? items = null,}) {
  return _then(CvCustomSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CvCustomSectionType,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CvCustomItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CvCustomSection].
extension CvCustomSectionPatterns on CvCustomSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvCustomSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvCustomSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvCustomSection value)  $default,){
final _that = this;
switch (_that) {
case _CvCustomSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvCustomSection value)?  $default,){
final _that = this;
switch (_that) {
case _CvCustomSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  CvCustomSectionType type,  bool visible,  String text,  List<CvCustomItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvCustomSection() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.visible,_that.text,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  CvCustomSectionType type,  bool visible,  String text,  List<CvCustomItem> items)  $default,) {final _that = this;
switch (_that) {
case _CvCustomSection():
return $default(_that.id,_that.name,_that.type,_that.visible,_that.text,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  CvCustomSectionType type,  bool visible,  String text,  List<CvCustomItem> items)?  $default,) {final _that = this;
switch (_that) {
case _CvCustomSection() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.visible,_that.text,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvCustomSection extends CvCustomSection {
  const _CvCustomSection({required this.id, required this.name, required this.type, this.visible = true, this.text = '',  List<CvCustomItem> items = const <CvCustomItem>[]}): _items = items,super._();
  factory _CvCustomSection.fromJson(Map<String, dynamic> json) => _$CvCustomSectionFromJson(json);

@override final  String id;
@override final  String name;
@override final  CvCustomSectionType type;
@override@JsonKey() final  bool visible;
@override@JsonKey() final  String text;
 final  List<CvCustomItem> _items;
@override@JsonKey() List<CvCustomItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of CvCustomSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvCustomSectionCopyWith<_CvCustomSection> get copyWith => __$CvCustomSectionCopyWithImpl<_CvCustomSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvCustomSectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvCustomSection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,visible,text,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'CvCustomSection(id: $id, name: $name, type: $type, visible: $visible, text: $text, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CvCustomSectionCopyWith<$Res> implements $CvCustomSectionCopyWith<$Res> {
  factory _$CvCustomSectionCopyWith(_CvCustomSection value, $Res Function(_CvCustomSection) _then) = __$CvCustomSectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, CvCustomSectionType type, bool visible, String text, List<CvCustomItem> items
});




}
/// @nodoc
class __$CvCustomSectionCopyWithImpl<$Res>
    implements _$CvCustomSectionCopyWith<$Res> {
  __$CvCustomSectionCopyWithImpl(this._self, this._then);

  final _CvCustomSection _self;
  final $Res Function(_CvCustomSection) _then;

/// Create a copy of CvCustomSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? visible = null,Object? text = null,Object? items = null,}) {
  return _then(_CvCustomSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CvCustomSectionType,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CvCustomItem>,
  ));
}


}

// dart format on
