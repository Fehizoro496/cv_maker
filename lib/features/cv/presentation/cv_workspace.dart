import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/cv_repository.dart';
import '../domain/cv_document.dart';
import '../domain/cv_section.dart';
import '../domain/cv_summary.dart';
import 'cv_autosave.dart';
import 'cv_library_provider.dart';
import 'cv_session_provider.dart';
import 'selected_section_provider.dart';

/// Les opérations sur l'ensemble des CV : créer, ouvrir, renommer,
/// dupliquer, supprimer.
///
/// Chaque opération qui quitte le CV ouvert commence par écrire ses
/// modifications en attente.
final cvWorkspaceProvider = Provider<CvWorkspace>(CvWorkspace._);

class CvWorkspace {
  CvWorkspace._(this._ref);

  static const newCvName = 'Nouveau CV';

  final Ref _ref;
  final _ids = const Uuid();

  CvRepository get _repository => _ref.read(cvRepositoryProvider);
  CvAutosave get _autosave => _ref.read(cvAutosaveProvider);
  CvSessionNotifier get _session => _ref.read(cvSessionProvider.notifier);
  CvLibraryNotifier get _library => _ref.read(cvLibraryProvider.notifier);
  DateTime _now() => _ref.read(clockProvider)();

  String get openId => _ref.read(cvSessionProvider).document.id;

  /// Crée un CV vide, l'enregistre puis l'ouvre sur les informations
  /// personnelles.
  Future<void> create() async {
    final document = CvDocument.empty(
      id: _ids.v4(),
      now: _now(),
      name: newCvName,
    );
    await _autosave.run(() => _repository.save(document));
    _library.upsert(CvSummary.of(document));
    await _openDocument(document);
    _ref.read(selectedSectionProvider.notifier).select(CvSection.personalInfo);
  }

  /// Ouvre le CV [id] après avoir écrit les modifications en attente.
  ///
  /// Un échec d'écriture n'empêche pas de changer de CV : il est signalé par
  /// l'état de sauvegarde, et les modifications restent en attente.
  ///
  /// Retourne `false` si le CV n'existe plus.
  Future<bool> open(String id) async {
    if (id == openId) return true;
    final document = await _documentOf(id);
    if (document == null) return false;
    await _openDocument(document);
    return true;
  }

  /// Renomme le CV [id], ouvert ou non, et l'enregistre aussitôt.
  Future<void> rename(String id, String name) async {
    final document = await _documentOf(id);
    if (document == null) return;
    _session
      ..load(document)
      ..rename(id, name);
    final renamed = _session.loadedDocument(id)!;
    if (identical(renamed, document)) return;
    _autosave.schedule(renamed);
    await _autosave.flush();
  }

  /// Enregistre une copie du CV [id], sans l'ouvrir.
  Future<void> duplicate(String id) async {
    final source = await _documentOf(id);
    if (source == null) return;
    final now = _now();
    final copy = source.copyWith(
      id: _ids.v4(),
      name: '${source.name} (copie)',
      createdAt: now,
      updatedAt: now,
    );
    await _autosave.run(() => _repository.save(copy));
    _library.upsert(CvSummary.of(copy));
  }

  /// Supprime définitivement le CV [id].
  ///
  /// Supprimer le CV de la session charge à sa place le plus récemment
  /// modifié des autres.
  ///
  /// Retourne `true` s'il reste au moins un CV.
  Future<bool> delete(String id) async {
    _autosave.discard(id);
    await _autosave.run(() => _repository.delete(id));
    _library.remove(id);
    final remaining = _ref.read(cvLibraryProvider);
    if (id == openId && remaining.isNotEmpty) await open(remaining.first.id);
    _session.forget(id);
    return remaining.isNotEmpty;
  }

  /// Écrit les modifications en attente avant la fermeture de l'application.
  Future<bool> saveBeforeExit() => _autosave.flush();

  Future<void> _openDocument(CvDocument document) async {
    await _autosave.flush();
    _session.open(document);
  }

  /// Le CV [id] tel que la session le connaît, sinon tel qu'il est
  /// enregistré.
  Future<CvDocument?> _documentOf(String id) async =>
      _session.loadedDocument(id) ?? await _repository.read(id);
}
