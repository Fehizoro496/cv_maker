import 'dart:typed_data';

import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/document/cv_example.dart';
import 'package:cv_maker/features/cv/domain/document/cv_summary.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_thumbnail_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/memory_cv_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final rendered = Uint8List.fromList([1, 2, 3]);

  /// Les octets PDF réellement rasterisés : un par rendu d'aperçu.
  late List<Uint8List> rasterized;
  late MemoryCvRepository repository;

  ProviderContainer makeContainer() {
    rasterized = [];
    final container = ProviderContainer(
      overrides: [
        cvRepositoryProvider.overrideWithValue(repository),
        pdfRasterizerProvider.overrideWith(
          (ref) => (bytes, {dpi = previewDpi}) {
            rasterized.add(bytes);
            return Stream.value(rendered);
          },
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Les aperçus émis pour [summary], dans l'ordre, une fois le flux épuisé.
  ///
  /// L'abonnement est indispensable : sans écouteur, le provider est jeté
  /// avant même de s'exécuter, comme il le serait dans l'application si
  /// aucune carte ne l'affichait.
  Future<List<Uint8List?>> emissions(
    ProviderContainer container,
    CvSummary summary,
  ) async {
    final emitted = <Uint8List?>[];
    final subscription = container.listen(cvThumbnailProvider(summary), (
      _,
      next,
    ) {
      if (next case AsyncData(:final value)) emitted.add(value);
    }, fireImmediately: true);
    addTearDown(subscription.close);
    await container.read(cvThumbnailProvider(summary).future);
    // Laisse le rendu de remplacement arriver, s'il y en a un.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return emitted;
  }

  final document = exampleCvDocument();
  final summary = CvSummary.of(document);

  setUp(() => repository = MemoryCvRepository([document]));

  test(
    'un CV sans aperçu enregistré en fait rendre un, puis le garde',
    () async {
      final container = makeContainer();
      final emitted = await emissions(container, summary);

      expect(emitted, [null, rendered], reason: 'la maquette, puis le rendu');
      expect(rasterized, hasLength(1), reason: 'un seul rendu');
      final stored = await repository.readThumbnail(summary.id);
      expect(stored?.png, rendered);
      expect(stored?.updatedAt, summary.updatedAt);
    },
  );

  test('un aperçu à jour est relu sans recomposer de PDF', () async {
    await repository.saveThumbnail(summary.id, rendered, summary.updatedAt);
    final container = makeContainer();

    final emitted = await emissions(container, summary);

    expect(emitted, [rendered]);
    expect(rasterized, isEmpty, reason: 'la base sert de cache');
  });

  test('un aperçu dépassé est affiché puis remplacé', () async {
    final stale = Uint8List.fromList([9, 9, 9]);
    // Un aperçu rendu à partir d'une version antérieure du CV.
    repository.thumbnails[summary.id] = CvThumbnail(
      stale,
      summary.updatedAt.subtract(const Duration(hours: 1)),
    );
    final container = makeContainer();

    final emitted = await emissions(container, summary);

    expect(
      emitted.first,
      stale,
      reason: 'la liste n’attend pas devant un vide',
    );
    expect(emitted.last, rendered);
    expect(rasterized, hasLength(1));
  });

  test('l’aperçu porte la date de la version réellement rendue', () async {
    final container = makeContainer();
    // Le CV a été réenregistré entre la liste et le rendu : le résumé affiché
    // est déjà dépassé.
    final newer = summary.updatedAt.add(const Duration(minutes: 5));
    await repository.save(document.copyWith(updatedAt: newer));

    await emissions(container, summary);

    // Le rendu lit le CV enregistré, donc sa version récente : l'aperçu est
    // daté d'elle et non du résumé, sans quoi il serait aussitôt réputé
    // périmé et refait à chaque affichage de la liste.
    expect((await repository.readThumbnail(summary.id))?.updatedAt, newer);
  });

  test('un CV supprimé ne rend aucun aperçu', () async {
    final container = makeContainer();
    await repository.delete(summary.id);

    final emitted = await emissions(container, summary);

    expect(emitted, [
      null,
    ], reason: 'la carte n’attend pas un rendu impossible');
    expect(rasterized, isEmpty);
  });
}
