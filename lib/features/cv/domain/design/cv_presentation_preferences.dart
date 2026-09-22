import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_design.dart';
import 'cv_template.dart';
import 'cv_design_spec.dart';
import '../document/cv_section.dart';

part 'cv_presentation_preferences.freezed.dart';
part 'cv_presentation_preferences.g.dart';

/// Choix de présentation d'un CV : modèle, réglages, ordre et visibilité des
/// sections.
///
/// L'identifiant relie le CV au catalogue ; [templateSnapshot] conserve la
/// définition appliquée pour que les imports suivants ne changent pas son rendu.
/// Les anciens CV sans copie utilisent encore le modèle intégré correspondant.
///
/// [accentArgb], [showPhoto], [photoShape] et [photoSizeMm] sont les seules
/// propriétés de mise en forme qu'un CV impose au modèle choisi ; le reste
/// vient de sa description. La couleur est libre : elle est donc enregistrée
/// telle quelle, et non sous forme d'identifiant de palette.
@freezed
abstract class CvPresentationPreferences with _$CvPresentationPreferences {
  const factory CvPresentationPreferences({
    @Default('classic') String designId,

    /// Copie autonome : les mises à jour du catalogue ne modifient pas ce CV.
    CvTemplate? templateSnapshot,
    @Default(CvAccent.defaultColor) int accentArgb,
    @Default(true) bool showPhoto,

    /// Forme de la photo ; `null` garde celle du modèle.
    CvPhotoShape? photoShape,

    /// Côté de la photo en millimètres ; `null` garde celui du modèle.
    double? photoSizeMm,
    @Default(<CvSection>[]) List<CvSection> sectionOrder,
    @Default(<CvSection>[]) List<CvSection> hiddenSections,
  }) = _CvPresentationPreferences;

  const CvPresentationPreferences._();

  factory CvPresentationPreferences.fromJson(Map<String, dynamic> json) =>
      _$CvPresentationPreferencesFromJson(json);

  /// Le modèle référencé, ou le modèle par défaut si l'identifiant est inconnu.
  CvDesign get design => CvDesign.fromId(designId);

  /// Bornes du côté de la photo, en millimètres.
  static const minPhotoSizeMm = 16.0;
  static const maxPhotoSizeMm = 40.0;

  /// La couleur d'accent du CV, opacité forcée pour rester imprimable.
  int get accentColor => accentArgb | 0xFF000000;

  /// Les sections dans leur ordre d'affichage.
  ///
  /// Les sections absentes de [sectionOrder] sont ajoutées à la fin dans leur
  /// ordre déclaré : un CV enregistré avant l'ajout d'une section reste
  /// complet après mise à jour de l'application.
  List<CvSection> get orderedSections => [
    for (final section in sectionOrder)
      if (CvSection.values.contains(section)) section,
    for (final section in CvSection.values)
      if (!sectionOrder.contains(section)) section,
  ];

  /// Seule une section facultative peut être masquée.
  bool isVisible(CvSection section) =>
      !section.isOptional || !hiddenSections.contains(section);

  /// Affiche ou masque [section]. Sans effet sur une section obligatoire.
  CvPresentationPreferences withSectionVisible(
    CvSection section,
    bool visible,
  ) {
    if (!section.isOptional || isVisible(section) == visible) return this;
    return copyWith(
      hiddenSections: visible
          ? [
              for (final hidden in hiddenSections)
                if (hidden != section) hidden,
            ]
          : [...hiddenSections, section],
    );
  }

  /// Déplace une section dans l'ordre d'affichage.
  CvPresentationPreferences reorderSections(int oldIndex, int newIndex) {
    final sections = orderedSections;
    if (oldIndex < 0 ||
        oldIndex >= sections.length ||
        newIndex < 0 ||
        newIndex >= sections.length ||
        oldIndex == newIndex) {
      return this;
    }
    sections.insert(newIndex, sections.removeAt(oldIndex));
    return copyWith(sectionOrder: sections);
  }

  CvPresentationPreferences withDesign(CvDesign design) =>
      copyWith(designId: design.id, templateSnapshot: null);

  /// Impose la forme et la taille de la photo, bornée ; `null` rend la main
  /// au modèle.
  CvPresentationPreferences withPhotoFormat({
    required CvPhotoShape? shape,
    required double? sizeMm,
  }) => copyWith(
    photoShape: shape,
    photoSizeMm: sizeMm?.clamp(minPhotoSizeMm, maxPhotoSizeMm),
  );

  CvPresentationPreferences withAccent(int argb) =>
      copyWith(accentArgb: argb | 0xFF000000);

  /// Les trois choix du catalogue s'appliquent d'un seul geste.
  CvPresentationPreferences withTemplate({
    required CvDesign design,
    required int accentArgb,
    required bool showPhoto,
  }) => copyWith(
    designId: design.id,
    templateSnapshot: null,
    accentArgb: accentArgb | 0xFF000000,
    showPhoto: showPhoto,
  );
}
