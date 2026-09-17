import 'cv_certification.dart';
import 'cv_date_range.dart';
import 'cv_document.dart';
import 'cv_education.dart';
import 'cv_experience.dart';
import 'cv_language.dart';
import 'cv_month_year.dart';
import 'cv_note.dart';
import 'cv_personal_info.dart';
import 'cv_project.dart';
import 'cv_skill.dart';

/// CV d'exemple, identique d'un appel à l'autre.
///
/// Sert de point de départ dans l'éditeur et de jeu de données dans les tests :
/// toutes les sections sont remplies, y compris les facultatives, et les dates
/// sont fixes pour que les résultats restent comparables.
CvDocument exampleCvDocument() => CvDocument(
  id: 'example',
  name: 'CV de Camille Moreau',
  createdAt: DateTime.utc(2026, 1, 12),
  updatedAt: DateTime.utc(2026, 1, 12),
  personalInfo: const CvPersonalInfo(
    firstName: 'Camille',
    lastName: 'Moreau',
    headline: 'Développeuse Front-End',
    location: 'Lyon, France',
    phone: '+33 6 12 34 56 78',
    email: 'camille.moreau@email.fr',
    website: 'camille-moreau.fr',
    links: [
      CvLink(
        id: 'link-linkedin',
        label: 'LinkedIn',
        url: 'linkedin.com/in/camillemoreau',
      ),
    ],
  ),
  profile:
      "Développeuse front-end avec 5 ans d'expérience sur des applications web "
      'et de bureau. Spécialisée en Flutter et TypeScript, attentive à '
      "l'accessibilité et aux performances.",
  experiences: const [
    CvExperience(
      id: 'exp-nexora',
      position: 'Développeuse Front-End',
      company: 'Nexora',
      location: 'Lyon, France',
      period: CvDateRange(start: CvMonthYear(2023, 9), isCurrent: true),
      description:
          '• Refonte du portail client (Flutter Web).\n'
          '• Réduction du temps de chargement de 38 %.\n'
          '• Collaboration avec les équipes produit et design.',
    ),
    CvExperience(
      id: 'exp-kipli',
      position: 'Développeuse Web',
      company: 'Atelier Kipli',
      location: 'Lyon',
      period: CvDateRange(
        start: CvMonthYear(2021, 1),
        end: CvMonthYear(2023, 8),
      ),
      description: 'Création du design system interne utilisé par 4 équipes.',
    ),
    CvExperience(
      id: 'exp-vertige',
      position: 'Intégratrice Web',
      company: 'Studio Vertige',
      location: 'Lyon',
      period: CvDateRange(
        start: CvMonthYear(2019, 9),
        end: CvMonthYear(2020, 12),
      ),
      description: 'Intégration de 20+ sites vitrines, en alternance.',
    ),
  ],
  education: const [
    CvEducation(
      id: 'edu-master',
      degree: 'Master Informatique',
      school: 'Université Lyon 1',
      period: CvDateRange(start: CvMonthYear(2019), end: CvMonthYear(2021)),
    ),
    CvEducation(
      id: 'edu-licence',
      degree: 'Licence MIAGE',
      school: 'Université Lyon 2',
      period: CvDateRange(start: CvMonthYear(2016), end: CvMonthYear(2019)),
    ),
  ],
  skills: const [
    CvSkill(id: 'skill-flutter', name: 'Flutter', category: 'Développement'),
    CvSkill(id: 'skill-dart', name: 'Dart', category: 'Développement'),
    CvSkill(
      id: 'skill-typescript',
      name: 'TypeScript',
      category: 'Développement',
    ),
    CvSkill(id: 'skill-react', name: 'React', category: 'Développement'),
    CvSkill(id: 'skill-html', name: 'HTML/CSS', category: 'Développement'),
    CvSkill(id: 'skill-tests', name: 'Tests', category: 'Méthodes'),
    CvSkill(id: 'skill-git', name: 'Git', category: 'Méthodes'),
    CvSkill(id: 'skill-figma', name: 'Figma', category: 'Design'),
    CvSkill(id: 'skill-a11y', name: 'Accessibilité', category: 'Design'),
  ],
  languages: const [
    CvLanguage(id: 'lang-fr', name: 'Français', level: 'langue maternelle'),
    CvLanguage(id: 'lang-en', name: 'Anglais', level: 'C1'),
    CvLanguage(id: 'lang-es', name: 'Espagnol', level: 'B1'),
  ],
  certifications: const [
    CvCertification(
      id: 'cert-opquast',
      name: 'Opquast — Maîtrise de la qualité web',
      issuer: 'Opquast',
      date: CvMonthYear(2022, 6),
    ),
  ],
  projects: const [
    CvProject(
      id: 'proj-atlas',
      name: 'Atlas',
      role: 'Conception et développement',
      url: 'github.com/camillemoreau/atlas',
      period: CvDateRange(start: CvMonthYear(2024, 2)),
      description:
          'Bibliothèque de composants Flutter accessibles, 400 étoiles.',
    ),
  ],
  interests: const [
    CvNote(id: 'int-escalade', label: 'Escalade'),
    CvNote(
      id: 'int-typo',
      label: 'Typographie',
      description: 'Collection de spécimens imprimés.',
    ),
  ],
  references: const [
    CvNote(id: 'ref-nexora', label: 'Références disponibles sur demande'),
  ],
);
