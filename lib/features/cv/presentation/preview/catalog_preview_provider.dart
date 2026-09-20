import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/design/cv_design.dart';
import '../../domain/design/cv_design_spec.dart';
import '../session/cv_session_provider.dart';
import 'draft_preview_provider.dart';
import 'template_catalog_provider.dart';
import 'widgets/cv_pdf.dart';

/// Un modèle et ses deux réglages, tels que le catalogue les prévisualise.
///
/// La couleur est une valeur ARGB et non une entrée de palette : elle est
/// libre, et sert aussi de clé de cache des aperçus.
typedef CatalogChoice = ({CvDesign design, int accentArgb, bool showPhoto});

/// Le CV réel, rendu avec le choix en cours de composition.
///
/// C'est le grand aperçu du panneau de droite, et lui seul : les vignettes de
/// la grille montrent le CV d'exemple et ne dépendent pas de la session
/// ([templateThumbnailProvider]). L'utilisateur voit donc ses propres données
/// dans le modèle qu'il s'apprête à appliquer, pour une seule génération au
/// lieu de huit.
///
/// Le résultat est jeté avec le catalogue, car le CV a pu changer entre deux
/// ouvertures.
final catalogPreviewProvider = FutureProvider.family<Uint8List, CatalogChoice>((
  ref,
  choice,
) async {
  final session = ref.watch(cvSessionProvider);
  final rasterize = ref.watch(pdfRasterizerProvider);
  final presentation = session.document.presentation;
  final bytes = await buildCvPdf(
    session.document,
    // La forme et la taille de la photo, réglées dans l'éditeur, suivent le CV
    // d'un modèle à l'autre.
    choice.design.spec.withOverrides(
      accentColor: choice.accentArgb,
      showPhoto: choice.showPhoto,
      photoShape: presentation.photoShape,
      photoSizeMm: presentation.photoSizeMm,
    ),
    photo: session.photo,
  );
  if (!ref.mounted) throw StateError('Generation superseded');
  await for (final page in rasterize(bytes, dpi: previewDpi)) {
    // Seule la première page sert d'aperçu.
    return page;
  }
  throw StateError('Le PDF ne contient aucune page');
});
