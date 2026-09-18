import 'package:cv_maker/features/cv/domain/cv_certification.dart';
import 'package:cv_maker/features/cv/domain/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_education.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_experience.dart';
import 'package:cv_maker/features/cv/domain/cv_language.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/cv_note.dart';
import 'package:cv_maker/features/cv/domain/cv_project.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/domain/cv_skill.dart';

/// Une description longue, sur plusieurs lignes, pour éprouver la pagination.
String _description(int index) => [
  'Réalisation nº $index : refonte complète du parcours, de la prise de '
      'besoin jusqu’à la mise en production, avec reprise de données.',
  '• Réduction du temps de chargement de 38 % sur les pages critiques.',
  '• Accompagnement de quatre équipes sur les conventions d’accessibilité.',
  '• Rédaction de la documentation technique et des guides de contribution.',
].join('\n');

/// Un CV dont **seule** [section] est remplie, avec [count] éléments longs.
///
/// Les autres sections répétables sont vidées : ce qui paginé vient donc bien
/// de la section éprouvée, et non du CV d'exemple.
///
/// Les informations personnelles restent renseignées : elles constituent
/// l'en-tête, présent dans tous les cas.
CvDocument longCvFor(CvSection section, {int count = 12}) {
  final empty = exampleCvDocument().copyWith(
    profile: '',
    experiences: const [],
    education: const [],
    skills: const [],
    languages: const [],
    certifications: const [],
    projects: const [],
    interests: const [],
    references: const [],
  );
  return switch (section) {
    // L'en-tête porte les informations personnelles : leurs liens suffisent.
    CvSection.personalInfo => empty,
    CvSection.profile => empty.copyWith(
      profile: List.generate(count, _description).join('\n'),
    ),
    CvSection.experiences => empty.copyWith(
      experiences: [
        for (var i = 0; i < count; i++)
          CvExperience(
            id: 'exp-$i',
            position: 'Développeuse front-end nº $i',
            company: 'Entreprise nº $i',
            location: 'Lyon, France',
            period: CvDateRange(
              start: CvMonthYear(2010 + i % 15, 1 + i % 12),
              isCurrent: i == 0,
              end: i == 0 ? null : CvMonthYear(2012 + i % 15, 1 + i % 12),
            ),
            description: _description(i),
          ),
      ],
    ),
    CvSection.education => empty.copyWith(
      education: [
        for (var i = 0; i < count; i++)
          CvEducation(
            id: 'edu-$i',
            degree: 'Master informatique, parcours nº $i',
            school: 'Université de Lyon nº $i',
            location: 'Lyon',
            period: CvDateRange(
              start: CvMonthYear(2010 + i % 15),
              end: CvMonthYear(2012 + i % 15),
            ),
            description: _description(i),
          ),
      ],
    ),
    CvSection.skills => empty.copyWith(
      skills: [
        for (var i = 0; i < count; i++)
          CvSkill(
            id: 'skill-$i',
            name: 'Compétence technique détaillée nº $i',
            category: 'Catégorie nº ${i % 4}',
            level: 'Avancé',
          ),
      ],
    ),
    CvSection.languages => empty.copyWith(
      languages: [
        for (var i = 0; i < count; i++)
          CvLanguage(
            id: 'lang-$i',
            name: 'Langue parlée et écrite nº $i',
            level: 'Niveau C1 certifié',
          ),
      ],
    ),
    CvSection.certifications => empty.copyWith(
      certifications: [
        for (var i = 0; i < count; i++)
          CvCertification(
            id: 'cert-$i',
            name: 'Certification professionnelle nº $i',
            issuer: 'Organisme certificateur nº $i',
            date: CvMonthYear(2015 + i % 10, 1 + i % 12),
            description: _description(i),
          ),
      ],
    ),
    CvSection.projects => empty.copyWith(
      projects: [
        for (var i = 0; i < count; i++)
          CvProject(
            id: 'proj-$i',
            name: 'Projet open source nº $i',
            role: 'Conception et développement',
            url: 'github.com/exemple/projet-$i',
            period: CvDateRange(start: CvMonthYear(2018 + i % 8, 1 + i % 12)),
            description: _description(i),
          ),
      ],
    ),
    CvSection.interests => empty.copyWith(
      interests: [
        for (var i = 0; i < count; i++)
          CvNote(
            id: 'int-$i',
            label: 'Centre d’intérêt nº $i',
            description: _description(i),
          ),
      ],
    ),
    CvSection.references => empty.copyWith(
      references: [
        for (var i = 0; i < count; i++)
          CvNote(
            id: 'ref-$i',
            label: 'Référence professionnelle nº $i',
            description: _description(i),
          ),
      ],
    ),
  };
}
