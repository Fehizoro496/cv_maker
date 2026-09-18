import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_certification.dart';
import 'cv_design.dart';
import 'cv_design_spec.dart';
import 'cv_education.dart';
import 'cv_entry.dart';
import 'cv_experience.dart';
import 'cv_language.dart';
import 'cv_note.dart';
import 'cv_personal_info.dart';
import 'cv_presentation_preferences.dart';
import 'cv_project.dart';
import 'cv_section.dart';
import 'cv_skill.dart';

part 'cv_document.freezed.dart';
part 'cv_document.g.dart';

/// Un CV complet, indépendant de l'interface et du rendu PDF.
///
/// Le document est immuable : chaque modification produit un nouvel état, ce
/// qui permet d'empiler les états successifs pour l'annulation. Les listes se
/// modifient avec les opérations pures de [CvEntryList] et le résultat se
/// réinjecte avec `copyWith` :
///
/// ```dart
/// document.copyWith(experiences: document.experiences.removed(id));
/// ```
///
/// La photo n'est pas ici : elle n'est pas persistée et vit dans `CvSession`.
@freezed
abstract class CvDocument with _$CvDocument {
  const factory CvDocument({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String name,
    @Default(CvPersonalInfo()) CvPersonalInfo personalInfo,
    @Default('') String profile,
    @Default(<CvExperience>[]) List<CvExperience> experiences,
    @Default(<CvEducation>[]) List<CvEducation> education,
    @Default(<CvSkill>[]) List<CvSkill> skills,
    @Default(<CvLanguage>[]) List<CvLanguage> languages,
    @Default(<CvCertification>[]) List<CvCertification> certifications,
    @Default(<CvProject>[]) List<CvProject> projects,
    @Default(<CvNote>[]) List<CvNote> interests,
    @Default(<CvNote>[]) List<CvNote> references,
    @Default(CvPresentationPreferences())
    CvPresentationPreferences presentation,
  }) = _CvDocument;

  const CvDocument._();

  factory CvDocument.fromJson(Map<String, dynamic> json) =>
      _$CvDocumentFromJson(json);

  /// Un CV vide, prêt à être rempli.
  factory CvDocument.empty({
    required String id,
    required DateTime now,
    String name = '',
  }) => CvDocument(id: id, createdAt: now, updatedAt: now, name: name);

  /// Le même document, daté de [at] : à appeler après chaque modification.
  CvDocument touched(DateTime at) => copyWith(updatedAt: at);

  CvDesign get design => presentation.design;

  /// La description effective du modèle, réglages du CV appliqués.
  ///
  /// C'est la seule entrée de mise en forme du générateur PDF : la couleur
  /// d'accent et l'affichage de la photo y sont déjà résolus.
  CvDesignSpec get designSpec => design.spec.withOverrides(
    accentColor: presentation.accentColor,
    showPhoto: presentation.showPhoto,
  );

  bool isVisible(CvSection section) => presentation.isVisible(section);

  CvDocument withSectionVisible(CvSection section, bool visible) =>
      copyWith(presentation: presentation.withSectionVisible(section, visible));

  CvDocument withDesign(CvDesign design) =>
      copyWith(presentation: presentation.withDesign(design));

  /// Les éléments répétables de [section], en lecture seule.
  ///
  /// Les sections sans liste ([CvSection.profile]) renvoient une liste vide.
  /// Pour écrire, passer par `copyWith` sur la liste concernée : l'affectation
  /// générique demanderait de renoncer au typage de chaque section.
  List<CvEntry> entriesOf(CvSection section) => switch (section) {
    CvSection.personalInfo => personalInfo.links,
    CvSection.profile => const [],
    CvSection.experiences => experiences,
    CvSection.education => education,
    CvSection.skills => skills,
    CvSection.languages => languages,
    CvSection.certifications => certifications,
    CvSection.projects => projects,
    CvSection.interests => interests,
    CvSection.references => references,
  };

  /// Une section visible et effectivement remplie apparaît dans le CV.
  bool hasContent(CvSection section) => switch (section) {
    CvSection.profile => profile.trim().isNotEmpty,
    _ => entriesOf(section).isNotEmpty,
  };
}
