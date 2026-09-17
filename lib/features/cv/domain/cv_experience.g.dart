// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_experience.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvExperience _$CvExperienceFromJson(Map<String, dynamic> json) =>
    _CvExperience(
      id: json['id'] as String,
      position: json['position'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      period: json['period'] == null
          ? const CvDateRange()
          : CvDateRange.fromJson(json['period'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CvExperienceToJson(_CvExperience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'company': instance.company,
      'location': instance.location,
      'period': instance.period.toJson(),
      'description': instance.description,
    };
