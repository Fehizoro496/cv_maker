// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvProject _$CvProjectFromJson(Map<String, dynamic> json) => _CvProject(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  role: json['role'] as String? ?? '',
  url: json['url'] as String? ?? '',
  period: json['period'] == null
      ? const CvDateRange()
      : CvDateRange.fromJson(json['period'] as Map<String, dynamic>),
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$CvProjectToJson(_CvProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'url': instance.url,
      'period': instance.period.toJson(),
      'description': instance.description,
    };
