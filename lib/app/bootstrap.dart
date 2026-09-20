import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../features/cv/data/cv_repository.dart';
import '../features/cv/presentation/cv_library_provider.dart';
import 'cv_maker_app.dart';
import 'startup_failure_screen.dart';

/// L'application prête à s'afficher sur les CV de [repository].
///
/// La liste des CV est lue avant le premier affichage : le tableau de bord
/// s'ouvre directement complet, sans état de chargement.
///
/// Si cette lecture échoue — base verrouillée par une autre instance, fichier
/// endommagé, dossier de données inaccessible — l'application affiche à la
/// place un écran d'erreur avec « Réessayer », plutôt que de disparaître sans
/// un mot.
Future<Widget> bootstrap(CvRepository repository) async {
  try {
    return ProviderScope(
      overrides: await startupOverrides(repository),
      child: const CvMakerApp(),
    );
  } catch (error) {
    return StartupFailureApp(
      details: '$error',
      // Un nouveau `runApp` remplace la racine : réessayer repart donc d'une
      // lecture neuve, sans conserver l'état manquant.
      onRetry: () async => runApp(await bootstrap(repository)),
    );
  }
}

/// L'état de départ lu dans [repository] : le stockage et la liste des CV.
///
/// Aucun CV n'est ouvert, et donc aucun document décodé : un CV illisible ne
/// peut pas empêcher l'application de démarrer.
Future<List<Override>> startupOverrides(CvRepository repository) async => [
  cvRepositoryProvider.overrideWithValue(repository),
  initialCvLibraryProvider.overrideWithValue(await repository.list()),
];
