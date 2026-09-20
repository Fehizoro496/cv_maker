// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvDocument _$CvDocumentFromJson(Map<String, dynamic> json) => _CvDocument(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String? ?? '',
  personalInfo: json['personalInfo'] == null
      ? const CvPersonalInfo()
      : CvPersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
  profile: json['profile'] as String? ?? '',
  experiences:
      (json['experiences'] as List<dynamic>?)
          ?.map((e) => CvExperience.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvExperience>[],
  education:
      (json['education'] as List<dynamic>?)
          ?.map((e) => CvEducation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvEducation>[],
  skills:
      (json['skills'] as List<dynamic>?)
          ?.map((e) => CvSkill.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvSkill>[],
  languages:
      (json['languages'] as List<dynamic>?)
          ?.map((e) => CvLanguage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvLanguage>[],
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => CvCertification.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvCertification>[],
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => CvProject.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvProject>[],
  interests:
      (json['interests'] as List<dynamic>?)
          ?.map((e) => CvNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvNote>[],
  references:
      (json['references'] as List<dynamic>?)
          ?.map((e) => CvNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvNote>[],
  customSections:
      (json['customSections'] as List<dynamic>?)
          ?.map((e) => CvCustomSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvCustomSection>[],
  presentation: json['presentation'] == null
      ? const CvPresentationPreferences()
      : CvPresentationPreferences.fromJson(
          json['presentation'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CvDocumentToJson(_CvDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'personalInfo': instance.personalInfo.toJson(),
      'profile': instance.profile,
      'experiences': instance.experiences.map((e) => e.toJson()).toList(),
      'education': instance.education.map((e) => e.toJson()).toList(),
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'languages': instance.languages.map((e) => e.toJson()).toList(),
      'certifications': instance.certifications.map((e) => e.toJson()).toList(),
      'projects': instance.projects.map((e) => e.toJson()).toList(),
      'interests': instance.interests.map((e) => e.toJson()).toList(),
      'references': instance.references.map((e) => e.toJson()).toList(),
      'customSections': instance.customSections.map((e) => e.toJson()).toList(),
      'presentation': instance.presentation.toJson(),
    };
