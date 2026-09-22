// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvTemplate _$CvTemplateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CvTemplate', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['id', 'revision', 'label', 'description', 'spec'],
      );
      final val = CvTemplate(
        id: $checkedConvert('id', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        spec: $checkedConvert(
          'spec',
          (v) => CvDesignSpec.fromJson(v as Map<String, dynamic>),
        ),
        revision: $checkedConvert('revision', (v) => (v as num?)?.toInt() ?? 1),
      );
      return val;
    });

Map<String, dynamic> _$CvTemplateToJson(CvTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'revision': instance.revision,
      'label': instance.label,
      'description': instance.description,
      'spec': instance.spec.toJson(),
    };
