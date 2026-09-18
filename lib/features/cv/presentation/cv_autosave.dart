import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_document.dart';
import '../domain/cv_summary.dart';
import 'cv_library_provider.dart';
import 'cv_session_provider.dart';

/// L'état de la sauvegarde, affiché dans l'en-tête du formulaire.
enum CvSaveStatus {
  /// Toutes les modifications sont enregistrées.
  saved,

  /// Des modifications attendent la fin de la saisie ou sont en cours
  /// d'écriture.
  saving,

  /// La dernière écriture a échoué. Les modifications restent en mémoire et
  /// seront retentées à la prochaine sauvegarde.
  error,
}

final cvSaveStatusProvider =
    NotifierProvider<CvSaveStatusNotifier, CvSaveStatus>(
      CvSaveStatusNotifier.new,
    );

class CvSaveStatusNotifier extends Notifier<CvSaveStatus> {
  @override
  CvSaveStatus build() => CvSaveStatus.saved;

  void set(CvSaveStatus status) => state = status;
}

/// La sauvegarde automatique du CV ouvert.
///
/// Elle écoute le document de la session et l'enregistre après une courte
/// pause dans la saisie ; une annulation ou un rétablissement est une
/// modification comme une autre. Ouvrir un autre CV n'en est pas une.
///
/// Elle n'est active que si l'application la lit : l'éditeur seul, dans les
/// tests, n'écrit rien.
final cvAutosaveProvider = Provider<CvAutosave>((ref) {
  final autosave = CvAutosave._(ref);
  ref.listen(cvSessionProvider.select((session) => session.document), (
    previous,
    next,
  ) {
    if (previous?.id == next.id) autosave.schedule(next);
  });
  ref.onDispose(autosave._dispose);
  return autosave;
});

class CvAutosave {
  CvAutosave._(this._ref);

  static const delay = Duration(milliseconds: 600);

  final Ref _ref;

  /// Les versions à écrire, une par CV : seule la plus récente compte.
  ///
  /// Un CV quitté avant l'écriture garde ici sa version, qui sera écrite avec
  /// les autres.
  final _pending = <String, CvDocument>{};
  Timer? _timer;

  /// Les écritures s'exécutent l'une après l'autre, dans l'ordre de leur
  /// demande : une écriture ne peut pas en doubler une plus récente.
  Future<void> _queue = Future.value();

  bool get hasPending => _pending.isNotEmpty;

  /// Programme l'écriture de [document] après [delay].
  void schedule(CvDocument document) {
    _pending[document.id] = document;
    _setStatus(CvSaveStatus.saving);
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  /// Renonce à écrire le CV [id], qui va être supprimé.
  void discard(String id) {
    _pending.remove(id);
    if (_pending.isEmpty) {
      _timer?.cancel();
      _timer = null;
      _setStatus(CvSaveStatus.saved);
    }
  }

  /// Écrit sans attendre toutes les versions en attente.
  ///
  /// Retourne `false` si une écriture a échoué : l'état passe alors en erreur
  /// et les versions non écrites restent en attente.
  Future<bool> flush() {
    _timer?.cancel();
    _timer = null;
    return run(() async {
      if (_pending.isEmpty) return true;
      _setStatus(CvSaveStatus.saving);
      try {
        for (final document in [..._pending.values]) {
          // La date d'écriture est celle de la modification enregistrée : un
          // état restauré par une annulation est plus récent que la version
          // qu'il remplace, même s'il reproduit un état plus ancien.
          final saved = document.touched(_ref.read(clockProvider)());
          await _ref.read(cvRepositoryProvider).save(saved);
          if (!_ref.mounted) return true;
          // Une frappe arrivée pendant l'écriture reste en attente.
          if (identical(_pending[document.id], document)) {
            _pending.remove(document.id);
          }
          _ref.read(cvLibraryProvider.notifier).upsert(CvSummary.of(saved));
        }
      } catch (_) {
        _setStatus(CvSaveStatus.error);
        return false;
      }
      _setStatus(_pending.isEmpty ? CvSaveStatus.saved : CvSaveStatus.saving);
      return true;
    });
  }

  /// Exécute [operation] à la suite des écritures en cours.
  ///
  /// Création, duplication et suppression y passent aussi : une suppression
  /// ne peut pas précéder l'écriture en cours du même CV, qui le recréerait.
  Future<T> run<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  void _setStatus(CvSaveStatus status) {
    if (_ref.mounted) _ref.read(cvSaveStatusProvider.notifier).set(status);
  }

  void _dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
