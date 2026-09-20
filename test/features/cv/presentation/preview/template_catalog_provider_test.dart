import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pdf_bytes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Les octets PDF réellement produits, capturés par le faux rasteriseur.
  late List<Uint8List> rasterized;

  ProviderContainer makeContainer() {
    rasterized = [];
    final container = ProviderContainer(
      overrides: [
        pdfRasterizerProvider.overrideWith(
          (ref) => (bytes, {dpi = previewDpi}) {
            rasterized.add(bytes);
            // Une page par génération suffit : la vignette est la première.
            return Stream.value(Uint8List.fromList([1, 2, 3]));
          },
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('le catalogue expose tous les modèles intégrés', () {
    final templates = makeContainer().read(templateCatalogProvider);
    expect(
      templates.map((template) => template.id),
      CvDesign.values.map((design) => design.id),
    );
  });

  test('la vignette est la première page du PDF du modèle', () async {
    final container = makeContainer();
    final png = await container.read(
      templateThumbnailProvider(CvDesign.classic.id).future,
    );
    expect(png, [1, 2, 3]);
    expect(rasterized, hasLength(1));
    expect(latin1.decode(rasterized.single), startsWith('%PDF-'));
  });

  test('chaque modèle produit une vignette distincte', () async {
    final container = makeContainer();
    for (final design in CvDesign.values) {
      await container.read(templateThumbnailProvider(design.id).future);
    }
    expect(rasterized, hasLength(CvDesign.values.length));
    expect(
      rasterized.map(pdfFingerprint).toSet(),
      hasLength(CvDesign.values.length),
    );
  });

  test('la vignette ne dépend pas du CV ouvert', () async {
    final container = makeContainer();
    final id = CvDesign.classic.id;
    await container.read(templateThumbnailProvider(id).future);

    // Masquer une section change le CV ouvert, et donc son aperçu — mais la
    // vignette montre le CV d'exemple et reste identique.
    container
        .read(cvSessionProvider.notifier)
        .setSectionVisible(
          container
              .read(cvSessionProvider)
              .document
              .presentation
              .orderedSections
              .firstWhere((section) => section.isOptional),
          false,
        );
    await container.read(templateThumbnailProvider(id).future);

    expect(rasterized, hasLength(1));
  });

  test('la vignette survit à la fermeture du catalogue', () async {
    final container = makeContainer();
    final id = CvDesign.compact.id;
    await container.read(templateThumbnailProvider(id).future);

    // Plus personne n'écoute : sans `keepAlive`, le provider serait jeté et la
    // vignette regénérée à l'ouverture suivante.
    await Future<void>.delayed(Duration.zero);
    await container.read(templateThumbnailProvider(id).future);

    expect(rasterized, hasLength(1));
  });
}
