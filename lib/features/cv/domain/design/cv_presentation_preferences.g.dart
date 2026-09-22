// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_presentation_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvPresentationPreferences _$CvPresentationPreferencesFromJson(
  Map<String, dynamic> json,
) => _CvPresentationPreferences(
  designId: json['designId'] as String? ?? 'classic',
  templateSnapshot: json['templateSnapshot'] == null
      ? null
      : CvTemplate.fromJson(json['templateSnapshot'] as Map<String, dynamic>),
  accentArgb: (json['accentArgb'] as num?)?.toInt() ?? CvAccent.defaultColor,
  showPhoto: json['showPhoto'] as bool? ?? true,
  photoShape: $enumDecodeNullable(_$CvPhotoShapeEnumMap, json['photoShape']),
  photoSizeMm: (json['photoSizeMm'] as num?)?.toDouble(),
  sectionOrder:
      (json['sectionOrder'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionEnumMap, e))
          .toList() ??
      const <CvSection>[],
  hiddenSections:
      (json['hiddenSections'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionEnumMap, e))
          .toList() ??
      const <CvSection>[],
);

Map<String, dynamic> _$CvPresentationPreferencesToJson(
  _CvPresentationPreferences instance,
) => <String, dynamic>{
  'designId': instance.designId,
  'templateSnapshot': ?instance.templateSnapshot?.toJson(),
  'accentArgb': instance.accentArgb,
  'showPhoto': instance.showPhoto,
  'photoShape': ?_$CvPhotoShapeEnumMap[instance.photoShape],
  'photoSizeMm': ?instance.photoSizeMm,
  'sectionOrder': instance.sectionOrder
      .map((e) => _$CvSectionEnumMap[e]!)
      .toList(),
  'hiddenSections': instance.hiddenSections
      .map((e) => _$CvSectionEnumMap[e]!)
      .toList(),
};

const _$CvPhotoShapeEnumMap = {
  CvPhotoShape.circle: 'circle',
  CvPhotoShape.rounded: 'rounded',
  CvPhotoShape.square: 'square',
};

const _$CvSectionEnumMap = {
  CvSection.personalInfo: 'personalInfo',
  CvSection.profile: 'profile',
  CvSection.experiences: 'experiences',
  CvSection.education: 'education',
  CvSection.skills: 'skills',
  CvSection.languages: 'languages',
  CvSection.certifications: 'certifications',
  CvSection.projects: 'projects',
  CvSection.interests: 'interests',
  CvSection.references: 'references',
};
