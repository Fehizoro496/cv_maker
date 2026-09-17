import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_section.dart';
import '../domain/cv_design.dart';

/// Editable, in-memory example used by the editor until local storage is added.
class EditorDraft {
  EditorDraft({
    required Map<String, String> fields,
    required Map<CvSection, List<Map<String, String>>> entries,
    this.photo,
    this.design = CvDesign.professional,
  }) : fields = Map.unmodifiable(fields),
       entries = Map.unmodifiable(
         entries.map(
           (key, value) => MapEntry(
             key,
             List<Map<String, String>>.unmodifiable(
               value.map(Map<String, String>.unmodifiable),
             ),
           ),
         ),
       );

  final Map<String, String> fields;
  final Map<CvSection, List<Map<String, String>>> entries;
  final Uint8List? photo;
  final CvDesign design;

  String get name => '${fields['Prénom'] ?? ''} ${fields['Nom'] ?? ''}'.trim();

  factory EditorDraft.example() => EditorDraft(
    fields: {
      'Prénom': 'Camille',
      'Nom': 'Moreau',
      'Titre professionnel': 'Développeuse Front-End',
      'Localisation': 'Lyon, France',
      'Téléphone': '+33 6 12 34 56 78',
      'E-mail': 'camille.moreau@email.fr',
      'Site / portfolio': 'camille-moreau.fr',
      'Profil professionnel':
          "Développeuse front-end avec 5 ans d'expérience sur des applications web et de bureau. Spécialisée en Flutter et TypeScript, attentive à l'accessibilité et aux performances.",
    },
    entries: {
      CvSection.personalInfo: [
        {
          'id': 'link-1',
          'Libellé': 'LinkedIn',
          'URL': 'linkedin.com/in/camillemoreau',
        },
      ],
      CvSection.experiences: [
        {
          'id': 'exp-1',
          'Poste': 'Développeuse Front-End',
          'Entreprise': 'Nexora',
          'Lieu': 'Lyon, France',
          'Début': 'sept. 2023',
          'Fin': '',
          'En cours': 'true',
          'Description / réalisations':
              '• Refonte du portail client (Flutter Web).\n• Réduction du temps de chargement de 38 %.\n• Collaboration avec les équipes produit et design.',
        },
        {
          'id': 'exp-2',
          'Poste': 'Développeuse Web',
          'Entreprise': 'Atelier Kipli',
          'Lieu': 'Lyon',
          'Début': 'janv. 2021',
          'Fin': 'août 2023',
          'Description / réalisations':
              'Création du design system interne utilisé par 4 équipes.',
        },
        {
          'id': 'exp-3',
          'Poste': 'Intégratrice Web',
          'Entreprise': 'Studio Vertige',
          'Lieu': 'Lyon',
          'Début': 'sept. 2019',
          'Fin': 'déc. 2020',
          'Description / réalisations':
              'Intégration de 20+ sites vitrines, alternance.',
        },
      ],
      CvSection.education: [
        {
          'id': 'edu-1',
          'Diplôme': 'Master Informatique',
          'Établissement': 'Université Lyon 1',
          'Début': '2019',
          'Fin': '2021',
        },
        {
          'id': 'edu-2',
          'Diplôme': 'Licence MIAGE',
          'Établissement': 'Université Lyon 2',
          'Début': '2016',
          'Fin': '2019',
        },
      ],
      CvSection.skills: [
        for (final name in [
          'Flutter',
          'Dart',
          'TypeScript',
          'React',
          'HTML/CSS',
          'Tests',
          'Git',
          'Figma',
          'Accessibilité',
        ])
          {'id': 'skill-$name', 'Nom': name},
      ],
      CvSection.languages: [
        {'id': 'lang-1', 'Langue': 'Français', 'Niveau': 'langue maternelle'},
        {'id': 'lang-2', 'Langue': 'Anglais', 'Niveau': 'C1'},
        {'id': 'lang-3', 'Langue': 'Espagnol', 'Niveau': 'B1'},
      ],
    },
  );
}

final editorDraftProvider = NotifierProvider<EditorDraftNotifier, EditorDraft>(
  EditorDraftNotifier.new,
);

class EditorDraftNotifier extends Notifier<EditorDraft> {
  final _past = <EditorDraft>[];
  final _future = <EditorDraft>[];
  String? _lastField;
  DateTime? _lastEdit;
  int _nextId = 0;
  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  @override
  EditorDraft build() => EditorDraft.example();

  void _commit(EditorDraft next, [String? field]) {
    final now = DateTime.now();
    if (field == null ||
        field != _lastField ||
        _lastEdit == null ||
        now.difference(_lastEdit!) > const Duration(milliseconds: 900)) {
      _past.add(state);
      if (_past.length > 50) _past.removeAt(0);
    }
    _future.clear();
    _lastField = field;
    _lastEdit = now;
    state = next;
  }

  void setField(String label, String value) {
    if ((state.fields[label] ?? '') == value) return;
    _commit(
      EditorDraft(
        fields: {...state.fields, label: value},
        entries: state.entries,
        photo: state.photo,
        design: state.design,
      ),
      label,
    );
  }

  void setPhoto(Uint8List? photo) => _commit(
    EditorDraft(
      fields: state.fields,
      entries: state.entries,
      photo: photo,
      design: state.design,
    ),
  );

  void setDesign(CvDesign design) {
    if (state.design == design) return;
    _commit(
      EditorDraft(
        fields: state.fields,
        entries: state.entries,
        photo: state.photo,
        design: design,
      ),
    );
  }

  void setEntry(CvSection section, String id, String field, String value) {
    final matches = (state.entries[section] ?? <Map<String, String>>[]).where(
      (entry) => entry['id'] == id,
    );
    if (matches.isEmpty || (matches.first[field] ?? '') == value) return;
    final entries = [
      for (final entry in state.entries[section] ?? <Map<String, String>>[])
        if (entry['id'] == id) {...entry, field: value} else entry,
    ];
    _setEntries(section, entries, '$id/$field');
  }

  void _setEntries(
    CvSection section,
    List<Map<String, String>> entries, [
    String? field,
  ]) => _commit(
    EditorDraft(
      fields: state.fields,
      entries: {...state.entries, section: entries},
      photo: state.photo,
      design: state.design,
    ),
    field,
  );

  String add(CvSection section) {
    final id = 'new-${_nextId++}';
    _setEntries(section, [
      ...?state.entries[section],
      {'id': id},
    ]);
    return id;
  }

  void remove(CvSection section, String id) => _setEntries(
    section,
    [...?state.entries[section]].where((entry) => entry['id'] != id).toList(),
  );

  void reorder(CvSection section, int oldIndex, int newIndex) {
    final entries = [...?state.entries[section]];
    entries.insert(newIndex, entries.removeAt(oldIndex));
    _setEntries(section, entries);
  }

  void undo() {
    if (!canUndo) return;
    _future.add(state);
    _lastField = null;
    state = _past.removeLast();
  }

  void redo() {
    if (!canRedo) return;
    _past.add(state);
    _lastField = null;
    state = _future.removeLast();
  }
}
