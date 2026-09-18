// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvDocument {

 String get id; DateTime get createdAt; DateTime get updatedAt; String get name; CvPersonalInfo get personalInfo; String get profile; List<CvExperience> get experiences; List<CvEducation> get education; List<CvSkill> get skills; List<CvLanguage> get languages; List<CvCertification> get certifications; List<CvProject> get projects; List<CvNote> get interests; List<CvNote> get references;/// Sections créées par l'utilisateur, dans leur ordre de création.
 List<CvCustomSection> get customSections; CvPresentationPreferences get presentation;
/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvDocumentCopyWith<CvDocument> get copyWith => _$CvDocumentCopyWithImpl<CvDocument>(this as CvDocument, _$identity);

  /// Serializes this CvDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.personalInfo, personalInfo) || other.personalInfo == personalInfo)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.experiences, experiences)&&const DeepCollectionEquality().equals(other.education, education)&&const DeepCollectionEquality().equals(other.skills, skills)&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.certifications, certifications)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.references, references)&&const DeepCollectionEquality().equals(other.customSections, customSections)&&(identical(other.presentation, presentation) || other.presentation == presentation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,name,personalInfo,profile,const DeepCollectionEquality().hash(experiences),const DeepCollectionEquality().hash(education),const DeepCollectionEquality().hash(skills),const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(certifications),const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(references),const DeepCollectionEquality().hash(customSections),presentation);

@override
String toString() {
  return 'CvDocument(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, personalInfo: $personalInfo, profile: $profile, experiences: $experiences, education: $education, skills: $skills, languages: $languages, certifications: $certifications, projects: $projects, interests: $interests, references: $references, customSections: $customSections, presentation: $presentation)';
}


}

/// @nodoc
abstract mixin class $CvDocumentCopyWith<$Res>  {
  factory $CvDocumentCopyWith(CvDocument value, $Res Function(CvDocument) _then) = _$CvDocumentCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, String name, CvPersonalInfo personalInfo, String profile, List<CvExperience> experiences, List<CvEducation> education, List<CvSkill> skills, List<CvLanguage> languages, List<CvCertification> certifications, List<CvProject> projects, List<CvNote> interests, List<CvNote> references, List<CvCustomSection> customSections, CvPresentationPreferences presentation
});


$CvPersonalInfoCopyWith<$Res> get personalInfo;$CvPresentationPreferencesCopyWith<$Res> get presentation;

}
/// @nodoc
class _$CvDocumentCopyWithImpl<$Res>
    implements $CvDocumentCopyWith<$Res> {
  _$CvDocumentCopyWithImpl(this._self, this._then);

  final CvDocument _self;
  final $Res Function(CvDocument) _then;

/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? name = null,Object? personalInfo = null,Object? profile = null,Object? experiences = null,Object? education = null,Object? skills = null,Object? languages = null,Object? certifications = null,Object? projects = null,Object? interests = null,Object? references = null,Object? customSections = null,Object? presentation = null,}) {
  return _then(CvDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,personalInfo: null == personalInfo ? _self.personalInfo : personalInfo // ignore: cast_nullable_to_non_nullable
as CvPersonalInfo,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,experiences: null == experiences ? _self.experiences : experiences // ignore: cast_nullable_to_non_nullable
as List<CvExperience>,education: null == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as List<CvEducation>,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<CvSkill>,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<CvLanguage>,certifications: null == certifications ? _self.certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<CvCertification>,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<CvProject>,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<CvNote>,references: null == references ? _self.references : references // ignore: cast_nullable_to_non_nullable
as List<CvNote>,customSections: null == customSections ? _self.customSections : customSections // ignore: cast_nullable_to_non_nullable
as List<CvCustomSection>,presentation: null == presentation ? _self.presentation : presentation // ignore: cast_nullable_to_non_nullable
as CvPresentationPreferences,
  ));
}
/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPersonalInfoCopyWith<$Res> get personalInfo {
  
  return $CvPersonalInfoCopyWith<$Res>(_self.personalInfo, (value) {
    return _then(_self.copyWith(personalInfo: value));
  });
}/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPresentationPreferencesCopyWith<$Res> get presentation {
  
  return $CvPresentationPreferencesCopyWith<$Res>(_self.presentation, (value) {
    return _then(_self.copyWith(presentation: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvDocument].
extension CvDocumentPatterns on CvDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvDocument value)  $default,){
final _that = this;
switch (_that) {
case _CvDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvDocument value)?  $default,){
final _that = this;
switch (_that) {
case _CvDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  String name,  CvPersonalInfo personalInfo,  String profile,  List<CvExperience> experiences,  List<CvEducation> education,  List<CvSkill> skills,  List<CvLanguage> languages,  List<CvCertification> certifications,  List<CvProject> projects,  List<CvNote> interests,  List<CvNote> references,  List<CvCustomSection> customSections,  CvPresentationPreferences presentation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvDocument() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.name,_that.personalInfo,_that.profile,_that.experiences,_that.education,_that.skills,_that.languages,_that.certifications,_that.projects,_that.interests,_that.references,_that.customSections,_that.presentation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  String name,  CvPersonalInfo personalInfo,  String profile,  List<CvExperience> experiences,  List<CvEducation> education,  List<CvSkill> skills,  List<CvLanguage> languages,  List<CvCertification> certifications,  List<CvProject> projects,  List<CvNote> interests,  List<CvNote> references,  List<CvCustomSection> customSections,  CvPresentationPreferences presentation)  $default,) {final _that = this;
switch (_that) {
case _CvDocument():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.name,_that.personalInfo,_that.profile,_that.experiences,_that.education,_that.skills,_that.languages,_that.certifications,_that.projects,_that.interests,_that.references,_that.customSections,_that.presentation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime updatedAt,  String name,  CvPersonalInfo personalInfo,  String profile,  List<CvExperience> experiences,  List<CvEducation> education,  List<CvSkill> skills,  List<CvLanguage> languages,  List<CvCertification> certifications,  List<CvProject> projects,  List<CvNote> interests,  List<CvNote> references,  List<CvCustomSection> customSections,  CvPresentationPreferences presentation)?  $default,) {final _that = this;
switch (_that) {
case _CvDocument() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.name,_that.personalInfo,_that.profile,_that.experiences,_that.education,_that.skills,_that.languages,_that.certifications,_that.projects,_that.interests,_that.references,_that.customSections,_that.presentation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvDocument extends CvDocument {
  const _CvDocument({required this.id, required this.createdAt, required this.updatedAt, this.name = '', this.personalInfo = const CvPersonalInfo(), this.profile = '',  List<CvExperience> experiences = const <CvExperience>[],  List<CvEducation> education = const <CvEducation>[],  List<CvSkill> skills = const <CvSkill>[],  List<CvLanguage> languages = const <CvLanguage>[],  List<CvCertification> certifications = const <CvCertification>[],  List<CvProject> projects = const <CvProject>[],  List<CvNote> interests = const <CvNote>[],  List<CvNote> references = const <CvNote>[],  List<CvCustomSection> customSections = const <CvCustomSection>[], this.presentation = const CvPresentationPreferences()}): _experiences = experiences,_education = education,_skills = skills,_languages = languages,_certifications = certifications,_projects = projects,_interests = interests,_references = references,_customSections = customSections,super._();
  factory _CvDocument.fromJson(Map<String, dynamic> json) => _$CvDocumentFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  String name;
@override@JsonKey() final  CvPersonalInfo personalInfo;
@override@JsonKey() final  String profile;
 final  List<CvExperience> _experiences;
@override@JsonKey() List<CvExperience> get experiences {
  if (_experiences is EqualUnmodifiableListView) return _experiences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_experiences);
}

 final  List<CvEducation> _education;
@override@JsonKey() List<CvEducation> get education {
  if (_education is EqualUnmodifiableListView) return _education;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_education);
}

 final  List<CvSkill> _skills;
@override@JsonKey() List<CvSkill> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}

 final  List<CvLanguage> _languages;
@override@JsonKey() List<CvLanguage> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

 final  List<CvCertification> _certifications;
@override@JsonKey() List<CvCertification> get certifications {
  if (_certifications is EqualUnmodifiableListView) return _certifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certifications);
}

 final  List<CvProject> _projects;
@override@JsonKey() List<CvProject> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<CvNote> _interests;
@override@JsonKey() List<CvNote> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<CvNote> _references;
@override@JsonKey() List<CvNote> get references {
  if (_references is EqualUnmodifiableListView) return _references;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_references);
}

/// Sections créées par l'utilisateur, dans leur ordre de création.
 final  List<CvCustomSection> _customSections;
/// Sections créées par l'utilisateur, dans leur ordre de création.
@override@JsonKey() List<CvCustomSection> get customSections {
  if (_customSections is EqualUnmodifiableListView) return _customSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customSections);
}

@override@JsonKey() final  CvPresentationPreferences presentation;

/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvDocumentCopyWith<_CvDocument> get copyWith => __$CvDocumentCopyWithImpl<_CvDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.personalInfo, personalInfo) || other.personalInfo == personalInfo)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._experiences, _experiences)&&const DeepCollectionEquality().equals(other._education, _education)&&const DeepCollectionEquality().equals(other._skills, _skills)&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._certifications, _certifications)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._references, _references)&&const DeepCollectionEquality().equals(other._customSections, _customSections)&&(identical(other.presentation, presentation) || other.presentation == presentation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,name,personalInfo,profile,const DeepCollectionEquality().hash(_experiences),const DeepCollectionEquality().hash(_education),const DeepCollectionEquality().hash(_skills),const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_certifications),const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_references),const DeepCollectionEquality().hash(_customSections),presentation);

@override
String toString() {
  return 'CvDocument(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, name: $name, personalInfo: $personalInfo, profile: $profile, experiences: $experiences, education: $education, skills: $skills, languages: $languages, certifications: $certifications, projects: $projects, interests: $interests, references: $references, customSections: $customSections, presentation: $presentation)';
}


}

/// @nodoc
abstract mixin class _$CvDocumentCopyWith<$Res> implements $CvDocumentCopyWith<$Res> {
  factory _$CvDocumentCopyWith(_CvDocument value, $Res Function(_CvDocument) _then) = __$CvDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, String name, CvPersonalInfo personalInfo, String profile, List<CvExperience> experiences, List<CvEducation> education, List<CvSkill> skills, List<CvLanguage> languages, List<CvCertification> certifications, List<CvProject> projects, List<CvNote> interests, List<CvNote> references, List<CvCustomSection> customSections, CvPresentationPreferences presentation
});


@override $CvPersonalInfoCopyWith<$Res> get personalInfo;@override $CvPresentationPreferencesCopyWith<$Res> get presentation;

}
/// @nodoc
class __$CvDocumentCopyWithImpl<$Res>
    implements _$CvDocumentCopyWith<$Res> {
  __$CvDocumentCopyWithImpl(this._self, this._then);

  final _CvDocument _self;
  final $Res Function(_CvDocument) _then;

/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? name = null,Object? personalInfo = null,Object? profile = null,Object? experiences = null,Object? education = null,Object? skills = null,Object? languages = null,Object? certifications = null,Object? projects = null,Object? interests = null,Object? references = null,Object? customSections = null,Object? presentation = null,}) {
  return _then(_CvDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,personalInfo: null == personalInfo ? _self.personalInfo : personalInfo // ignore: cast_nullable_to_non_nullable
as CvPersonalInfo,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,experiences: null == experiences ? _self._experiences : experiences // ignore: cast_nullable_to_non_nullable
as List<CvExperience>,education: null == education ? _self._education : education // ignore: cast_nullable_to_non_nullable
as List<CvEducation>,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<CvSkill>,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<CvLanguage>,certifications: null == certifications ? _self._certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<CvCertification>,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<CvProject>,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<CvNote>,references: null == references ? _self._references : references // ignore: cast_nullable_to_non_nullable
as List<CvNote>,customSections: null == customSections ? _self._customSections : customSections // ignore: cast_nullable_to_non_nullable
as List<CvCustomSection>,presentation: null == presentation ? _self.presentation : presentation // ignore: cast_nullable_to_non_nullable
as CvPresentationPreferences,
  ));
}

/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPersonalInfoCopyWith<$Res> get personalInfo {
  
  return $CvPersonalInfoCopyWith<$Res>(_self.personalInfo, (value) {
    return _then(_self.copyWith(personalInfo: value));
  });
}/// Create a copy of CvDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CvPresentationPreferencesCopyWith<$Res> get presentation {
  
  return $CvPresentationPreferencesCopyWith<$Res>(_self.presentation, (value) {
    return _then(_self.copyWith(presentation: value));
  });
}
}

// dart format on
