import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/memory_cv_repository.dart';

void main() {
  CvDocument cv(String id, int day) =>
      CvDocument.empty(id: id, now: DateTime.utc(2026, 9, day), name: 'CV $id');

  Future<ProviderContainer> start(MemoryCvRepository repository) async {
    final container = ProviderContainer(
      overrides: await startupOverrides(repository),
    );
    addTearDown(container.dispose);
    return container;
  }

  test('sans CV enregistré, la liste est vide', () async {
    final container = await start(MemoryCvRepository());

    expect(container.read(cvLibraryProvider), isEmpty);
  });

  test('ouvre le dernier CV modifié, avec un historique vide', () async {
    final repository = MemoryCvRepository([
      cv('ancien', 1),
      cv('recent', 3),
      cv('moyen', 2),
    ]);

    final container = await start(repository);

    expect(container.read(cvSessionProvider).document, cv('recent', 3));
    expect(container.read(cvSessionProvider.notifier).canUndo, isFalse);
    expect(container.read(cvLibraryProvider).map((s) => s.id), [
      'recent',
      'moyen',
      'ancien',
    ]);
    expect(container.read(cvRepositoryProvider), same(repository));
  });

  test('un CV illisible n’empêche pas le démarrage', () async {
    final repository = MemoryCvRepository([cv('ancien', 1), cv('recent', 3)])
      ..unreadable.add('recent');

    final container = await start(repository);

    expect(container.read(cvSessionProvider).document.id, 'ancien');
    expect(
      container.read(cvLibraryProvider).map((s) => s.id),
      contains('recent'),
      reason: 'il reste listé',
    );
  });

  testWidgets('bootstrap enveloppe l’application dans un ProviderScope', (
    tester,
  ) async {
    final app = await bootstrap(MemoryCvRepository());

    expect(app, isA<ProviderScope>());
  });
}
