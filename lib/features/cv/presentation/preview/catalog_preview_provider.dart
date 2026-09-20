import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/design/cv_design.dart';
import '../../domain/design/cv_design_spec.dart';
import '../session/cv_session_provider.dart';
import 'draft_preview_provider.dart';
import 'widgets/cv_pdf.dart';

/// Un modèle et ses deux réglages, tels que le catalogue les prévisualise.
///
/// La couleur est une valeur ARGB et non une entrée de palette : elle est
/// libre, et sert aussi de clé de cache des aperçus.
typedef CatalogChoice = ({CvDesign design, int accentArgb, bool showPhoto});

/// La première page du CV en cours, rendue avec le choix demandé.
///
/// Les vignettes du catalogue viennent du PDF réel et non d'une image livrée
/// dans les assets : l'utilisateur voit ses propres données dans chaque modèle.
///
/// Le résultat est conservé le temps où le catalogue est ouvert ; il est jeté
/// avec lui, car le CV a pu changer entre deux ouvertures.
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
  await for (final page in rasterize(bytes)) {
    // Seule la première page sert de vignette.
    return page;
  }
  throw StateError('Le PDF ne contient aucune page');
});
