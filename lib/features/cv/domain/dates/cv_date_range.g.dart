// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_date_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvDateRange _$CvDateRangeFromJson(Map<String, dynamic> json) => _CvDateRange(
  start: json['start'] == null
      ? null
      : CvMonthYear.fromJson(json['start'] as Map<String, dynamic>),
  end: json['end'] == null
      ? null
      : CvMonthYear.fromJson(json['end'] as Map<String, dynamic>),
  isCurrent: json['isCurrent'] as bool? ?? false,
);

Map<String, dynamic> _$CvDateRangeToJson(_CvDateRange instance) =>
    <String, dynamic>{
      'start': ?instance.start?.toJson(),
      'end': ?instance.end?.toJson(),
      'isCurrent': instance.isCurrent,
    };
