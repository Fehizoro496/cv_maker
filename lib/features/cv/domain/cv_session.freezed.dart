// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CvSession {

 CvDocument get document;/// Photo choisie pendant la session, absente après un redémarrage.
///
/// L'égalité de [CvSession] compare les photos par référence : une même
/// image rechargée depuis le disque produit une session différente. C'est
/// suffisant pour l'historique, qui empile les états tels qu'ils ont été
/// produits.
 Uint8List? get photo;
/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvSessionCopyWith<CvSession> get copyWith => _$CvSessionCopyWithImpl<CvSession>(this as CvSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvSession&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.photo, photo));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(photo));

@override
String toString() {
  return 'CvSession(document: $document, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $CvSessionCopyWith<$Res>  {
  factory $CvSessionCopyWith(CvSession value, $Res Function(CvSession) _then) = _$CvSessionCopyWithImpl;
@useResult
$Res call({
 CvDocument document, Uint8List? photo
});


$CvDocumentCopyWith<$Res> get document;

}
/// @nodoc
class _$CvSessionCopyWithImpl<$Res>
    implements $CvSessionCopyWith<$Res> {
  _$CvSessionCopyWithImpl(this._self, this._then);

  final CvSession _self;
  final $Res Function(CvSession) _then;

/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? photo = freezed,}) {
  return _then(CvSession(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as CvDocument,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as Uint8List?,
  ));
}
/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDocumentCopyWith<$Res> get document {
  
  return $CvDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvSession].
extension CvSessionPatterns on CvSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvSession value)  $default,){
final _that = this;
switch (_that) {
case _CvSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvSession value)?  $default,){
final _that = this;
switch (_that) {
case _CvSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CvDocument document,  Uint8List? photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvSession() when $default != null:
return $default(_that.document,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CvDocument document,  Uint8List? photo)  $default,) {final _that = this;
switch (_that) {
case _CvSession():
return $default(_that.document,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CvDocument document,  Uint8List? photo)?  $default,) {final _that = this;
switch (_that) {
case _CvSession() when $default != null:
return $default(_that.document,_that.photo);case _:
  return null;

}
}

}

/// @nodoc


class _CvSession extends CvSession {
  const _CvSession({required this.document, this.photo}): super._();
  

@override final  CvDocument document;
/// Photo choisie pendant la session, absente après un redémarrage.
///
/// L'égalité de [CvSession] compare les photos par référence : une même
/// image rechargée depuis le disque produit une session différente. C'est
/// suffisant pour l'historique, qui empile les états tels qu'ils ont été
/// produits.
@override final  Uint8List? photo;

/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvSessionCopyWith<_CvSession> get copyWith => __$CvSessionCopyWithImpl<_CvSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvSession&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.photo, photo));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(photo));

@override
String toString() {
  return 'CvSession(document: $document, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$CvSessionCopyWith<$Res> implements $CvSessionCopyWith<$Res> {
  factory _$CvSessionCopyWith(_CvSession value, $Res Function(_CvSession) _then) = __$CvSessionCopyWithImpl;
@override @useResult
$Res call({
 CvDocument document, Uint8List? photo
});


@override $CvDocumentCopyWith<$Res> get document;

}
/// @nodoc
class __$CvSessionCopyWithImpl<$Res>
    implements _$CvSessionCopyWith<$Res> {
  __$CvSessionCopyWithImpl(this._self, this._then);

  final _CvSession _self;
  final $Res Function(_CvSession) _then;

/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? photo = freezed,}) {
  return _then(_CvSession(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as CvDocument,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as Uint8List?,
  ));
}

/// Create a copy of CvSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvDocumentCopyWith<$Res> get document {
  
  return $CvDocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

// dart format on
