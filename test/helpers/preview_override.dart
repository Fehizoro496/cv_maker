import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/features/cv/presentation/library/cv_thumbnail_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';

/// Un PNG 1×1 valide : le contenu d'un aperçu n'est pas le sujet de ces tests.
final samplePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

final previewOverride = draftPreviewProvider.overrideWith(
  (ref) async => DraftPreview(Uint8List(0), []),
);

/// Neutralise la génération des vignettes du catalogue.
///
/// L'application les prépare dès son démarrage : sans cette surcharge, tout
/// test qui monte `CvMakerApp` composerait huit PDF pour rien.
final thumbnailOverride = templateThumbnailProvider.overrideWith(
  (ref, templateId) async => Uint8List.fromList(samplePng),
);

final catalogPreviewOverride = catalogPreviewProvider.overrideWith(
  (ref, choice) async => Uint8List.fromList(samplePng),
);

/// Neutralise la génération des aperçus de la liste d'accueil.
///
/// L'accueil en demande un par CV listé : sans cette surcharge, tout test qui
/// l'affiche lirait la base et composerait un PDF par carte.
final cvThumbnailOverride = cvThumbnailProvider.overrideWith(
  (ref, summary) => Stream.value(Uint8List.fromList(samplePng)),
);
