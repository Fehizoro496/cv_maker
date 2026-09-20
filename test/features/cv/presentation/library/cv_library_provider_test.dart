import 'package:cv_maker/features/cv/domain/document/cv_example.dart';
import 'package:cv_maker/features/cv/domain/document/cv_summary.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CvSummary summary(String id, int day) =>
      CvSummary(id: id, name: id, updatedAt: DateTime.utc(2026, 1, day));

  test('par défaut, le CV d’ouverture est le seul CV connu', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(cvLibraryProvider), [
      CvSummary.of(exampleCvDocument()),
    ]);
  });

  test('aucun stockage n’est fourni par défaut', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(cvRepositoryProvider), throwsA(anything));
  });

  test('part de la liste lue au lancement, triée', () {
    final container = ProviderContainer(
      overrides: [
        initialCvLibraryProvider.overrideWithValue([
          summary('a', 1),
          summary('b', 2),
        ]),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(cvLibraryProvider).map((s) => s.id), ['b', 'a']);
  });

  test('upsert et remove tiennent la liste à jour', () {
    final container = ProviderContainer(
      overrides: [
        initialCvLibraryProvider.overrideWithValue([summary('a', 1)]),
      ],
    );
    addTearDown(container.dispose);
    final library = container.read(cvLibraryProvider.notifier);

    library.upsert(summary('b', 2));
    expect(container.read(cvLibraryProvider).map((s) => s.id), ['b', 'a']);

    library.upsert(summary('a', 3));
    expect(container.read(cvLibraryProvider).map((s) => s.id), ['a', 'b']);

    library.remove('a');
    expect(container.read(cvLibraryProvider).map((s) => s.id), ['b']);
  });

  test('l’horloge par défaut est l’heure courante', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final before = DateTime.now();

    final now = container.read(clockProvider)();

    expect(now.isBefore(before), isFalse);
  });
}
