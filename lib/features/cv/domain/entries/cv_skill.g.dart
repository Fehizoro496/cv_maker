// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvSkill _$CvSkillFromJson(Map<String, dynamic> json) => _CvSkill(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  category: json['category'] as String? ?? '',
  level: json['level'] as String? ?? '',
);

Map<String, dynamic> _$CvSkillToJson(_CvSkill instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'level': instance.level,
};
