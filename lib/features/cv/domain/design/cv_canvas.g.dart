// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_canvas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvCanvas _$CvCanvasFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CvCanvas', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['pages']);
      final val = CvCanvas(
        pages: $checkedConvert(
          'pages',
          (v) => (v as List<dynamic>)
              .map((e) => CvCanvasPage.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CvCanvasToJson(CvCanvas instance) => <String, dynamic>{
  'pages': instance.pages.map((e) => e.toJson()).toList(),
};

CvCanvasPage _$CvCanvasPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CvCanvasPage', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['background', 'showPageNumber', 'elements'],
      );
      final val = CvCanvasPage(
        elements: $checkedConvert(
          'elements',
          (v) => (v as List<dynamic>)
              .map((e) => CvCanvasElement.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        background: $checkedConvert(
          'background',
          (v) => (v as num?)?.toInt() ?? 0xFFFFFFFF,
        ),
        showPageNumber: $checkedConvert(
          'showPageNumber',
          (v) => v as bool? ?? false,
        ),
      );
      return val;
    });

Map<String, dynamic> _$CvCanvasPageToJson(CvCanvasPage instance) =>
    <String, dynamic>{
      'background': instance.background,
      'showPageNumber': instance.showPageNumber,
      'elements': instance.elements.map((e) => e.toJson()).toList(),
    };

CvCanvasElement _$CvCanvasElementFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CvCanvasElement', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'id',
      'type',
      'x',
      'y',
      'width',
      'height',
      'text',
      'binding',
      'section',
      'fontSize',
      'bold',
      'italic',
      'color',
      'background',
      'borderColor',
      'borderWidth',
      'radius',
      'padding',
      'align',
      'palette',
      'sectionOrder',
      'excludedSections',
      'includeRemaining',
      'includeCustom',
      'showHeader',
      'showContacts',
      'showPhoto',
      'titleMargin',
    ],
  );
  final val = CvCanvasElement(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$CvCanvasElementTypeEnumMap, v),
    ),
    x: $checkedConvert('x', (v) => (v as num).toDouble()),
    y: $checkedConvert('y', (v) => (v as num).toDouble()),
    width: $checkedConvert('width', (v) => (v as num).toDouble()),
    height: $checkedConvert('height', (v) => (v as num).toDouble()),
    text: $checkedConvert('text', (v) => v as String? ?? ''),
    binding: $checkedConvert('binding', (v) => v as String?),
    section: $checkedConvert(
      'section',
      (v) => $enumDecodeNullable(_$CvSectionEnumMap, v),
    ),
    fontSize: $checkedConvert('fontSize', (v) => (v as num?)?.toDouble() ?? 10),
    bold: $checkedConvert('bold', (v) => v as bool? ?? false),
    italic: $checkedConvert('italic', (v) => v as bool? ?? false),
    color: $checkedConvert('color', (v) => (v as num?)?.toInt() ?? 0xFF202B38),
    background: $checkedConvert('background', (v) => (v as num?)?.toInt()),
    borderColor: $checkedConvert(
      'borderColor',
      (v) => (v as num?)?.toInt() ?? 0xFF202B38,
    ),
    borderWidth: $checkedConvert(
      'borderWidth',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    radius: $checkedConvert('radius', (v) => (v as num?)?.toDouble() ?? 0),
    padding: $checkedConvert('padding', (v) => (v as num?)?.toDouble() ?? 0),
    align: $checkedConvert(
      'align',
      (v) =>
          $enumDecodeNullable(_$CvCanvasTextAlignEnumMap, v) ??
          CvCanvasTextAlign.left,
    ),
    palette: $checkedConvert(
      'palette',
      (v) =>
          $enumDecodeNullable(_$CvCanvasPaletteEnumMap, v) ??
          CvCanvasPalette.custom,
    ),
    sectionOrder: $checkedConvert(
      'sectionOrder',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => $enumDecode(_$CvSectionEnumMap, e))
              .toList() ??
          const [],
    ),
    excludedSections: $checkedConvert(
      'excludedSections',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => $enumDecode(_$CvSectionEnumMap, e))
              .toList() ??
          const [],
    ),
    includeRemaining: $checkedConvert(
      'includeRemaining',
      (v) => v as bool? ?? false,
    ),
    includeCustom: $checkedConvert('includeCustom', (v) => v as bool? ?? false),
    showHeader: $checkedConvert('showHeader', (v) => v as bool? ?? false),
    showContacts: $checkedConvert('showContacts', (v) => v as bool? ?? false),
    showPhoto: $checkedConvert('showPhoto', (v) => v as bool? ?? false),
    titleMargin: $checkedConvert(
      'titleMargin',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
  );
  return val;
});

Map<String, dynamic> _$CvCanvasElementToJson(CvCanvasElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CvCanvasElementTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'text': instance.text,
      'binding': ?instance.binding,
      'section': ?_$CvSectionEnumMap[instance.section],
      'fontSize': instance.fontSize,
      'bold': instance.bold,
      'italic': instance.italic,
      'color': instance.color,
      'background': ?instance.background,
      'borderColor': instance.borderColor,
      'borderWidth': instance.borderWidth,
      'radius': instance.radius,
      'padding': instance.padding,
      'align': _$CvCanvasTextAlignEnumMap[instance.align]!,
      'palette': _$CvCanvasPaletteEnumMap[instance.palette]!,
      'sectionOrder': instance.sectionOrder
          .map((e) => _$CvSectionEnumMap[e]!)
          .toList(),
      'excludedSections': instance.excludedSections
          .map((e) => _$CvSectionEnumMap[e]!)
          .toList(),
      'includeRemaining': instance.includeRemaining,
      'includeCustom': instance.includeCustom,
      'showHeader': instance.showHeader,
      'showContacts': instance.showContacts,
      'showPhoto': instance.showPhoto,
      'titleMargin': instance.titleMargin,
    };

const _$CvCanvasElementTypeEnumMap = {
  CvCanvasElementType.text: 'text',
  CvCanvasElementType.section: 'section',
  CvCanvasElementType.photo: 'photo',
  CvCanvasElementType.rectangle: 'rectangle',
  CvCanvasElementType.flow: 'flow',
};

const _$CvSectionEnumMap = {
  CvSection.personalInfo: 'personalInfo',
  CvSection.profile: 'profile',
  CvSection.experiences: 'experiences',
  CvSection.education: 'education',
  CvSection.skills: 'skills',
  CvSection.languages: 'languages',
  CvSection.certifications: 'certifications',
  CvSection.projects: 'projects',
  CvSection.interests: 'interests',
  CvSection.references: 'references',
};

const _$CvCanvasTextAlignEnumMap = {
  CvCanvasTextAlign.left: 'left',
  CvCanvasTextAlign.center: 'center',
  CvCanvasTextAlign.right: 'right',
  CvCanvasTextAlign.justify: 'justify',
};

const _$CvCanvasPaletteEnumMap = {
  CvCanvasPalette.custom: 'custom',
  CvCanvasPalette.body: 'body',
  CvCanvasPalette.sidebar: 'sidebar',
};
