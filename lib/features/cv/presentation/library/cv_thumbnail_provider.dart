import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/document/cv_summary.dart';
import '../preview/draft_preview_provider.dart';
import '../preview/preview_queue.dart';
import '../preview/widgets/cv_pdf.dart';
import 'cv_library_provider.dart';

/// L'aperçu de la première page d'un CV enregistré, pour la liste d'accueil.
///
/// Un flux et non une valeur : l'aperçu déjà enregistré s'affiche tout de
/// suite, même s'il montre une version dépassée du CV, et le rendu à jour le
/// remplace quand il est prêt. La liste n'attend donc jamais devant un vide.
///
/// Rien n'est mis en cache en mémoire : c'est la base qui tient le cache, et
/// elle survit au redémarrage. Revenir sur l'accueil ne recompose un PDF que
/// pour les CV modifiés entre-temps.
///
/// La clé est le résumé et non l'identifiant : sa date de modification en
/// fait partie, donc éditer un CV demande bien un nouvel aperçu.
final cvThumbnailProvider = StreamProvider.family<Uint8List?, CvSummary>((
  ref,
  summary,
) async* {
  final repository = ref.watch(cvRepositoryProvider);
  final stored = await repository.readThumbnail(summary.id);
  // Le flux émet toujours au moins une fois, quitte à émettre `null` : une
  // carte sans aperçu montre sa maquette de page plutôt que d'attendre sans
  // fin un rendu qui ne viendra pas.
  yield stored?.png;
  // L'aperçu enregistré montre bien la version listée : rien à refaire.
  if (stored?.updatedAt == summary.updatedAt) return;

  final rasterize = ref.watch(pdfRasterizerProvider);
  final queue = ref.watch(previewQueueProvider);
  // Le rendu porte la date du document lu, et non celle du résumé : le CV a
  // pu être réenregistré entre la liste et la lecture.
  final rendered = await queue.add<({Uint8List png, DateTime updatedAt})?>(
    () async {
      final document = await repository.read(summary.id);
      // Le CV a pu être supprimé pendant l'attente dans la file.
      if (document == null || !ref.mounted) return null;
      final photo = await repository.readPhoto(summary.id);
      final bytes = await buildCvPdf(
        document,
        document.designSpec,
        photo: photo,
      );
      await for (final page in rasterize(bytes, dpi: thumbnailDpi)) {
        // Seule la première page sert d'aperçu.
        return (png: page, updatedAt: document.updatedAt);
      }
      return null;
    },
  );
  // Rien n'a pu être rendu : le premier passage a déjà dit ce qu'il y avait.
  if (rendered == null || !ref.mounted) return;

  // Le dépôt revérifie la date : un rendu lent ne peut pas écraser l'aperçu
  // d'une version plus récente.
  await repository.saveThumbnail(summary.id, rendered.png, rendered.updatedAt);
  yield rendered.png;
});
