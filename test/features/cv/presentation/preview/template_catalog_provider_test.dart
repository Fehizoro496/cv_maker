import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/domain/design/template_file.dart';
import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/data/template_repository.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pdf_bytes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CvTemplate custom(int revision) => CvTemplate(
    id: 'studio.modern',
    label: 'Studio',
    description: '',
    revision: revision,
    spec: revision == 1 ? bannerDesignSpec : compactDesignSpec,
  );

  test(
    'import, mise à jour, conflits et conservation du rendu du CV',
    () async {
      final repository = _Templates();
      final container = ProviderContainer(
        overrides: [templateRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final importer = container.read(importedTemplatesProvider.notifier);
      final first = await importer.importFile(TemplateFile.encode(custom(1)));
      expect(
        container
            .read(templateByIdProvider(first.id))
            .spec
            .header
            .fullWidthBanner,
        isTrue,
      );
      final editor = container.read(cvSessionProvider.notifier);
      editor.applyCatalogTemplate(
        template: first,
        accentArgb: 0xFF123456,
        showPhoto: false,
      );
      final document = container.read(cvSessionProvider).document;
      editor.applyCatalogTemplate(
        template: first,
        accentArgb: 0xFF123456,
        showPhoto: false,
      );
      expect(container.read(cvSessionProvider).document, same(document));
      await importer.importFile(TemplateFile.encode(custom(2)));
      expect(container.read(templateByIdProvider(first.id)).revision, 2);
      final reopened = CvDocument.fromJson(
        jsonDecode(jsonEncode(document.toJson())) as Map<String, dynamic>,
      );
      expect(reopened.presentation.templateSnapshot!.revision, 1);
      expect(reopened.designSpec.header.fullWidthBanner, isTrue);
      expect(reopened.designSpec.header.showPhoto, isFalse);
      expect(reopened.designSpec.tokens.accentColor, 0xFF123456);
      await expectLater(
        importer.importFile(TemplateFile.encode(custom(1))),
        throwsFormatException,
      );
      final writes = repository.writes;
      await importer.importFile(TemplateFile.encode(custom(2)));
      expect(repository.writes, writes);
      expect(container.read(importedTemplatesProvider), hasLength(1));
      editor.undo();
      expect(
        container
            .read(cvSessionProvider)
            .document
            .presentation
            .templateSnapshot,
        isNull,
      );
      editor.redo();
      expect(
        container
            .read(cvSessionProvider)
            .document
            .presentation
            .templateSnapshot!
            .id,
        first.id,
      );
    },
  );

  test(
    'un échec disque, un conflit ou un fichier invalide laisse le catalogue intact',
    () async {
      final repository = _Templates()..fail = true;
      final container = ProviderContainer(
        overrides: [templateRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final importer = container.read(importedTemplatesProvider.notifier);
      await expectLater(
        importer.importFile(TemplateFile.encode(custom(1))),
        throwsStateError,
      );
      await expectLater(importer.importFile('{}'), throwsFormatException);
      final reserved = CvTemplate(
        id: 'classic',
        label: 'Collision',
        description: '',
        spec: compactDesignSpec,
      );
      await expectLater(
        importer.importFile(TemplateFile.encode(reserved)),
        throwsFormatException,
      );
      expect(container.read(importedTemplatesProvider), isEmpty);
      repository.fail = false;
      await importer.importFile(TemplateFile.encode(custom(1)));
      final conflicting = CvTemplate(
        id: custom(1).id,
        label: 'Conflit',
        description: '',
        spec: compactDesignSpec,
      );
      await expectLater(
        importer.importFile(TemplateFile.encode(conflicting)),
        throwsFormatException,
      );
      expect(container.read(importedTemplatesProvider).single.label, 'Studio');
    },
  );

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

class _Templates implements TemplateRepository {
  bool fail = false;
  int writes = 0;
  @override
  Future<List<CvTemplate>> list() async => [];
  @override
  Future<void> save(CvTemplate template) async {
    if (fail) throw StateError('disque indisponible');
    writes++;
  }
}
