import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entries/cv_custom_section.dart';
import '../../domain/design/cv_design.dart';
import '../../domain/design/cv_design_spec.dart';
import '../../domain/document/cv_document.dart';
import '../../domain/entries/cv_entry.dart';
import '../../domain/document/cv_example.dart';
import '../../domain/document/cv_section.dart';
import '../../domain/session/cv_session.dart';
import '../editor/cv_section_forms.dart';

/// Le document de la session avant qu'un CV soit ouvert.
///
/// L'application démarre sur le tableau de bord : ce document n'est ni
/// affiché ni enregistré tant qu'aucun CV n'est ouvert. Les tests de
/// l'éditeur s'en servent pour partir directement du CV d'exemple.
final initialCvDocumentProvider = Provider<CvDocument>(
  (ref) => exampleCvDocument(),
);

/// Le CV ouvert, avec son historique d'annulation.
///
/// L'état est un [CvSession] : le document persistable et la photo de session,
/// empilés ensemble pour que l'annulation les restaure sans les désynchroniser.
///
/// Chaque CV ouvert pendant la session garde son propre historique et sa
/// propre photo : revenir sur un CV retrouve l'un et l'autre. Rien de tout
/// cela ne survit à la fermeture, seul le document est enregistré.
final cvSessionProvider = NotifierProvider<CvSessionNotifier, CvSession>(
  CvSessionNotifier.new,
);

/// L'état et l'historique d'un CV chargé pendant la session.
class _CvHistory {
  _CvHistory(this.session);

  CvSession session;
  final past = <CvSession>[];
  final future = <CvSession>[];
}

class CvSessionNotifier extends Notifier<CvSession> {
  final _histories = <String, _CvHistory>{};
  late _CvHistory _current;
  static const _maxHistory = 50;
  static const _coalesceWindow = Duration(milliseconds: 900);
  final _ids = const Uuid();
  String? _lastKey;
  DateTime? _lastEdit;

  bool get canUndo => _current.past.isNotEmpty;
  bool get canRedo => _current.future.isNotEmpty;

  @override
  CvSession build() {
    final document = ref.read(initialCvDocumentProvider);
    _current = _CvHistory(CvSession(document: document));
    _histories
      ..clear()
      ..[document.id] = _current;
    _lastKey = null;
    return _current.session;
  }

  CvDocument get document => state.document;

  /// Le dernier état connu du CV [id] s'il a été chargé pendant la session,
  /// modifications non encore enregistrées comprises.
  CvSession? loadedSession(String id) => _histories[id]?.session;

  /// Le document de [loadedSession].
  CvDocument? loadedDocument(String id) => loadedSession(id)?.document;

  /// Ouvre [document] à la place du CV courant.
  ///
  /// Un CV déjà chargé pendant la session reprend son dernier état, son
  /// historique et sa photo : [document] et [photo] ne servent qu'à un CV
  /// encore inconnu.
  void open(CvDocument document, {Uint8List? photo}) {
    load(document, photo: photo);
    final next = _histories[document.id]!;
    if (identical(next, _current)) return;
    _current = next;
    _lastKey = null;
    state = next.session;
  }

  /// Charge [document] et sa [photo] enregistrée sans les ouvrir, avec un
  /// historique vide ; sans effet s'il est déjà chargé.
  void load(CvDocument document, {Uint8List? photo}) => _histories.putIfAbsent(
    document.id,
    () => _CvHistory(CvSession(document: document, photo: photo)),
  );

  /// Oublie l'état et l'historique du CV [id], supprimé.
  ///
  /// Le CV courant reste affiché jusqu'à l'ouverture d'un autre : il n'y a
  /// pas de session sans CV.
  void forget(String id) {
    if (_histories[id] case final history? when !identical(history, _current)) {
      _histories.remove(id);
    }
  }

  /// Empile l'état de [history] puis lui applique [next].
  ///
  /// Deux modifications successives du CV courant portant la même
  /// [coalesceKey] et proches dans le temps ne forment qu'une seule étape
  /// d'historique : les frappes dans un même champ s'annulent d'un seul coup.
  void _commitTo(_CvHistory history, CvSession next, {String? coalesceKey}) {
    final isCurrent = identical(history, _current);
    final now = DateTime.now();
    final coalesces =
        isCurrent &&
        coalesceKey != null &&
        coalesceKey == _lastKey &&
        _lastEdit != null &&
        now.difference(_lastEdit!) <= _coalesceWindow;
    if (!coalesces) {
      history.past.add(history.session);
      if (history.past.length > _maxHistory) history.past.removeAt(0);
    }
    history.future.clear();
    history.session = next;
    if (!isCurrent) return;
    _lastKey = coalesceKey;
    _lastEdit = now;
    state = next;
  }

  void _commit(CvSession next, {String? coalesceKey}) =>
      _commitTo(_current, next, coalesceKey: coalesceKey);

  void _commitDocument(CvDocument next, {String? coalesceKey}) => _commit(
    state.copyWith(document: next.touched(DateTime.now())),
    coalesceKey: coalesceKey,
  );

  /// Renomme le CV [id], ouvert ou seulement chargé.
  ///
  /// Le renommage entre dans l'historique de ce CV : il s'annule comme toute
  /// autre modification, une fois le CV ouvert.
  void rename(String id, String name) {
    final history = _histories[id];
    final trimmed = name.trim();
    if (history == null || trimmed.isEmpty) return;
    final current = history.session.document;
    if (current.name == trimmed) return;
    _commitTo(
      history,
      history.session.copyWith(
        document: current.copyWith(name: trimmed).touched(DateTime.now()),
      ),
    );
  }

  /// Écrit un champ du document : nom, coordonnées, profil.
  void setDocumentField(CvDocumentField field, String value) {
    if (field.read(document) == value) return;
    _commitDocument(field.write(document, value), coalesceKey: field.label);
  }

  /// Remplace un élément répétable par sa version modifiée.
  ///
  /// [coalesceKey] regroupe les frappes d'un même champ d'un même élément.
  void updateEntry(CvSectionRef section, CvEntry entry, {String? coalesceKey}) {
    final form = cvSectionFormOf(section, document);
    if (form == null) return;
    final current = form.read(document).byId(entry.id);
    if (current == null || current == entry) return;
    _commitDocument(form.updated(document, entry), coalesceKey: coalesceKey);
  }

  /// Ajoute un élément vide et retourne son identifiant.
  String addEntry(CvSectionRef section) {
    final form = cvSectionFormOf(section, document);
    final id = _ids.v4();
    if (form == null) return id;
    _commitDocument(form.added(document, id));
    return id;
  }

  void removeEntry(CvSectionRef section, String id) {
    final form = cvSectionFormOf(section, document);
    if (form == null || form.read(document).byId(id) == null) return;
    _commitDocument(form.removed(document, id));
  }

  void reorderEntries(CvSectionRef section, int oldIndex, int newIndex) {
    final form = cvSectionFormOf(section, document);
    if (form == null) return;
    _commitDocument(form.reordered(document, oldIndex, newIndex));
  }

  /// Les éléments d'une section, dans leur ordre d'affichage.
  List<CvEntry> entriesOf(CvSectionRef section) =>
      cvSectionFormOf(section, document)?.read(document) ?? const [];

  /// Affiche ou masque une section facultative ou personnalisée.
  void setSectionVisible(CvSectionRef section, bool visible) {
    if (section is CvSection && !section.isOptional) return;
    if (document.isVisible(section) == visible) return;
    _commitDocument(document.withSectionVisible(section, visible));
  }

  /// Ajoute une section personnalisée visible à la fin du CV et retourne son
  /// identifiant.
  ///
  /// Le nom est validé par l'interface, qui connaît les libellés des sections
  /// standard ; il est seulement débarrassé de ses espaces superflus ici.
  String addCustomSection(String name, CvCustomSectionType type) {
    final id = _ids.v4();
    _commitDocument(
      document.copyWith(
        customSections: document.customSections.added(
          CvCustomSection(id: id, name: name.trim(), type: type),
        ),
      ),
    );
    return id;
  }

  void renameCustomSection(String id, String name) {
    final current = document.customSectionById(id);
    final trimmed = name.trim();
    if (current == null || current.name == trimmed) return;
    _commitDocument(
      document.withCustomSection(id, (s) => s.copyWith(name: trimmed)),
    );
  }

  /// Supprime une section personnalisée et tout son contenu.
  void removeCustomSection(String id) {
    if (document.customSectionById(id) == null) return;
    _commitDocument(
      document.copyWith(customSections: document.customSections.removed(id)),
    );
  }

  /// Écrit le paragraphe d'une section personnalisée de texte libre.
  void setCustomSectionText(String id, String text) {
    final current = document.customSectionById(id);
    if (current == null || current.text == text) return;
    _commitDocument(
      document.withCustomSection(id, (s) => s.copyWith(text: text)),
      coalesceKey: 'custom/$id/text',
    );
  }

  void setDesign(CvDesign design) {
    if (document.design == design) return;
    _commitDocument(document.withDesign(design));
  }

  /// Applique d'un seul geste le modèle et ses deux réglages.
  ///
  /// Les trois valeurs forment une seule étape d'historique : le catalogue les
  /// valide ensemble, une annulation les retire ensemble.
  void applyTemplate({
    required CvDesign design,
    required int accentArgb,
    required bool showPhoto,
  }) {
    final next = document.presentation.withTemplate(
      design: design,
      accentArgb: accentArgb,
      showPhoto: showPhoto,
    );
    if (next == document.presentation) return;
    _commitDocument(document.copyWith(presentation: next));
  }

  /// Impose la forme et la taille de la photo ; `null` rend la main au
  /// modèle.
  ///
  /// Des réglages rapprochés, comme plusieurs pressions sur « + », ne
  /// forment qu'une étape d'historique.
  void setPhotoFormat({required CvPhotoShape? shape, required double? sizeMm}) {
    final next = document.presentation.withPhotoFormat(
      shape: shape,
      sizeMm: sizeMm,
    );
    if (next == document.presentation) return;
    _commitDocument(
      document.copyWith(presentation: next),
      coalesceKey: 'photo/format',
    );
  }

  /// La photo n'est pas persistée : elle vit dans la session, pas le document.
  void setPhoto(Uint8List? photo) {
    if (state.photo == photo) return;
    _commit(CvSession(document: document, photo: photo));
  }

  void undo() {
    if (!canUndo) return;
    _current.future.add(state);
    _lastKey = null;
    state = _current.session = _current.past.removeLast();
  }

  void redo() {
    if (!canRedo) return;
    _current.past.add(state);
    _lastKey = null;
    state = _current.session = _current.future.removeLast();
  }
}
