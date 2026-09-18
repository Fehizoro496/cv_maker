import '../domain/cv_certification.dart';
import '../domain/cv_custom_section.dart';
import '../domain/cv_date_range.dart';
import '../domain/cv_document.dart';
import '../domain/cv_education.dart';
import '../domain/cv_entry.dart';
import '../domain/cv_experience.dart';
import '../domain/cv_language.dart';
import '../domain/cv_month_year.dart';
import '../domain/cv_note.dart';
import '../domain/cv_personal_info.dart';
import '../domain/cv_project.dart';
import '../domain/cv_section.dart';
import '../domain/cv_skill.dart';

/// Relie les libellés affichés dans le formulaire au modèle typé du CV.
///
/// Le formulaire reste générique : il parcourt des descripteurs sans connaître
/// le type des éléments qu'il édite. Les conversions sont déclarées ici, une
/// seule fois par champ, ce qui évite de faire circuler des
/// `Map<String, String>` entre l'interface, l'historique et le générateur PDF.
///
/// Les transtypages présents dans les lectures et les écritures sont sûrs par
/// construction : un descripteur n'est utilisé que pour la section dont il
/// décrit les éléments. Le test miroir les exerce tous.

/// Un champ éditable d'un élément répétable.
sealed class CvEntryField {
  const CvEntryField(this.label);

  /// Libellé affiché au-dessus du champ.
  final String label;
}

/// Un champ de texte, sur une ou plusieurs lignes.
final class CvEntryTextField extends CvEntryField {
  const CvEntryTextField(
    super.label, {
    required this.read,
    required this.write,
    this.lines = 1,
  });

  final String Function(CvEntry entry) read;
  final CvEntry Function(CvEntry entry, String value) write;

  /// Nombre de lignes du champ ; au-delà de 1, le champ est multiligne.
  final int lines;
}

/// Un mois et une année, choisis dans le sélecteur plutôt que saisis.
final class CvEntryMonthYearField extends CvEntryField {
  const CvEntryMonthYearField(
    super.label, {
    required this.read,
    required this.write,
    this.isEnabled,
  });

  final CvMonthYear? Function(CvEntry entry) read;
  final CvEntry Function(CvEntry entry, CvMonthYear? value) write;

  /// Un champ désactivé reste visible mais non modifiable, comme la date de
  /// fin d'une expérience en cours.
  final bool Function(CvEntry entry)? isEnabled;
}

/// Une case à cocher.
final class CvEntryFlagField extends CvEntryField {
  const CvEntryFlagField(
    super.label, {
    required this.read,
    required this.write,
  });

  final bool Function(CvEntry entry) read;
  final CvEntry Function(CvEntry entry, bool value) write;
}

/// Un champ éditable rattaché au document lui-même, hors élément répétable.
final class CvDocumentField {
  const CvDocumentField(
    this.label, {
    required this.read,
    required this.write,
    this.lines = 1,
  });

  final String label;
  final String Function(CvDocument document) read;
  final CvDocument Function(CvDocument document, String value) write;
  final int lines;
}

/// Le formulaire d'une section à éléments répétables.
final class CvSectionForm {
  const CvSectionForm({
    required this.addLabel,
    required this.rows,
    required this.create,
    required this.read,
    required this.write,
  });

  /// Libellé du bouton d'ajout.
  final String addLabel;

  /// Disposition du formulaire : une liste par rangée de champs.
  final List<List<CvEntryField>> rows;

  /// Crée un élément vide portant [id].
  final CvEntry Function(String id) create;

  /// Les éléments de la section, dans l'ordre d'affichage.
  final List<CvEntry> Function(CvDocument document) read;

  /// Le document portant la nouvelle liste d'éléments.
  final CvDocument Function(CvDocument document, List<CvEntry> entries) write;

  /// Tous les champs, rangées confondues.
  List<CvEntryField> get fields => [for (final row in rows) ...row];

  /// Le champ dont la valeur résume l'élément lorsqu'il est replié.
  CvEntryField get titleField => rows.first.first;

  /// Le champ affiché à côté du titre dans le résumé, s'il existe.
  CvEntryField? get subtitleField =>
      rows.first.length > 1 ? rows.first[1] : null;

  /// Le document où l'élément [entry] remplace celui de même identifiant.
  CvDocument updated(CvDocument document, CvEntry entry) =>
      write(document, read(document).updated(entry));

  /// Le document augmenté d'un élément vide portant [id].
  CvDocument added(CvDocument document, String id) =>
      write(document, read(document).added(create(id)));

  /// Le document privé de l'élément [id].
  CvDocument removed(CvDocument document, String id) =>
      write(document, read(document).removed(id));

  /// Le document dont l'élément de [oldIndex] est déplacé en [newIndex].
  CvDocument reordered(CvDocument document, int oldIndex, int newIndex) =>
      write(document, read(document).reordered(oldIndex, newIndex));
}

/// Les champs du document, dans l'ordre du formulaire des informations
/// personnelles.
abstract final class CvDocumentFields {
  static const firstName = CvDocumentField(
    'Prénom',
    read: _readFirstName,
    write: _writeFirstName,
  );
  static const lastName = CvDocumentField(
    'Nom',
    read: _readLastName,
    write: _writeLastName,
  );
  static const headline = CvDocumentField(
    'Titre professionnel',
    read: _readHeadline,
    write: _writeHeadline,
  );
  static const location = CvDocumentField(
    'Localisation',
    read: _readLocation,
    write: _writeLocation,
  );
  static const phone = CvDocumentField(
    'Téléphone',
    read: _readPhone,
    write: _writePhone,
  );
  static const email = CvDocumentField(
    'E-mail',
    read: _readEmail,
    write: _writeEmail,
  );
  static const website = CvDocumentField(
    'Site / portfolio',
    read: _readWebsite,
    write: _writeWebsite,
  );
  static const profile = CvDocumentField(
    'Profil professionnel',
    read: _readProfile,
    write: _writeProfile,
    lines: 6,
  );

  /// Tous les champs du document, pour les tests et les parcours génériques.
  static const all = [
    firstName,
    lastName,
    headline,
    location,
    phone,
    email,
    website,
    profile,
  ];
}

String _readFirstName(CvDocument d) => d.personalInfo.firstName;
CvDocument _writeFirstName(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(firstName: v));
String _readLastName(CvDocument d) => d.personalInfo.lastName;
CvDocument _writeLastName(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(lastName: v));
String _readHeadline(CvDocument d) => d.personalInfo.headline;
CvDocument _writeHeadline(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(headline: v));
String _readLocation(CvDocument d) => d.personalInfo.location;
CvDocument _writeLocation(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(location: v));
String _readPhone(CvDocument d) => d.personalInfo.phone;
CvDocument _writePhone(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(phone: v));
String _readEmail(CvDocument d) => d.personalInfo.email;
CvDocument _writeEmail(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(email: v));
String _readWebsite(CvDocument d) => d.personalInfo.website;
CvDocument _writeWebsite(CvDocument d, String v) =>
    d.copyWith(personalInfo: d.personalInfo.copyWith(website: v));
String _readProfile(CvDocument d) => d.profile;
CvDocument _writeProfile(CvDocument d, String v) => d.copyWith(profile: v);

/// Le formulaire de chaque section à éléments répétables.
///
/// [CvSection.profile] n'y figure pas : elle n'a pas d'éléments répétables et
/// s'édite avec [CvDocumentFields.profile].
final cvSectionForms = <CvSection, CvSectionForm>{
  CvSection.personalInfo: CvSectionForm(
    addLabel: 'Ajouter un lien',
    create: (id) => CvLink(id: id),
    read: (d) => d.personalInfo.links,
    write: (d, entries) => d.copyWith(
      personalInfo: d.personalInfo.copyWith(links: entries.cast<CvLink>()),
    ),
    rows: [
      [
        CvEntryTextField(
          'Libellé',
          read: (e) => (e as CvLink).label,
          write: (e, v) => (e as CvLink).copyWith(label: v),
        ),
        CvEntryTextField(
          'URL',
          read: (e) => (e as CvLink).url,
          write: (e, v) => (e as CvLink).copyWith(url: v),
        ),
      ],
    ],
  ),
  CvSection.experiences: CvSectionForm(
    addLabel: 'Ajouter une expérience',
    create: (id) => CvExperience(id: id),
    read: (d) => d.experiences,
    write: (d, entries) =>
        d.copyWith(experiences: entries.cast<CvExperience>()),
    rows: [
      [
        CvEntryTextField(
          'Poste',
          read: (e) => (e as CvExperience).position,
          write: (e, v) => (e as CvExperience).copyWith(position: v),
        ),
        CvEntryTextField(
          'Entreprise',
          read: (e) => (e as CvExperience).company,
          write: (e, v) => (e as CvExperience).copyWith(company: v),
        ),
      ],
      [
        CvEntryTextField(
          'Lieu',
          read: (e) => (e as CvExperience).location,
          write: (e, v) => (e as CvExperience).copyWith(location: v),
        ),
        CvEntryMonthYearField(
          'Début',
          read: (e) => (e as CvExperience).period.start,
          write: (e, v) => _experience(e, (p) => p.copyWith(start: v)),
        ),
        CvEntryMonthYearField(
          'Fin',
          read: (e) => (e as CvExperience).period.end,
          write: (e, v) => _experience(e, (p) => p.copyWith(end: v)),
          isEnabled: (e) => !(e as CvExperience).period.isCurrent,
        ),
      ],
      [
        CvEntryFlagField(
          'En cours',
          read: (e) => (e as CvExperience).period.isCurrent,
          write: (e, v) => _experience(e, (p) => p.copyWith(isCurrent: v)),
        ),
      ],
      [
        CvEntryTextField(
          'Description / réalisations',
          read: (e) => (e as CvExperience).description,
          write: (e, v) => (e as CvExperience).copyWith(description: v),
          lines: 4,
        ),
      ],
    ],
  ),
  CvSection.education: CvSectionForm(
    addLabel: 'Ajouter une formation',
    create: (id) => CvEducation(id: id),
    read: (d) => d.education,
    write: (d, entries) => d.copyWith(education: entries.cast<CvEducation>()),
    rows: [
      [
        CvEntryTextField(
          'Diplôme',
          read: (e) => (e as CvEducation).degree,
          write: (e, v) => (e as CvEducation).copyWith(degree: v),
        ),
        CvEntryTextField(
          'Établissement',
          read: (e) => (e as CvEducation).school,
          write: (e, v) => (e as CvEducation).copyWith(school: v),
        ),
      ],
      [
        CvEntryTextField(
          'Lieu',
          read: (e) => (e as CvEducation).location,
          write: (e, v) => (e as CvEducation).copyWith(location: v),
        ),
        CvEntryMonthYearField(
          'Début',
          read: (e) => (e as CvEducation).period.start,
          write: (e, v) => _education(e, (p) => p.copyWith(start: v)),
        ),
        CvEntryMonthYearField(
          'Fin',
          read: (e) => (e as CvEducation).period.end,
          write: (e, v) => _education(e, (p) => p.copyWith(end: v)),
        ),
      ],
      [
        CvEntryTextField(
          'Description (facultative)',
          read: (e) => (e as CvEducation).description,
          write: (e, v) => (e as CvEducation).copyWith(description: v),
          lines: 4,
        ),
      ],
    ],
  ),
  CvSection.skills: CvSectionForm(
    addLabel: 'Ajouter une compétence',
    create: (id) => CvSkill(id: id),
    read: (d) => d.skills,
    write: (d, entries) => d.copyWith(skills: entries.cast<CvSkill>()),
    rows: [
      [
        CvEntryTextField(
          'Nom',
          read: (e) => (e as CvSkill).name,
          write: (e, v) => (e as CvSkill).copyWith(name: v),
        ),
        CvEntryTextField(
          'Catégorie (facultative)',
          read: (e) => (e as CvSkill).category,
          write: (e, v) => (e as CvSkill).copyWith(category: v),
        ),
      ],
      [
        CvEntryTextField(
          'Niveau (facultatif)',
          read: (e) => (e as CvSkill).level,
          write: (e, v) => (e as CvSkill).copyWith(level: v),
        ),
      ],
    ],
  ),
  CvSection.languages: CvSectionForm(
    addLabel: 'Ajouter une langue',
    create: (id) => CvLanguage(id: id),
    read: (d) => d.languages,
    write: (d, entries) => d.copyWith(languages: entries.cast<CvLanguage>()),
    rows: [
      [
        CvEntryTextField(
          'Langue',
          read: (e) => (e as CvLanguage).name,
          write: (e, v) => (e as CvLanguage).copyWith(name: v),
        ),
        CvEntryTextField(
          'Niveau',
          read: (e) => (e as CvLanguage).level,
          write: (e, v) => (e as CvLanguage).copyWith(level: v),
        ),
      ],
    ],
  ),
  CvSection.certifications: CvSectionForm(
    addLabel: 'Ajouter une certification',
    create: (id) => CvCertification(id: id),
    read: (d) => d.certifications,
    write: (d, entries) =>
        d.copyWith(certifications: entries.cast<CvCertification>()),
    rows: [
      [
        CvEntryTextField(
          'Intitulé',
          read: (e) => (e as CvCertification).name,
          write: (e, v) => (e as CvCertification).copyWith(name: v),
        ),
        CvEntryTextField(
          'Organisme',
          read: (e) => (e as CvCertification).issuer,
          write: (e, v) => (e as CvCertification).copyWith(issuer: v),
        ),
      ],
      [
        CvEntryMonthYearField(
          'Date',
          read: (e) => (e as CvCertification).date,
          write: (e, v) => (e as CvCertification).copyWith(date: v),
        ),
      ],
      [
        CvEntryTextField(
          'Description',
          read: (e) => (e as CvCertification).description,
          write: (e, v) => (e as CvCertification).copyWith(description: v),
          lines: 4,
        ),
      ],
    ],
  ),
  CvSection.projects: CvSectionForm(
    addLabel: 'Ajouter un projet',
    create: (id) => CvProject(id: id),
    read: (d) => d.projects,
    write: (d, entries) => d.copyWith(projects: entries.cast<CvProject>()),
    rows: [
      [
        CvEntryTextField(
          'Intitulé',
          read: (e) => (e as CvProject).name,
          write: (e, v) => (e as CvProject).copyWith(name: v),
        ),
        CvEntryTextField(
          'Rôle',
          read: (e) => (e as CvProject).role,
          write: (e, v) => (e as CvProject).copyWith(role: v),
        ),
      ],
      [
        CvEntryTextField(
          'Lien',
          read: (e) => (e as CvProject).url,
          write: (e, v) => (e as CvProject).copyWith(url: v),
        ),
        CvEntryMonthYearField(
          'Début',
          read: (e) => (e as CvProject).period.start,
          write: (e, v) => _project(e, (p) => p.copyWith(start: v)),
        ),
        CvEntryMonthYearField(
          'Fin',
          read: (e) => (e as CvProject).period.end,
          write: (e, v) => _project(e, (p) => p.copyWith(end: v)),
        ),
      ],
      [
        CvEntryTextField(
          'Description',
          read: (e) => (e as CvProject).description,
          write: (e, v) => (e as CvProject).copyWith(description: v),
          lines: 4,
        ),
      ],
    ],
  ),
  CvSection.interests: CvSectionForm(
    addLabel: "Ajouter un centre d'intérêt",
    create: (id) => CvNote(id: id),
    read: (d) => d.interests,
    write: (d, entries) => d.copyWith(interests: entries.cast<CvNote>()),
    rows: _noteRows,
  ),
  CvSection.references: CvSectionForm(
    addLabel: 'Ajouter une référence',
    create: (id) => CvNote(id: id),
    read: (d) => d.references,
    write: (d, entries) => d.copyWith(references: entries.cast<CvNote>()),
    rows: _noteRows,
  ),
};

/// Le formulaire de [section], standard ou personnalisée, dans [document].
///
/// `null` pour les sections sans éléments répétables : le profil, une section
/// personnalisée de texte libre ou une section personnalisée inconnue.
CvSectionForm? cvSectionFormOf(CvSectionRef section, CvDocument document) =>
    switch (section) {
      CvSection() => cvSectionForms[section],
      CvCustomSectionRef(:final id) => switch (document.customSectionById(id)) {
        final custom? => customSectionForm(custom),
        null => null,
      },
    };

/// Le formulaire d'une section personnalisée, selon son type.
///
/// Les éléments s'éditent avec les mêmes composants que les sections standard
/// dont ils reprennent la forme : une liste datée comme les expériences, une
/// liste simple comme les certifications. Un texte libre n'a pas de formulaire
/// de liste.
CvSectionForm? customSectionForm(CvCustomSection section) {
  final id = section.id;
  final rows = switch (section.type) {
    CvCustomSectionType.freeText => null,
    CvCustomSectionType.datedList => _datedItemRows,
    CvCustomSectionType.simpleList => _simpleItemRows,
  };
  if (rows == null) return null;
  return CvSectionForm(
    addLabel: 'Ajouter un élément',
    create: (itemId) => CvCustomItem(id: itemId),
    read: (d) => d.customSectionById(id)?.items ?? const [],
    write: (d, entries) => d.withCustomSection(
      id,
      (custom) => custom.copyWith(items: entries.cast<CvCustomItem>()),
    ),
    rows: rows,
  );
}

List<List<CvEntryField>> get _datedItemRows => [
  [
    CvEntryTextField(
      'Titre',
      read: (e) => (e as CvCustomItem).title,
      write: (e, v) => (e as CvCustomItem).copyWith(title: v),
    ),
    CvEntryTextField(
      'Sous-titre',
      read: (e) => (e as CvCustomItem).subtitle,
      write: (e, v) => (e as CvCustomItem).copyWith(subtitle: v),
    ),
  ],
  [
    CvEntryMonthYearField(
      'Début',
      read: (e) => (e as CvCustomItem).period.start,
      write: (e, v) => _customItem(e, (p) => p.copyWith(start: v)),
    ),
    CvEntryMonthYearField(
      'Fin',
      read: (e) => (e as CvCustomItem).period.end,
      write: (e, v) => _customItem(e, (p) => p.copyWith(end: v)),
      isEnabled: (e) => !(e as CvCustomItem).period.isCurrent,
    ),
  ],
  [
    CvEntryFlagField(
      'En cours',
      read: (e) => (e as CvCustomItem).period.isCurrent,
      write: (e, v) => _customItem(e, (p) => p.copyWith(isCurrent: v)),
    ),
  ],
  [
    CvEntryTextField(
      'Description',
      read: (e) => (e as CvCustomItem).description,
      write: (e, v) => (e as CvCustomItem).copyWith(description: v),
      lines: 4,
    ),
  ],
];

List<List<CvEntryField>> get _simpleItemRows => [
  [
    CvEntryTextField(
      'Titre',
      read: (e) => (e as CvCustomItem).title,
      write: (e, v) => (e as CvCustomItem).copyWith(title: v),
    ),
  ],
  [
    CvEntryTextField(
      'Description courte',
      read: (e) => (e as CvCustomItem).description,
      write: (e, v) => (e as CvCustomItem).copyWith(description: v),
      lines: 2,
    ),
  ],
];

CvCustomItem _customItem(
  CvEntry entry,
  CvDateRange Function(CvDateRange period) change,
) {
  final item = entry as CvCustomItem;
  return item.copyWith(period: change(item.period));
}

/// Réécrit la période d'un élément sans répéter le transtypage.
CvExperience _experience(
  CvEntry entry,
  CvDateRange Function(CvDateRange period) change,
) {
  final experience = entry as CvExperience;
  return experience.copyWith(period: change(experience.period));
}

CvEducation _education(
  CvEntry entry,
  CvDateRange Function(CvDateRange period) change,
) {
  final education = entry as CvEducation;
  return education.copyWith(period: change(education.period));
}

CvProject _project(
  CvEntry entry,
  CvDateRange Function(CvDateRange period) change,
) {
  final project = entry as CvProject;
  return project.copyWith(period: change(project.period));
}

/// Les centres d'intérêt et les références partagent le modèle [CvNote].
List<List<CvEntryField>> get _noteRows => [
  [
    CvEntryTextField(
      'Intitulé',
      read: (e) => (e as CvNote).label,
      write: (e, v) => (e as CvNote).copyWith(label: v),
    ),
  ],
  [
    CvEntryTextField(
      'Description',
      read: (e) => (e as CvNote).description,
      write: (e, v) => (e as CvNote).copyWith(description: v),
      lines: 4,
    ),
  ],
];
