import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/data/template_repository.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/app/startup_failure_screen.dart';
import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/library/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/desktop_view.dart';
import '../helpers/memory_cv_repository.dart';

void main() {
  test('le démarrage recharge les modèles importés', () async {
    final templates = _Templates();
    final container = ProviderContainer(
      overrides: await startupOverrides(
        MemoryCvRepository(),
        templates: templates,
      ),
    );
    addTearDown(container.dispose);
    expect(container.read(templateCatalogProvider), hasLength(9));
    expect(container.read(templateByIdProvider('external')).label, 'Externe');
    expect(container.read(templateRepositoryProvider), same(templates));
  });
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

  test('liste les CV sans en ouvrir aucun', () async {
    final repository = MemoryCvRepository([
      cv('ancien', 1),
      cv('recent', 3),
      cv('moyen', 2),
    ]);

    final container = await start(repository);

    expect(container.read(cvLibraryProvider).map((s) => s.id), [
      'recent',
      'moyen',
      'ancien',
    ]);
    expect(container.read(cvRepositoryProvider), same(repository));
    expect([
      'recent',
      'moyen',
      'ancien',
    ], isNot(contains(container.read(cvSessionProvider).document.id)));
  });

  test('un CV illisible n’empêche pas le démarrage', () async {
    final repository = MemoryCvRepository([cv('ancien', 1), cv('recent', 3)])
      ..unreadable.add('recent');

    final container = await start(repository);

    expect(container.read(cvLibraryProvider).map((s) => s.id), [
      'recent',
      'ancien',
    ]);
  });

  testWidgets('bootstrap enveloppe l’application dans un ProviderScope', (
    tester,
  ) async {
    final app = await bootstrap(MemoryCvRepository());

    expect(app, isA<ProviderScope>());
  });

  testWidgets('une base illisible mène à l’écran d’échec, pas à un plantage', (
    tester,
  ) async {
    final repository = MemoryCvRepository([cv('ancien', 1)])..failList = true;

    final app = await bootstrap(repository);

    expect(app, isA<StartupFailureApp>());
    expect((app as StartupFailureApp).details, contains('base illisible'));
  });

  testWidgets('« Réessayer » relit les CV et affiche le tableau de bord', (
    tester,
  ) async {
    useDesktopView(tester);
    final repository = MemoryCvRepository([cv('ancien', 1)])..failList = true;

    await tester.pumpWidget(await bootstrap(repository));
    repository.failList = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOne);
  });
}

class _Templates implements TemplateRepository {
  @override
  Future<List<CvTemplate>> list() async => [
    const CvTemplate(
      id: 'external',
      label: 'Externe',
      description: '',
      spec: compactDesignSpec,
    ),
  ];
  @override
  Future<void> save(CvTemplate template) async {}
}
