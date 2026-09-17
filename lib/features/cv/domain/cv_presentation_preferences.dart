import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_design.dart';
import 'cv_section.dart';

part 'cv_presentation_preferences.freezed.dart';
part 'cv_presentation_preferences.g.dart';

/// Choix de présentation d'un CV : modèle, ordre et visibilité des sections.
///
/// Ces préférences ne décrivent pas le modèle, elles s'y réfèrent par son
/// identifiant : le catalogue reste libre de faire évoluer un modèle sans
/// migrer les CV enregistrés.
@freezed
abstract class CvPresentationPreferences with _$CvPresentationPreferences {
  const factory CvPresentationPreferences({
    @Default('professional') String designId,
    @Default(<CvSection>[]) List<CvSection> sectionOrder,
    @Default(<CvSection>[]) List<CvSection> hiddenSections,
  }) = _CvPresentationPreferences;

  const CvPresentationPreferences._();

  factory CvPresentationPreferences.fromJson(Map<String, dynamic> json) =>
      _$CvPresentationPreferencesFromJson(json);

  /// Le modèle référencé, ou le modèle par défaut si l'identifiant est inconnu.
  CvDesign get design => CvDesign.fromId(designId);

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
      copyWith(designId: design.id);
}
