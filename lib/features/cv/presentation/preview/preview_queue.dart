import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sérialise les générations d'aperçus de modèles.
///
/// Les vignettes sont demandées d'un bloc à l'ouverture du catalogue. Composer
/// un PDF est un travail purement processeur, sur le même fil que l'interface :
/// les laisser s'entrelacer retardait chaque vignette jusqu'à ce que toutes
/// soient prêtes. En file, elles apparaissent l'une après l'autre, et la
/// première s'affiche presque aussitôt.
///
/// L'aperçu du CV réel ne passe pas par cette file : il est seul de son espèce
/// et ne doit pas attendre derrière les vignettes.
final previewQueueProvider = Provider<PreviewQueue>((ref) => PreviewQueue());

class PreviewQueue {
  Future<void> _tail = Future.value();

  Future<T> add<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      // Laisse l'interface reprendre la main entre deux générations.
      await Future<void>.delayed(Duration.zero);
      try {
        completer.complete(await task());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}
