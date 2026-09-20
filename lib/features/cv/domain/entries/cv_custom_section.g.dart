// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_custom_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvCustomItem _$CvCustomItemFromJson(Map<String, dynamic> json) =>
    _CvCustomItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      period: json['period'] == null
          ? const CvDateRange()
          : CvDateRange.fromJson(json['period'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$CvCustomItemToJson(_CvCustomItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'period': instance.period.toJson(),
      'description': instance.description,
    };

_CvCustomSection _$CvCustomSectionFromJson(Map<String, dynamic> json) =>
    _CvCustomSection(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CvCustomSectionTypeEnumMap, json['type']),
      visible: json['visible'] as bool? ?? true,
      text: json['text'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CvCustomItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CvCustomItem>[],
    );

Map<String, dynamic> _$CvCustomSectionToJson(_CvCustomSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CvCustomSectionTypeEnumMap[instance.type]!,
      'visible': instance.visible,
      'text': instance.text,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

const _$CvCustomSectionTypeEnumMap = {
  CvCustomSectionType.freeText: 'freeText',
  CvCustomSectionType.datedList: 'datedList',
  CvCustomSectionType.simpleList: 'simpleList',
};
