// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_education.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvEducation _$CvEducationFromJson(Map<String, dynamic> json) => _CvEducation(
  id: json['id'] as String,
  degree: json['degree'] as String? ?? '',
  school: json['school'] as String? ?? '',
  location: json['location'] as String? ?? '',
  period: json['period'] == null
      ? const CvDateRange()
      : CvDateRange.fromJson(json['period'] as Map<String, dynamic>),
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$CvEducationToJson(_CvEducation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'degree': instance.degree,
      'school': instance.school,
      'location': instance.location,
      'period': instance.period.toJson(),
      'description': instance.description,
    };
