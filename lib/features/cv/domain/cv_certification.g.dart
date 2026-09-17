// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_certification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvCertification _$CvCertificationFromJson(Map<String, dynamic> json) =>
    _CvCertification(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      date: json['date'] == null
          ? null
          : CvMonthYear.fromJson(json['date'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CvCertificationToJson(_CvCertification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'issuer': instance.issuer,
      'date': ?instance.date?.toJson(),
      'description': instance.description,
    };
