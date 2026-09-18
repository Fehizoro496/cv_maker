import 'package:flutter/material.dart';

import '../domain/cv_custom_section.dart';
import '../domain/cv_document.dart';
import '../domain/cv_section.dart';

extension CvSectionPresentation on CvSection {
  String get label => switch (this) {
    CvSection.personalInfo => 'Informations personnelles',
    CvSection.profile => 'Profil professionnel',
    CvSection.experiences => 'Expériences',
    CvSection.education => 'Formations',
    CvSection.skills => 'Compétences',
    CvSection.languages => 'Langues',
    CvSection.certifications => 'Certifications',
    CvSection.projects => 'Projets',
    CvSection.interests => "Centres d'intérêt",
    CvSection.references => 'Références',
  };

  /// Texte d'aide affiché sous le titre du formulaire.
  String get helpText => switch (this) {
    CvSection.personalInfo =>
      'Ces informations apparaissent en haut de votre CV.',
    CvSection.profile =>
      'Présentez-vous en quelques phrases : votre métier et ce que vous apportez.',
    CvSection.experiences =>
      'Commencez par la plus récente. Faites glisser pour réordonner.',
    CvSection.education =>
      'Commencez par la plus récente. Faites glisser pour réordonner.',
    CvSection.skills =>
      'Listez vos compétences clés, éventuellement par catégorie.',
    CvSection.languages => 'Indiquez chaque langue et votre niveau.',
    CvSection.certifications => 'Ajoutez vos certifications et leur organisme.',
    CvSection.projects => 'Mettez en avant les projets les plus parlants.',
    CvSection.interests => "Quelques centres d'intérêt suffisent.",
    CvSection.references =>
      'Ajoutez vos références ou des informations complémentaires.',
  };

  IconData get icon => switch (this) {
    CvSection.personalInfo => Icons.person_outline,
    CvSection.profile => Icons.short_text,
    CvSection.experiences => Icons.work_outline,
    CvSection.education => Icons.school_outlined,
    CvSection.skills => Icons.bolt,
    CvSection.languages => Icons.translate,
    CvSection.certifications => Icons.verified_outlined,
    CvSection.projects => Icons.folder_outlined,
    CvSection.interests => Icons.interests_outlined,
    CvSection.references => Icons.group_outlined,
  };
}

/// Icône des sections personnalisées dans la navigation.
const customSectionIcon = Icons.label_outline;

/// Libellé, aide et icône d'une section, standard ou personnalisée.
///
/// Le nom d'une section personnalisée appartient au document : il faut donc
/// le lire dans [document].
extension CvSectionRefPresentation on CvSectionRef {
  String labelIn(CvDocument document) => switch (this) {
    final CvSection section => section.label,
    CvCustomSectionRef(:final id) => document.customSectionById(id)?.name ?? '',
  };

  String helpTextIn(CvDocument document) => switch (this) {
    final CvSection section => section.helpText,
    CvCustomSectionRef(:final id) =>
      document.customSectionById(id)?.summary ?? '',
  };

  IconData get icon => switch (this) {
    final CvSection section => section.icon,
    CvCustomSectionRef() => customSectionIcon,
  };
}

extension CvCustomSectionTypePresentation on CvCustomSectionType {
  String get label => switch (this) {
    CvCustomSectionType.freeText => 'Texte libre',
    CvCustomSectionType.datedList => 'Liste datée',
    CvCustomSectionType.simpleList => 'Liste simple',
  };

  /// Explication affichée dans le dialogue de création.
  String get explanation => switch (this) {
    CvCustomSectionType.freeText =>
      'Un paragraphe unique, comme le profil professionnel.',
    CvCustomSectionType.datedList =>
      'Titre, sous-titre, dates et description, comme les expériences.',
    CvCustomSectionType.simpleList =>
      'Titre et description courte, comme les certifications.',
  };

  IconData get icon => switch (this) {
    CvCustomSectionType.freeText => Icons.notes,
    CvCustomSectionType.datedList => Icons.event_note_outlined,
    CvCustomSectionType.simpleList => Icons.format_list_bulleted,
  };
}

extension CvCustomSectionPresentation on CvCustomSection {
  /// Le type et le nombre d'éléments : « Liste datée · 2 éléments ».
  ///
  /// Un texte libre n'a pas d'éléments à compter.
  String get summary => type.hasItems
      ? '${type.label} · ${elementCountLabel(items.length)}'
      : type.label;
}

/// « 1 élément », « 2 éléments ».
String elementCountLabel(int count) =>
    count <= 1 ? '$count élément' : '$count éléments';

/// Le message d'erreur du nom d'une section personnalisée, ou `null` s'il est
/// valide.
///
/// Le nom doit être unique parmi toutes les sections du CV, standard comprises,
/// sans tenir compte de la casse ni des espaces en bordure : deux sections
/// « Publications » et « publications » seraient indiscernables dans le PDF.
/// [exceptId] exclut la section renommée de la comparaison.
String? customSectionNameError(
  String name,
  CvDocument document, {
  String? exceptId,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Donnez un nom à la section.';
  if (trimmed.length > CvCustomSection.maxNameLength) {
    return '${CvCustomSection.maxNameLength} caractères au maximum.';
  }
  final key = trimmed.toLowerCase();
  final taken = [
    for (final section in CvSection.values) section.label,
    for (final custom in document.customSections)
      if (custom.id != exceptId) custom.name,
  ];
  if (taken.any((other) => other.trim().toLowerCase() == key)) {
    return 'Une section porte déjà ce nom.';
  }
  return null;
}
