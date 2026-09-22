import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
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

  test('la vignette est la première page du PDF généré', () async {
    final container = makeContainer();
    final png = await container.read(
      catalogPreviewProvider((
        templateId: CvDesign.classic.id,
        accentArgb: CvAccent.defaultColor,
        showPhoto: true,
      )).future,
    );
    expect(png, [1, 2, 3]);
    expect(rasterized, hasLength(1));
    expect(latin1.decode(rasterized.single), startsWith('%PDF-'));
  });

  test('chaque modèle produit son propre PDF', () async {
    final container = makeContainer();
    for (final design in CvDesign.values) {
      await container.read(
        catalogPreviewProvider((
          templateId: design.id,
          accentArgb: CvAccent.defaultColor,
          showPhoto: true,
        )).future,
      );
    }
    expect(rasterized, hasLength(CvDesign.values.length));
    // Chaque modèle produit un rendu distinct de tous les autres.
    expect(
      rasterized.map(pdfFingerprint).toSet(),
      hasLength(CvDesign.values.length),
    );
  });

  test(
    'un identifiant externe utilise sa description et non le modèle de repli',
    () async {
      rasterized = [];
      final container = ProviderContainer(
        overrides: [
          initialTemplatesProvider.overrideWithValue([
            const CvTemplate(
              id: 'external',
              label: 'Externe',
              description: '',
              spec: compactDesignSpec,
            ),
          ]),
          pdfRasterizerProvider.overrideWith(
            (ref) => (bytes, {dpi = previewDpi}) {
              rasterized.add(bytes);
              return Stream.value(Uint8List.fromList([1]));
            },
          ),
        ],
      );
      addTearDown(container.dispose);
      for (final id in ['external', 'compact', 'classic']) {
        await container.read(
          catalogPreviewProvider((
            templateId: id,
            accentArgb: CvAccent.defaultColor,
            showPhoto: true,
          )).future,
        );
      }
      expect(pdfFingerprint(rasterized[0]), pdfFingerprint(rasterized[1]));
      expect(
        pdfFingerprint(rasterized[0]),
        isNot(pdfFingerprint(rasterized[2])),
      );
    },
  );

  test('la couleur d’accent change le PDF généré', () async {
    final container = makeContainer();
    for (final argb in [CvAccent.defaultColor, 0xFF7A2F4A]) {
      await container.read(
        catalogPreviewProvider((
          templateId: CvDesign.classic.id,
          accentArgb: argb,
          showPhoto: true,
        )).future,
      );
    }
    expect(rasterized, hasLength(2));
    expect(
      pdfFingerprint(rasterized.first),
      isNot(pdfFingerprint(rasterized.last)),
    );
  });

  test('un modèle sans couleur ignore l’accent demandé', () async {
    final container = makeContainer();
    for (final argb in [CvAccent.defaultColor, 0xFF1E5233]) {
      await container.read(
        catalogPreviewProvider((
          templateId: CvDesign.plain.id,
          accentArgb: argb,
          showPhoto: true,
        )).future,
      );
    }
    expect(pdfFingerprint(rasterized.first), pdfFingerprint(rasterized.last));
  });

  test('le grand aperçu suit le contenu du CV en cours', () async {
    final container = makeContainer();
    final choice = (
      templateId: CvDesign.classic.id,
      accentArgb: CvAccent.defaultColor,
      showPhoto: true,
    );
    await container.read(catalogPreviewProvider(choice).future);
    container
        .read(cvSessionProvider.notifier)
        .setSectionVisible(
          // Masquer une section change le PDF de la vignette.
          container
              .read(cvSessionProvider)
              .document
              .presentation
              .orderedSections
              .firstWhere((section) => section.isOptional),
          false,
        );
    await container.read(catalogPreviewProvider(choice).future);
    expect(rasterized, hasLength(2));
    expect(
      pdfFingerprint(rasterized.first),
      isNot(pdfFingerprint(rasterized.last)),
    );
  });
}
