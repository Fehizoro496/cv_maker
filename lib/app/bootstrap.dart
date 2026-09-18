import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../features/cv/data/cv_repository.dart';
import '../features/cv/domain/cv_document.dart';
import '../features/cv/presentation/cv_library_provider.dart';
import '../features/cv/presentation/cv_session_provider.dart';
import 'cv_maker_app.dart';

/// L'application prête à s'afficher sur les CV de [repository].
///
/// La liste des CV et le dernier modifié sont lus avant le premier affichage :
/// l'éditeur s'ouvre directement sur ce CV, sans état de chargement. Sans CV
/// enregistré, c'est l'écran d'accueil qui s'affiche.
Future<Widget> bootstrap(CvRepository repository) async => ProviderScope(
  overrides: await startupOverrides(repository),
  child: const CvMakerApp(),
);

/// L'état de départ lu dans [repository] : le stockage, la liste des CV et
/// le dernier modifié, avec un historique vide.
Future<List<Override>> startupOverrides(CvRepository repository) async {
  final summaries = await repository.list();
  final last = await _firstReadable(repository, summaries.map((s) => s.id));
  return [
    cvRepositoryProvider.overrideWithValue(repository),
    initialCvLibraryProvider.overrideWithValue(summaries),
    if (last != null) initialCvDocumentProvider.overrideWithValue(last),
  ];
}

/// Le premier CV de [ids] qui se relit : un document illisible ne doit pas
/// empêcher l'application de démarrer.
Future<CvDocument?> _firstReadable(
  CvRepository repository,
  Iterable<String> ids,
) async {
  for (final id in ids) {
    try {
      final document = await repository.read(id);
      if (document != null) return document;
    } catch (_) {
      // JSON corrompu ou écrit par une version plus récente : on passe au
      // suivant. Il reste listé, et son ouverture signalera l'échec.
      continue;
    }
  }
  return null;
}
