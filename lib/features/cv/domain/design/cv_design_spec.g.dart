// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_design_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvDesignSpec _$CvDesignSpecFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CvDesignSpec', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['canvas', 'header', 'tokens', 'sections'],
      );
      final val = CvDesignSpec(
        canvas: $checkedConvert(
          'canvas',
          (v) => CvCanvas.fromJson(v as Map<String, dynamic>),
        ),
        header: $checkedConvert(
          'header',
          (v) => v == null
              ? const CvDesignHeader()
              : CvDesignHeader.fromJson(v as Map<String, dynamic>),
        ),
        tokens: $checkedConvert(
          'tokens',
          (v) => v == null
              ? const CvDesignTokens()
              : CvDesignTokens.fromJson(v as Map<String, dynamic>),
        ),
        sections: $checkedConvert(
          'sections',
          (v) => v == null
              ? const CvDesignSectionStyle()
              : CvDesignSectionStyle.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CvDesignSpecToJson(CvDesignSpec instance) =>
    <String, dynamic>{
      'canvas': instance.canvas.toJson(),
      'header': instance.header.toJson(),
      'tokens': instance.tokens.toJson(),
      'sections': instance.sections.toJson(),
    };

CvDesignHeader _$CvDesignHeaderFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CvDesignHeader', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'fullWidthBanner',
      'bannerPadding',
      'alignment',
      'showPhoto',
      'photoShape',
      'photoDiameterMm',
      'photoGap',
      'nameUppercase',
      'headlineUppercase',
      'headlineLetterSpacing',
      'headlineGap',
    ],
  );
  final val = CvDesignHeader(
    fullWidthBanner: $checkedConvert(
      'fullWidthBanner',
      (v) => v as bool? ?? false,
    ),
    bannerPadding: $checkedConvert(
      'bannerPadding',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    alignment: $checkedConvert(
      'alignment',
      (v) =>
          $enumDecodeNullable(_$CvHeaderAlignmentEnumMap, v) ??
          CvHeaderAlignment.start,
    ),
    showPhoto: $checkedConvert('showPhoto', (v) => v as bool? ?? true),
    photoShape: $checkedConvert(
      'photoShape',
      (v) =>
          $enumDecodeNullable(_$CvPhotoShapeEnumMap, v) ?? CvPhotoShape.circle,
    ),
    photoDiameterMm: $checkedConvert(
      'photoDiameterMm',
      (v) => (v as num?)?.toDouble() ?? 25,
    ),
    photoGap: $checkedConvert('photoGap', (v) => (v as num?)?.toDouble() ?? 18),
    nameUppercase: $checkedConvert('nameUppercase', (v) => v as bool? ?? false),
    headlineUppercase: $checkedConvert(
      'headlineUppercase',
      (v) => v as bool? ?? false,
    ),
    headlineLetterSpacing: $checkedConvert(
      'headlineLetterSpacing',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    headlineGap: $checkedConvert(
      'headlineGap',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
  );
  return val;
});

Map<String, dynamic> _$CvDesignHeaderToJson(CvDesignHeader instance) =>
    <String, dynamic>{
      'fullWidthBanner': instance.fullWidthBanner,
      'bannerPadding': instance.bannerPadding,
      'alignment': _$CvHeaderAlignmentEnumMap[instance.alignment]!,
      'showPhoto': instance.showPhoto,
      'photoShape': _$CvPhotoShapeEnumMap[instance.photoShape]!,
      'photoDiameterMm': instance.photoDiameterMm,
      'photoGap': instance.photoGap,
      'nameUppercase': instance.nameUppercase,
      'headlineUppercase': instance.headlineUppercase,
      'headlineLetterSpacing': instance.headlineLetterSpacing,
      'headlineGap': instance.headlineGap,
    };

const _$CvHeaderAlignmentEnumMap = {
  CvHeaderAlignment.start: 'start',
  CvHeaderAlignment.center: 'center',
};

const _$CvPhotoShapeEnumMap = {
  CvPhotoShape.circle: 'circle',
  CvPhotoShape.rounded: 'rounded',
  CvPhotoShape.square: 'square',
};

CvDesignTokens _$CvDesignTokensFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CvDesignTokens', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'accentColor',
      'onAccentColor',
      'titleColor',
      'bodyColor',
      'mutedColor',
      'footerColor',
      'headingColor',
      'headingSurfaceColor',
      'tintHeadingSurface',
      'sidebarSurfaceColor',
      'sidebarHeadingColor',
      'sidebarTextColor',
      'scale',
      'bodyLineSpacing',
      'headerGap',
      'entryGap',
      'sectionTitleGapAbove',
      'sectionTitleGapBelow',
      'ignoresAccent',
      'minContactFontSize',
    ],
  );
  final val = CvDesignTokens(
    accentColor: $checkedConvert(
      'accentColor',
      (v) => (v as num?)?.toInt() ?? 0xFF2F5D8C,
    ),
    onAccentColor: $checkedConvert(
      'onAccentColor',
      (v) => (v as num?)?.toInt() ?? 0xFFFFFFFF,
    ),
    titleColor: $checkedConvert(
      'titleColor',
      (v) => (v as num?)?.toInt() ?? 0xFF000000,
    ),
    bodyColor: $checkedConvert(
      'bodyColor',
      (v) => (v as num?)?.toInt() ?? 0xFF000000,
    ),
    mutedColor: $checkedConvert(
      'mutedColor',
      (v) => (v as num?)?.toInt() ?? 0xFF3A3F45,
    ),
    footerColor: $checkedConvert(
      'footerColor',
      (v) => (v as num?)?.toInt() ?? 0xFF9AA0A6,
    ),
    headingColor: $checkedConvert('headingColor', (v) => (v as num?)?.toInt()),
    headingSurfaceColor: $checkedConvert(
      'headingSurfaceColor',
      (v) => (v as num?)?.toInt(),
    ),
    tintHeadingSurface: $checkedConvert(
      'tintHeadingSurface',
      (v) => v as bool? ?? false,
    ),
    sidebarSurfaceColor: $checkedConvert(
      'sidebarSurfaceColor',
      (v) => (v as num?)?.toInt(),
    ),
    sidebarHeadingColor: $checkedConvert(
      'sidebarHeadingColor',
      (v) => (v as num?)?.toInt(),
    ),
    sidebarTextColor: $checkedConvert(
      'sidebarTextColor',
      (v) => (v as num?)?.toInt(),
    ),
    scale: $checkedConvert(
      'scale',
      (v) => v == null
          ? const CvDesignTypeScale()
          : CvDesignTypeScale.fromJson(v as Map<String, dynamic>),
    ),
    bodyLineSpacing: $checkedConvert(
      'bodyLineSpacing',
      (v) => (v as num?)?.toDouble() ?? 3,
    ),
    headerGap: $checkedConvert(
      'headerGap',
      (v) => (v as num?)?.toDouble() ?? 12,
    ),
    entryGap: $checkedConvert('entryGap', (v) => (v as num?)?.toDouble() ?? 8),
    sectionTitleGapAbove: $checkedConvert(
      'sectionTitleGapAbove',
      (v) => (v as num?)?.toDouble() ?? 14,
    ),
    sectionTitleGapBelow: $checkedConvert(
      'sectionTitleGapBelow',
      (v) => (v as num?)?.toDouble() ?? 7,
    ),
    ignoresAccent: $checkedConvert('ignoresAccent', (v) => v as bool? ?? false),
    minContactFontSize: $checkedConvert(
      'minContactFontSize',
      (v) => (v as num?)?.toDouble() ?? 7,
    ),
  );
  return val;
});

Map<String, dynamic> _$CvDesignTokensToJson(CvDesignTokens instance) =>
    <String, dynamic>{
      'accentColor': instance.accentColor,
      'onAccentColor': instance.onAccentColor,
      'titleColor': instance.titleColor,
      'bodyColor': instance.bodyColor,
      'mutedColor': instance.mutedColor,
      'footerColor': instance.footerColor,
      'headingColor': instance.headingColor,
      'headingSurfaceColor': instance.headingSurfaceColor,
      'tintHeadingSurface': instance.tintHeadingSurface,
      'sidebarSurfaceColor': instance.sidebarSurfaceColor,
      'sidebarHeadingColor': instance.sidebarHeadingColor,
      'sidebarTextColor': instance.sidebarTextColor,
      'scale': instance.scale.toJson(),
      'bodyLineSpacing': instance.bodyLineSpacing,
      'headerGap': instance.headerGap,
      'entryGap': instance.entryGap,
      'sectionTitleGapAbove': instance.sectionTitleGapAbove,
      'sectionTitleGapBelow': instance.sectionTitleGapBelow,
      'ignoresAccent': instance.ignoresAccent,
      'minContactFontSize': instance.minContactFontSize,
    };

CvDesignTypeScale _$CvDesignTypeScaleFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CvDesignTypeScale', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'body',
      'name',
      'headline',
      'sectionTitle',
      'entryTitle',
      'meta',
      'footer',
    ],
  );
  final val = CvDesignTypeScale(
    body: $checkedConvert('body', (v) => (v as num?)?.toDouble() ?? 9.5),
    name: $checkedConvert('name', (v) => (v as num?)?.toDouble() ?? 23),
    headline: $checkedConvert('headline', (v) => (v as num?)?.toDouble() ?? 11),
    sectionTitle: $checkedConvert(
      'sectionTitle',
      (v) => (v as num?)?.toDouble() ?? 8,
    ),
    entryTitle: $checkedConvert(
      'entryTitle',
      (v) => (v as num?)?.toDouble() ?? 10,
    ),
    meta: $checkedConvert('meta', (v) => (v as num?)?.toDouble() ?? 8.5),
    footer: $checkedConvert('footer', (v) => (v as num?)?.toDouble() ?? 9.5),
  );
  return val;
});

Map<String, dynamic> _$CvDesignTypeScaleToJson(CvDesignTypeScale instance) =>
    <String, dynamic>{
      'body': instance.body,
      'name': instance.name,
      'headline': instance.headline,
      'sectionTitle': instance.sectionTitle,
      'entryTitle': instance.entryTitle,
      'meta': instance.meta,
      'footer': instance.footer,
    };

CvDesignSectionStyle _$CvDesignSectionStyleFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CvDesignSectionStyle', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'titleCase',
      'titleLetterSpacing',
      'titlePaddingHorizontal',
      'titlePaddingVertical',
      'titleRuleWidth',
      'headerRuleThickness',
      'headerRuleLength',
      'bulletPrefix',
      'inlineSeparator',
      'titleRadius',
      'stackEntryMeta',
    ],
  );
  final val = CvDesignSectionStyle(
    titleCase: $checkedConvert(
      'titleCase',
      (v) =>
          $enumDecodeNullable(_$CvSectionTitleCaseEnumMap, v) ??
          CvSectionTitleCase.upper,
    ),
    titleLetterSpacing: $checkedConvert(
      'titleLetterSpacing',
      (v) => (v as num?)?.toDouble() ?? 1.12,
    ),
    titlePaddingHorizontal: $checkedConvert(
      'titlePaddingHorizontal',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    titlePaddingVertical: $checkedConvert(
      'titlePaddingVertical',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    titleRuleWidth: $checkedConvert(
      'titleRuleWidth',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    headerRuleThickness: $checkedConvert(
      'headerRuleThickness',
      (v) => v == null ? 1 : _nullableDouble(v),
      readValue: _readHeaderRule,
    ),
    headerRuleLength: $checkedConvert(
      'headerRuleLength',
      (v) => (v as num?)?.toDouble(),
    ),
    bulletPrefix: $checkedConvert('bulletPrefix', (v) => v as String? ?? ''),
    inlineSeparator: $checkedConvert(
      'inlineSeparator',
      (v) => v as String? ?? ' · ',
    ),
    titleRadius: $checkedConvert(
      'titleRadius',
      (v) => (v as num?)?.toDouble() ?? 0,
    ),
    stackEntryMeta: $checkedConvert(
      'stackEntryMeta',
      (v) => v as bool? ?? false,
    ),
  );
  return val;
});

Map<String, dynamic> _$CvDesignSectionStyleToJson(
  CvDesignSectionStyle instance,
) => <String, dynamic>{
  'titleCase': _$CvSectionTitleCaseEnumMap[instance.titleCase]!,
  'titleLetterSpacing': instance.titleLetterSpacing,
  'titlePaddingHorizontal': instance.titlePaddingHorizontal,
  'titlePaddingVertical': instance.titlePaddingVertical,
  'titleRuleWidth': instance.titleRuleWidth,
  'headerRuleThickness': instance.headerRuleThickness,
  'headerRuleLength': instance.headerRuleLength,
  'bulletPrefix': instance.bulletPrefix,
  'inlineSeparator': instance.inlineSeparator,
  'titleRadius': instance.titleRadius,
  'stackEntryMeta': instance.stackEntryMeta,
};

const _$CvSectionTitleCaseEnumMap = {
  CvSectionTitleCase.upper: 'upper',
  CvSectionTitleCase.none: 'none',
};
