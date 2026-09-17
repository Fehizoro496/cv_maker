import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/cv_design.dart';
import '../domain/cv_document.dart';
import '../domain/cv_entry.dart';
import '../domain/cv_example.dart';
import '../domain/cv_section.dart';
import '../domain/cv_session.dart';
import 'cv_section_forms.dart';

/// Le CV en cours d'édition, avec son historique d'annulation.
///
/// L'état est un [CvSession] : le document persistable et la photo de session,
/// empilés ensemble pour que l'annulation les restaure sans les désynchroniser.
///
/// La sauvegarde locale arrive au J5 ; jusque-là, la session part du CV
/// d'exemple et ne survit pas à la fermeture.
final cvSessionProvider = NotifierProvider<CvSessionNotifier, CvSession>(
  CvSessionNotifier.new,
);

/// La section sélectionnée n'a pas toujours d'éléments répétables.
CvSectionForm? cvSectionFormOf(CvSection section) => cvSectionForms[section];

class CvSessionNotifier extends Notifier<CvSession> {
  final _past = <CvSession>[];
  final _future = <CvSession>[];
  static const _maxHistory = 50;
  static const _coalesceWindow = Duration(milliseconds: 900);
  final _ids = const Uuid();
  String? _lastKey;
  DateTime? _lastEdit;

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  @override
  CvSession build() => CvSession(document: exampleCvDocument());

  CvDocument get document => state.document;

  /// Empile l'état courant puis applique [next].
  ///
  /// Deux modifications successives portant la même [coalesceKey] et proches
  /// dans le temps ne forment qu'une seule étape d'historique : les frappes
  /// dans un même champ s'annulent d'un seul coup.
  void _commit(CvSession next, {String? coalesceKey}) {
    final now = DateTime.now();
    final coalesces =
        coalesceKey != null &&
        coalesceKey == _lastKey &&
        _lastEdit != null &&
        now.difference(_lastEdit!) <= _coalesceWindow;
    if (!coalesces) {
      _past.add(state);
      if (_past.length > _maxHistory) _past.removeAt(0);
    }
    _future.clear();
    _lastKey = coalesceKey;
    _lastEdit = now;
    state = next;
  }

  void _commitDocument(CvDocument next, {String? coalesceKey}) => _commit(
    state.copyWith(document: next.touched(DateTime.now())),
    coalesceKey: coalesceKey,
  );

  /// Écrit un champ du document : nom, coordonnées, profil.
  void setDocumentField(CvDocumentField field, String value) {
    if (field.read(document) == value) return;
    _commitDocument(field.write(document, value), coalesceKey: field.label);
  }

  /// Remplace un élément répétable par sa version modifiée.
  ///
  /// [coalesceKey] regroupe les frappes d'un même champ d'un même élément.
  void updateEntry(CvSection section, CvEntry entry, {String? coalesceKey}) {
    final form = cvSectionForms[section];
    if (form == null) return;
    final current = form.read(document).byId(entry.id);
    if (current == null || current == entry) return;
    _commitDocument(form.updated(document, entry), coalesceKey: coalesceKey);
  }

  /// Ajoute un élément vide et retourne son identifiant.
  String addEntry(CvSection section) {
    final form = cvSectionForms[section];
    final id = _ids.v4();
    if (form == null) return id;
    _commitDocument(form.added(document, id));
    return id;
  }

  void removeEntry(CvSection section, String id) {
    final form = cvSectionForms[section];
    if (form == null || form.read(document).byId(id) == null) return;
    _commitDocument(form.removed(document, id));
  }

  void reorderEntries(CvSection section, int oldIndex, int newIndex) {
    final form = cvSectionForms[section];
    if (form == null) return;
    _commitDocument(form.reordered(document, oldIndex, newIndex));
  }

  /// Les éléments d'une section, dans leur ordre d'affichage.
  List<CvEntry> entriesOf(CvSection section) =>
      cvSectionForms[section]?.read(document) ?? const [];

  void setSectionVisible(CvSection section, bool visible) {
    if (!section.isOptional || document.isVisible(section) == visible) return;
    _commitDocument(document.withSectionVisible(section, visible));
  }

  void setDesign(CvDesign design) {
    if (document.design == design) return;
    _commitDocument(document.withDesign(design));
  }

  /// La photo n'est pas persistée : elle vit dans la session, pas le document.
  void setPhoto(Uint8List? photo) {
    if (state.photo == photo) return;
    _commit(CvSession(document: document, photo: photo));
  }

  void undo() {
    if (!canUndo) return;
    _future.add(state);
    _lastKey = null;
    state = _past.removeLast();
  }

  void redo() {
    if (!canRedo) return;
    _past.add(state);
    _lastKey = null;
    state = _future.removeLast();
  }
}
