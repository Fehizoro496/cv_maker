// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvNote _$CvNoteFromJson(Map<String, dynamic> json) => _CvNote(
  id: json['id'] as String,
  label: json['label'] as String? ?? '',
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$CvNoteToJson(_CvNote instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'description': instance.description,
};
