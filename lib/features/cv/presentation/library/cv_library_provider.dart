import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cv_repository.dart';
import '../../domain/document/cv_summary.dart';
import '../session/cv_session_provider.dart';

/// Le stockage des CV, fourni au lancement de l'application.
///
/// Aucun stockage n'est ouvert par défaut : les tests qui n'enregistrent rien
/// n'ont pas à en fournir un, et ceux qui enregistrent le déclarent.
final cvRepositoryProvider = Provider<CvRepository>(
  (ref) => throw UnimplementedError(
    'cvRepositoryProvider doit être fourni au lancement.',
  ),
);

/// L'horloge des dates de modification, remplaçable dans les tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Les CV enregistrés au lancement.
///
/// Le lancement le remplace par la liste lue en base. Par défaut, le
/// document de départ de la session est le seul CV connu.
final initialCvLibraryProvider = Provider<List<CvSummary>>(
  (ref) => [CvSummary.of(ref.read(initialCvDocumentProvider))],
);

/// Les CV enregistrés, du plus récemment modifié au plus ancien.
///
/// La liste suit les écritures : elle est mise à jour après chaque
/// sauvegarde, création ou suppression réussie, et reflète donc la base.
final cvLibraryProvider = NotifierProvider<CvLibraryNotifier, List<CvSummary>>(
  CvLibraryNotifier.new,
);

class CvLibraryNotifier extends Notifier<List<CvSummary>> {
  @override
  List<CvSummary> build() =>
      [...ref.read(initialCvLibraryProvider)]..sortByRecency();

  void upsert(CvSummary summary) => state = state.upserted(summary);

  void remove(String id) => state = state.without(id);
}
