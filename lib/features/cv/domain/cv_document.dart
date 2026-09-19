import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_certification.dart';
import 'cv_custom_section.dart';
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

    /// Sections créées par l'utilisateur, dans leur ordre de création.
    @Default(<CvCustomSection>[]) List<CvCustomSection> customSections,
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
  /// d'accent et les réglages de la photo y sont déjà résolus.
  CvDesignSpec get designSpec => design.spec.withOverrides(
    accentColor: presentation.accentColor,
    showPhoto: presentation.showPhoto,
    photoShape: presentation.photoShape,
    photoSizeMm: presentation.photoSizeMm,
  );

  /// Une section facultative ou personnalisée peut être masquée.
  ///
  /// Une section personnalisée inconnue n'est pas visible.
  bool isVisible(CvSectionRef section) => switch (section) {
    CvSection() => presentation.isVisible(section),
    CvCustomSectionRef(:final id) => customSectionById(id)?.visible ?? false,
  };

  CvDocument withSectionVisible(CvSectionRef section, bool visible) =>
      switch (section) {
        CvSection() => copyWith(
          presentation: presentation.withSectionVisible(section, visible),
        ),
        CvCustomSectionRef(:final id) => withCustomSection(
          id,
          (custom) => custom.copyWith(visible: visible),
        ),
      };

  CvDocument withDesign(CvDesign design) =>
      copyWith(presentation: presentation.withDesign(design));

  /// La section personnalisée d'identifiant [id], ou `null`.
  CvCustomSection? customSectionById(String id) => customSections.byId(id);

  /// Le document où la section personnalisée [id] est remplacée par
  /// `change(section)`. Sans correspondance, le document est inchangé.
  CvDocument withCustomSection(
    String id,
    CvCustomSection Function(CvCustomSection section) change,
  ) {
    final current = customSectionById(id);
    if (current == null) return this;
    return copyWith(customSections: customSections.updated(change(current)));
  }

  /// Les éléments répétables de [section], en lecture seule.
  ///
  /// Les sections sans liste ([CvSection.profile], texte libre) renvoient une
  /// liste vide. Pour écrire, passer par `copyWith` sur la liste concernée :
  /// l'affectation générique demanderait de renoncer au typage de chaque
  /// section.
  List<CvEntry> entriesOf(CvSectionRef section) => switch (section) {
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
    CvCustomSectionRef(:final id) => customSectionById(id)?.items ?? const [],
  };

  /// Une section visible et effectivement remplie apparaît dans le CV.
  bool hasContent(CvSectionRef section) => switch (section) {
    CvSection.profile => profile.trim().isNotEmpty,
    CvCustomSectionRef(:final id) => customSectionById(id)?.hasContent ?? false,
    _ => entriesOf(section).isNotEmpty,
  };
}
