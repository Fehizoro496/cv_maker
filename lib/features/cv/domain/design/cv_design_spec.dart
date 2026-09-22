import 'package:json_annotation/json_annotation.dart';

import 'cv_design.dart';
import 'cv_canvas.dart';
import 'builtin_canvases.dart';

part 'cv_design_spec.g.dart';

/// Description de la mise en forme d'un modèle de CV, lue par le générateur.
///
/// Le libellé et la description affichés dans le catalogue restent portés par
/// `CvDesign` : cette description ne décrit que le rendu.
///
/// Le générateur ne connaît que cette description : il ne teste jamais
/// l'identité du modèle. Ajouter un modèle consiste donc à écrire une nouvelle
/// constante, sans toucher au rendu.
///
/// [canvas] définit toute la disposition. [header], [tokens] et [sections]
/// fournissent les styles des blocs de contenu structurés dans les cadres.
///
/// Les couleurs sont des entiers ARGB (`0xFF2F5D8C`) et non des `PdfColor` :
/// le domaine reste ainsi indépendant du paquet `pdf`.
///
/// Les modèles intégrés sont des constantes ; leur comparaison par `==` est
/// donc une comparaison d'identité, suffisante pour les besoins actuels.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  includeIfNull: true,
)
class CvDesignSpec {
  factory CvDesignSpec.fromJson(Map<String, dynamic> json) =>
      _$CvDesignSpecFromJson(json);
  Map<String, dynamic> toJson() => _$CvDesignSpecToJson(this);

  const CvDesignSpec({
    required this.canvas,
    this.header = const CvDesignHeader(),
    this.tokens = const CvDesignTokens(),
    this.sections = const CvDesignSectionStyle(),
  });

  final CvCanvas canvas;

  /// Groupe 2 : forme de l'en-tête et de la photo.
  final CvDesignHeader header;

  /// Groupe 3 : couleurs, échelle typographique, interlignes et marges.
  final CvDesignTokens tokens;

  /// Groupe 4 : titres, filets, puces et rendu des compétences.
  final CvDesignSectionStyle sections;

  /// La même description, avec les réglages que le CV peut imposer.
  ///
  /// La couleur d'accent, l'affichage de la photo, sa forme et sa taille sont
  /// les seules propriétés qu'un CV surcharge ; elles se résolvent donc ici,
  /// en un seul endroit, plutôt que d'être testées dans le générateur. Un
  /// modèle sans couleur ([CvDesignTokens.ignoresAccent]) refuse la surcharge
  /// de couleur. Une valeur `null` garde celle du modèle.
  CvDesignSpec withOverrides({
    int? accentColor,
    bool? showPhoto,
    CvPhotoShape? photoShape,
    double? photoSizeMm,
  }) => CvDesignSpec(
    canvas: canvas,
    header: showPhoto == null && photoShape == null && photoSizeMm == null
        ? header
        : header.copyWith(
            showPhoto: showPhoto,
            photoShape: photoShape,
            photoDiameterMm: photoSizeMm,
          ),
    tokens: accentColor == null || tokens.ignoresAccent
        ? tokens
        : tokens.copyWith(accentColor: accentColor),
    sections: sections,
  );
}

/// Groupe 2 — en-tête : bandeau, alignement, présence et forme de la photo.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  includeIfNull: true,
)
class CvDesignHeader {
  factory CvDesignHeader.fromJson(Map<String, dynamic> json) =>
      _$CvDesignHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$CvDesignHeaderToJson(this);

  const CvDesignHeader({
    this.fullWidthBanner = false,
    this.bannerPadding = 0,
    this.alignment = CvHeaderAlignment.start,
    this.showPhoto = true,
    this.photoShape = CvPhotoShape.circle,
    this.photoDiameterMm = 25,
    this.photoGap = 18,
    this.nameUppercase = false,
    this.headlineUppercase = false,
    this.headlineLetterSpacing = 0,
    this.headlineGap = 0,
  });

  /// Un bandeau pleine largeur peint le fond de l'en-tête avec la couleur
  /// d'accent ; le texte y prend alors [CvDesignTokens.onAccentColor].
  final bool fullWidthBanner;

  /// Marge intérieure du bandeau, ignorée sans bandeau.
  final double bannerPadding;

  /// Alignement du nom, du titre et des coordonnées.
  final CvHeaderAlignment alignment;

  /// Un modèle peut ignorer la photo même si la session en contient une.
  final bool showPhoto;

  final CvPhotoShape photoShape;

  /// Côté de la photo, en millimètres.
  final double photoDiameterMm;

  /// Espace entre la photo et le texte de l'en-tête.
  final double photoGap;

  /// Le nom est écrit en capitales.
  final bool nameUppercase;

  /// Le titre professionnel est écrit en capitales.
  final bool headlineUppercase;

  /// Interlettrage du titre professionnel.
  final double headlineLetterSpacing;
  final double headlineGap;

  CvDesignHeader copyWith({
    bool? showPhoto,
    CvPhotoShape? photoShape,
    double? photoDiameterMm,
  }) => CvDesignHeader(
    fullWidthBanner: fullWidthBanner,
    bannerPadding: bannerPadding,
    alignment: alignment,
    showPhoto: showPhoto ?? this.showPhoto,
    photoShape: photoShape ?? this.photoShape,
    photoDiameterMm: photoDiameterMm ?? this.photoDiameterMm,
    photoGap: photoGap,
    nameUppercase: nameUppercase,
    headlineUppercase: headlineUppercase,
    headlineLetterSpacing: headlineLetterSpacing,
    headlineGap: headlineGap,
  );
}

/// Alignement du contenu de l'en-tête.
enum CvHeaderAlignment { start, center }

/// Forme sous laquelle la photo est découpée.
enum CvPhotoShape {
  circle('Cercle'),
  rounded('Arrondi'),
  square('Carré');

  const CvPhotoShape(this.label);

  final String label;

  /// Rayon des coins d'une photo [rounded], en fraction de son côté.
  static const roundedCornerRatio = .16;
}

/// Groupe 3 — jetons visuels : couleurs, typographie, interlignes et marges.
///
/// Ce groupe ne contient aucune forme : uniquement des valeurs destinées à
/// devenir personnalisables indépendamment du modèle choisi.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  includeIfNull: true,
)
class CvDesignTokens {
  factory CvDesignTokens.fromJson(Map<String, dynamic> json) =>
      _$CvDesignTokensFromJson(json);
  Map<String, dynamic> toJson() => _$CvDesignTokensToJson(this);

  const CvDesignTokens({
    this.accentColor = 0xFF2F5D8C,
    this.onAccentColor = 0xFFFFFFFF,
    this.titleColor = 0xFF000000,
    this.bodyColor = 0xFF000000,
    this.mutedColor = 0xFF3A3F45,
    this.footerColor = 0xFF9AA0A6,
    this.headingColor,
    this.headingSurfaceColor,
    this.tintHeadingSurface = false,
    this.sidebarSurfaceColor,
    this.sidebarHeadingColor,
    this.sidebarTextColor,
    this.scale = const CvDesignTypeScale(),
    this.bodyLineSpacing = 3,
    this.headerGap = 12,
    this.entryGap = 8,
    this.sectionTitleGapAbove = 14,
    this.sectionTitleGapBelow = 7,
    this.ignoresAccent = false,
    this.minContactFontSize = 7,
  });

  /// Couleur d'accent du modèle : titres de section, filets et bandeau.
  final int accentColor;

  /// Couleur du texte posé sur la couleur d'accent.
  final int onAccentColor;

  /// Couleur du nom et des intitulés d'éléments.
  final int titleColor;

  /// Couleur du corps de texte.
  final int bodyColor;

  /// Couleur des informations secondaires : dates, lieux, coordonnées.
  final int mutedColor;

  /// Couleur de la pagination en pied de page.
  final int footerColor;

  /// Couleur des titres de section ; à défaut, [accentColor].
  final int? headingColor;

  /// Fond des titres de section, ou `null` pour un titre sans fond.
  final int? headingSurfaceColor;

  /// Les surfaces des titres suivent la teinte d'accent, mélangée au blanc.
  final bool tintHeadingSurface;

  int? get effectiveHeadingSurfaceColor {
    if (!tintHeadingSurface) return headingSurfaceColor;
    int channel(int shift) =>
        (255 * .92 + ((accentColor >> shift) & 255) * .08).round();
    return 0xFF000000 | (channel(16) << 16) | (channel(8) << 8) | channel(0);
  }

  /// Fond de la colonne latérale ; à défaut, [accentColor].
  final int? sidebarSurfaceColor;

  /// Couleur des titres de la colonne latérale ; à défaut, [onAccentColor].
  final int? sidebarHeadingColor;

  /// Couleur du texte de la colonne latérale ; à défaut, [onAccentColor].
  final int? sidebarTextColor;

  final CvDesignTypeScale scale;

  /// Interligne additionnel du corps de texte.
  final double bodyLineSpacing;

  /// Espace entre l'en-tête et la première section.
  final double headerGap;

  /// Espace entre deux éléments d'une même section.
  final double entryGap;

  /// Espace au-dessus d'un titre de section.
  final double sectionTitleGapAbove;

  /// Espace sous un titre de section.
  final double sectionTitleGapBelow;

  /// Un modèle sans couleur ignore le réglage de couleur d'accent.
  ///
  /// Le modèle sobre est entièrement en noir et gris : lui appliquer une
  /// couleur reviendrait à en faire un autre modèle.
  final bool ignoresAccent;

  /// En dessous de ce seuil, une coordonnée quitte son cadre pour l'en-tête.
  final double minContactFontSize;

  /// La couleur effective des titres de section.
  int get effectiveHeadingColor => headingColor ?? accentColor;

  /// Le fond effectif de la colonne latérale.
  int get effectiveSidebarSurfaceColor => sidebarSurfaceColor ?? accentColor;

  /// La couleur effective des titres de la colonne latérale.
  int get effectiveSidebarHeadingColor =>
      sidebarHeadingColor ??
      (sidebarSurfaceColor == null ? onAccentColor : accentColor);

  /// La couleur effective du texte de la colonne latérale.
  int get effectiveSidebarTextColor => sidebarTextColor ?? onAccentColor;

  CvDesignTokens copyWith({int? accentColor}) => CvDesignTokens(
    accentColor: accentColor ?? this.accentColor,
    onAccentColor: onAccentColor,
    titleColor: titleColor,
    bodyColor: bodyColor,
    mutedColor: mutedColor,
    footerColor: footerColor,
    headingColor: headingColor,
    headingSurfaceColor: headingSurfaceColor,
    tintHeadingSurface: tintHeadingSurface,
    sidebarSurfaceColor: sidebarSurfaceColor,
    sidebarHeadingColor: sidebarHeadingColor,
    sidebarTextColor: sidebarTextColor,
    scale: scale,
    bodyLineSpacing: bodyLineSpacing,
    headerGap: headerGap,
    entryGap: entryGap,
    sectionTitleGapAbove: sectionTitleGapAbove,
    sectionTitleGapBelow: sectionTitleGapBelow,
    ignoresAccent: ignoresAccent,
    minContactFontSize: minContactFontSize,
  );
}

/// Échelle typographique d'un modèle, en points.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  includeIfNull: true,
)
class CvDesignTypeScale {
  factory CvDesignTypeScale.fromJson(Map<String, dynamic> json) =>
      _$CvDesignTypeScaleFromJson(json);
  Map<String, dynamic> toJson() => _$CvDesignTypeScaleToJson(this);

  const CvDesignTypeScale({
    this.body = 9.5,
    this.name = 23,
    this.headline = 11,
    this.sectionTitle = 8,
    this.entryTitle = 10,
    this.meta = 8.5,
    this.footer = 9.5,
  });

  /// Corps de texte et descriptions.
  final double body;

  /// Nom de la personne, en en-tête.
  final double name;

  /// Titre professionnel, sous le nom.
  final double headline;

  /// Titres de section.
  final double sectionTitle;

  /// Intitulé d'un élément répétable : poste, diplôme, projet.
  final double entryTitle;

  /// Dates, lieux et coordonnées.
  final double meta;

  /// Pagination en pied de page.
  final double footer;
}

/// Groupe 4 — décorations : titres, filets, puces et rendu des compétences.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  includeIfNull: true,
)
class CvDesignSectionStyle {
  factory CvDesignSectionStyle.fromJson(Map<String, dynamic> json) =>
      _$CvDesignSectionStyleFromJson(json);
  Map<String, dynamic> toJson() => _$CvDesignSectionStyleToJson(this);

  const CvDesignSectionStyle({
    this.titleCase = CvSectionTitleCase.upper,
    this.titleLetterSpacing = 1.12,
    this.titlePaddingHorizontal = 0,
    this.titlePaddingVertical = 0,
    this.titleRuleWidth = 0,
    this.headerRuleThickness = 1,
    this.headerRuleLength,
    this.bulletPrefix = '',
    this.inlineSeparator = ' · ',
    this.titleRadius = 0,
    this.stackEntryMeta = false,
  });

  /// Casse appliquée aux titres de section.
  final CvSectionTitleCase titleCase;

  /// Interlettrage des titres de section.
  final double titleLetterSpacing;

  /// Marge intérieure horizontale d'un titre encadré.
  final double titlePaddingHorizontal;

  /// Marge intérieure verticale d'un titre encadré.
  final double titlePaddingVertical;

  /// Épaisseur du filet vertical à gauche du titre ; `0` pour aucun filet.
  final double titleRuleWidth;

  /// Épaisseur du filet sous l'en-tête ; `null` pour aucun filet.
  @JsonKey(readValue: _readHeaderRule, fromJson: _nullableDouble)
  final double? headerRuleThickness;

  /// Longueur du filet sous l'en-tête ; `null` pour toute la largeur.
  final double? headerRuleLength;

  /// Préfixe ajouté devant chaque ligne de description ; vide pour aucun.
  final String bulletPrefix;

  /// Séparateur des valeurs rendues sur une seule ligne : compétences,
  /// langues et coordonnées.
  final String inlineSeparator;

  final double titleRadius;

  /// Place la période sous l'intitulé pour libérer la largeur du corps.
  final bool stackEntryMeta;
}

/// Casse appliquée aux titres de section.
enum CvSectionTitleCase { upper, none }

// json_serializable applique la valeur par défaut sur null : la sentinelle
// distingue un filet explicitement absent d'une propriété omise (filet de 1).
const _noHeaderRule = Object();
Object _readHeaderRule(Map json, String key) =>
    json.containsKey(key) ? json[key] ?? _noHeaderRule : 1;
double? _nullableDouble(Object? value) =>
    identical(value, _noHeaderRule) ? null : (value as num?)?.toDouble();

/// Le modèle par défaut : une seule colonne et un filet d'accent.
///
/// Il sert de référence commune aux autres : marges, échelle typographique et
/// règles de pagination sont les siennes, et chaque autre modèle n'en décrit
/// que ses écarts. Il sert aussi de repli lorsqu'un CV référence un modèle
/// inconnu.
const classicDesignSpec = CvDesignSpec(canvas: classicCanvas);

/// Noir et blanc, sans aucune couleur d'accent.
const plainDesignSpec = CvDesignSpec(
  canvas: plainCanvas,
  tokens: CvDesignTokens(
    accentColor: 0xFF1B1F23,
    mutedColor: 0xFF43474E,
    ignoresAccent: true,
  ),
  sections: CvDesignSectionStyle(headerRuleThickness: .8),
);

/// Un bandeau d'accent pleine largeur et des titres de section encadrés.
const bannerDesignSpec = CvDesignSpec(
  canvas: bannerCanvas,
  header: CvDesignHeader(fullWidthBanner: true, bannerPadding: 16),
  tokens: CvDesignTokens(tintHeadingSurface: true),
  sections: CvDesignSectionStyle(
    titlePaddingHorizontal: 8,
    titlePaddingVertical: 5,
    titleRuleWidth: 3,
    headerRuleThickness: null,
  ),
);

/// Interlignes serrés et espacements réduits : plus de contenu par page.
const compactDesignSpec = CvDesignSpec(
  canvas: compactCanvas,
  tokens: CvDesignTokens(
    scale: CvDesignTypeScale(
      body: 8.5,
      name: 20,
      headline: 10,
      entryTitle: 9.5,
      meta: 8,
    ),
    bodyLineSpacing: 1.6,
    headerGap: 8,
    entryGap: 5,
    sectionTitleGapAbove: 9,
    sectionTitleGapBelow: 5,
  ),
);

/// En-tête centré, filet discret et formations avant les expériences.
const academicDesignSpec = CvDesignSpec(
  canvas: academicCanvas,
  header: CvDesignHeader(alignment: CvHeaderAlignment.center),
  tokens: CvDesignTokens(scale: CvDesignTypeScale(name: 26, sectionTitle: 10)),
  sections: CvDesignSectionStyle(
    titleCase: CvSectionTitleCase.none,
    titleLetterSpacing: 0,
    headerRuleThickness: .4,
  ),
);

/// Une colonne en aplat d'accent à gauche : photo, coordonnées, compétences
/// et langues ; le corps à droite.
const sidebarDesignSpec = CvDesignSpec(
  canvas: sidebarCanvas,
  header: CvDesignHeader(headlineGap: 6, photoDiameterMm: 28),
  tokens: CvDesignTokens(
    titleColor: 0xFF202B38,
    bodyColor: 0xFF344251,
    mutedColor: 0xFF667383,
    tintHeadingSurface: true,
    scale: CvDesignTypeScale(name: 27, body: 9.2, entryTitle: 10.5, footer: 8),
    bodyLineSpacing: 2.5,
    headerGap: 14,
    entryGap: 12,
    sectionTitleGapAbove: 18,
    sectionTitleGapBelow: 9,
  ),
  sections: CvDesignSectionStyle(
    headerRuleThickness: null,
    titleLetterSpacing: .7,
    titlePaddingHorizontal: 7,
    titlePaddingVertical: 5,
    titleRadius: 6,
    stackEntryMeta: true,
  ),
);

/// Une colonne grise à droite : coordonnées, langues et centres d'intérêt.
const lightSidebarDesignSpec = CvDesignSpec(
  canvas: lightSidebarCanvas,
  tokens: CvDesignTokens(
    sidebarSurfaceColor: 0xFFEDF0F5,
    sidebarTextColor: 0xFF1B1F23,
    titleColor: 0xFF202B38,
    bodyColor: 0xFF344251,
    mutedColor: 0xFF667383,
    tintHeadingSurface: true,
    scale: CvDesignTypeScale(name: 27, body: 9.2, entryTitle: 10.5, footer: 8),
    bodyLineSpacing: 2.5,
    headerGap: 14,
    entryGap: 12,
    sectionTitleGapAbove: 18,
    sectionTitleGapBelow: 9,
  ),
  header: CvDesignHeader(headlineGap: 6, photoDiameterMm: 20, photoGap: 12),
  sections: CvDesignSectionStyle(
    headerRuleThickness: null,
    titleLetterSpacing: .7,
    titlePaddingHorizontal: 7,
    titlePaddingVertical: 5,
    titleRadius: 6,
    stackEntryMeta: true,
  ),
);

/// Nom en capitales, titres de section dans une marge à gauche et court filet
/// d'accent sous l'en-tête.
const contrastDesignSpec = CvDesignSpec(
  canvas: contrastCanvas,
  header: CvDesignHeader(
    nameUppercase: true,
    headlineUppercase: true,
    headlineLetterSpacing: 1.3,
    headlineGap: 7,
  ),
  tokens: CvDesignTokens(
    titleColor: 0xFF202B38,
    bodyColor: 0xFF344251,
    mutedColor: 0xFF667383,
    scale: CvDesignTypeScale(name: 30, entryTitle: 11, footer: 8),
    headerGap: 18,
    entryGap: 12,
    sectionTitleGapAbove: 22,
    bodyLineSpacing: 2.5,
  ),
  sections: CvDesignSectionStyle(
    headerRuleThickness: 3,
    headerRuleLength: 48,
    titleLetterSpacing: .6,
    stackEntryMeta: true,
  ),
);

/// Seul point de correspondance entre l'identifiant d'un modèle et sa
/// description : le générateur PDF n'utilise que [CvDesignSpec].
extension CvDesignSpecLookup on CvDesign {
  CvDesignSpec get spec => switch (this) {
    CvDesign.classic => classicDesignSpec,
    CvDesign.plain => plainDesignSpec,
    CvDesign.sidebar => sidebarDesignSpec,
    CvDesign.lightSidebar => lightSidebarDesignSpec,
    CvDesign.banner => bannerDesignSpec,
    CvDesign.compact => compactDesignSpec,
    CvDesign.academic => academicDesignSpec,
    CvDesign.contrast => contrastDesignSpec,
  };
}
