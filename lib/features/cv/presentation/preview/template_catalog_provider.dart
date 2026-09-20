import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/design/cv_design.dart';
import '../../domain/design/cv_template.dart';
import '../../domain/document/cv_example.dart';
import 'draft_preview_provider.dart';
import 'preview_queue.dart';
import 'widgets/cv_pdf.dart';

/// Les modèles proposés par le catalogue, dans l'ordre d'affichage.
///
/// C'est le seul endroit qui sait d'où viennent les modèles. Les remplacer un
/// jour par des descriptions lues hors du code — un fichier livré, un dossier
/// utilisateur, une table — se fait ici, sans toucher au catalogue, aux
/// aperçus ni au générateur.
final templateCatalogProvider = Provider<List<CvTemplate>>(
  (ref) => [for (final design in CvDesign.values) CvTemplate.of(design)],
);

/// Le modèle d'identifiant [id], ou le modèle de repli s'il a disparu.
final templateByIdProvider = Provider.family<CvTemplate, String>((ref, id) {
  final templates = ref.watch(templateCatalogProvider);
  return templates.firstWhere(
    (template) => template.id == id,
    orElse: () => templates.first,
  );
});

/// Portrait neutre utilisé par les vignettes du catalogue.
///
/// Les modèles qui réservent une place à la photo se lisent mal sans elle : le
/// CV d'exemple n'en a pas, cette image en tient lieu. Ce n'est le visage de
/// personne, seulement une silhouette.
final samplePortraitProvider = FutureProvider<Uint8List>((ref) async {
  ref.keepAlive();
  final data = await rootBundle.load(
    'assets/previews/portrait_placeholder.png',
  );
  return data.buffer.asUint8List();
});

/// La vignette d'un modèle : la première page du CV d'exemple, rendue avec lui.
///
/// La vignette ne dépend que du modèle — ni du CV ouvert, ni de la couleur
/// choisie dans le panneau de droite. Elle est donc la même d'une ouverture du
/// catalogue à l'autre et d'un CV à l'autre : elle est calculée une fois, puis
/// conservée pour la durée de la session. C'est ce qui rend l'ouverture du
/// catalogue immédiate après la première fois.
///
/// La clé est l'identifiant du modèle et non une valeur de l'enum : un modèle
/// décrit par des données s'y prévisualise sans rien changer ici.
final templateThumbnailProvider = FutureProvider.family<Uint8List, String>((
  ref,
  templateId,
) async {
  ref.keepAlive();
  final template = ref.watch(templateByIdProvider(templateId));
  final rasterize = ref.watch(pdfRasterizerProvider);
  final queue = ref.watch(previewQueueProvider);
  final portrait = await ref.watch(samplePortraitProvider.future);
  return queue.add(() async {
    // Aucune surcharge : la vignette montre le modèle tel qu'il se définit,
    // avec sa propre couleur d'accent et son propre parti sur la photo.
    final bytes = await buildCvPdf(
      exampleCvDocument(),
      template.spec,
      photo: portrait,
    );
    await for (final page in rasterize(bytes, dpi: thumbnailDpi)) {
      // Seule la première page sert de vignette.
      return page;
    }
    throw StateError('Le PDF ne contient aucune page');
  });
});

/// Prépare les vignettes en tâche de fond, sans bloquer l'appelant.
///
/// Appelée au démarrage : au premier passage dans le catalogue, la grille est
/// déjà remplie. Les générations passent par [previewQueueProvider], qui rend
/// la main à l'interface entre chacune ; l'aperçu du CV ouvert, lui, ne passe
/// pas par cette file et garde donc la priorité.
///
/// Les erreurs sont ignorées : une vignette qui n'a pas pu être préparée sera
/// regénérée à l'ouverture, et le catalogue sait déjà afficher un échec.
void warmTemplateThumbnails(WidgetRef ref) {
  for (final template in ref.read(templateCatalogProvider)) {
    ref.read(templateThumbnailProvider(template.id).future).ignore();
  }
}
