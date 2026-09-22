import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/design/cv_design.dart';
import '../../domain/design/template_file.dart';
import '../../data/template_repository.dart';
import '../../domain/design/cv_template.dart';
import '../../domain/document/cv_example.dart';
import 'draft_preview_provider.dart';
import 'preview_queue.dart';
import 'widgets/cv_pdf.dart';

/// Les modèles proposés par le catalogue, dans l'ordre d'affichage.
///
/// Réunit les modèles intégrés et la dernière révision des imports locaux.
/// Les aperçus observent cette liste et suivent les mises à jour du catalogue.
final templateCatalogProvider = Provider<List<CvTemplate>>(
  (ref) => [
    for (final design in CvDesign.values) CvTemplate.of(design),
    ...ref.watch(importedTemplatesProvider),
  ],
);

/// Le modèle d'identifiant [id], ou le modèle de repli s'il a disparu.
final templateByIdProvider = Provider.family<CvTemplate, String>((ref, id) {
  final templates = ref.watch(templateCatalogProvider);
  return templates.firstWhere(
    (template) => template.id == id,
    orElse: () => CvTemplate.of(CvDesign.fallback),
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

final templateRepositoryProvider = Provider<TemplateRepository>(
  (ref) => throw StateError('Stockage des modèles non initialisé'),
);
final initialTemplatesProvider = Provider<List<CvTemplate>>((ref) => const []);
final importedTemplatesProvider =
    NotifierProvider<ImportedTemplates, List<CvTemplate>>(
      ImportedTemplates.new,
    );

class ImportedTemplates extends Notifier<List<CvTemplate>> {
  bool _importing = false;
  @override
  List<CvTemplate> build() =>
      List.unmodifiable(ref.watch(initialTemplatesProvider));

  Future<CvTemplate> importFile(String source) async {
    if (_importing) throw StateError('Un import est déjà en cours.');
    _importing = true;
    try {
      final template = TemplateFile.decode(source);
      final existing = [
        for (final design in CvDesign.values) CvTemplate.of(design),
        ...state,
      ].where((item) => item.id == template.id).firstOrNull;
      if (existing != null) {
        if (TemplateFile.encode(existing) == TemplateFile.encode(template)) {
          return existing;
        }
        if (CvDesign.values.any((design) => design.id == template.id)) {
          throw const FormatException(
            'Cet identifiant est réservé à un modèle intégré. Choisissez un nouvel identifiant.',
          );
        }
        if (template.revision <= existing.revision) {
          throw const FormatException(
            'Une révision plus récente est requise pour remplacer ce modèle.',
          );
        }
      }
      await ref.read(templateRepositoryProvider).save(template);
      if (ref.mounted) {
        state = List.unmodifiable([
          for (final item in state)
            if (item.id != template.id) item,
          template,
        ]);
      }
      return template;
    } finally {
      _importing = false;
    }
  }
}
