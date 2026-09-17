import 'package:flutter/material.dart';

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
