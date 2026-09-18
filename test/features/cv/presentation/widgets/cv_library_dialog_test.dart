import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_workspace.dart';
import 'package:cv_maker/features/cv/presentation/widgets/cv_library_dialog.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';
import '../../../../helpers/memory_cv_repository.dart';

void main() {
  late MemoryCvRepository repository;
  late ProviderContainer container;
  final now = DateTime(2026, 9, 18, 16);

  CvDocument cv(String id, String name, DateTime at) =>
      CvDocument.empty(id: id, now: at, name: name);

  Future<void> pumpDialog(
    WidgetTester tester, {
    List<CvDocument>? documents,
  }) async {
    useDesktopView(tester);
    repository = MemoryCvRepository(
      documents ??
          [
            cv('dev', 'CV développeuse', DateTime(2026, 9, 18, 14, 2)),
            cv('design', 'CV design', DateTime(2026, 9, 12, 10)),
          ],
    );
    final overrides = await startupOverrides(repository);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...overrides, clockProvider.overrideWithValue(() => now)],
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) =>
              ToastLayer(child: child ?? const SizedBox()),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showCvLibraryDialog(context),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
  }

  Finder rowOf(String id) => find.byKey(ValueKey(id));
  Finder inRow(String id, Finder finder) =>
      find.descendant(of: rowOf(id), matching: finder);
  String openId() => container.read(cvSessionProvider).document.id;
  List<String> libraryIds() =>
      container.read(cvLibraryProvider).map((s) => s.id).toList();

  testWidgets('liste les CV du plus récent au plus ancien', (tester) async {
    await pumpDialog(tester);

    expect(find.text('Mes CV'), findsOneWidget);
    expect(find.text('2 CV enregistrés sur cet ordinateur'), findsOneWidget);
    expect(
      tester.getTopLeft(rowOf('dev')).dy,
      lessThan(tester.getTopLeft(rowOf('design')).dy),
    );
    expect(find.text('Modifié aujourd’hui à 14:02 · Ouvert'), findsOneWidget);
    expect(find.text('Modifié le 12 septembre 2026'), findsOneWidget);
    expect(
      find.text('Au démarrage, le dernier CV modifié est rouvert.'),
      findsOneWidget,
    );
  });

  testWidgets('un clic sur une ligne ouvre le CV et ferme le dialogue', (
    tester,
  ) async {
    await pumpDialog(tester);

    await tester.tap(find.text('CV design'));
    await tester.pumpAndSettle();

    expect(openId(), 'design');
    expect(find.byType(CvLibraryDialog), findsNothing);
  });

  testWidgets('« Créer » ouvre un nouveau CV et ferme le dialogue', (
    tester,
  ) async {
    await pumpDialog(tester);

    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.byType(CvLibraryDialog), findsNothing);
    expect(libraryIds(), hasLength(3));
    expect(
      container.read(cvSessionProvider).document.name,
      CvWorkspace.newCvName,
    );
  });

  testWidgets('renommer un CV', (tester) async {
    await pumpDialog(tester);

    await tester.tap(inRow('design', find.byTooltip('Renommer')));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Nom du CV'),
    );
    expect(field.controller!.selection.textInside('CV design'), 'CV design');

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Renommer'))
          .onPressed,
      isNull,
      reason: 'un nom vide est refusé',
    );

    await tester.enterText(find.byType(TextField), 'CV graphisme');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Renommer'));
    await tester.pumpAndSettle();

    expect(find.text('CV graphisme'), findsOneWidget);
    expect(repository.documents['design']!.name, 'CV graphisme');
    expect(openId(), 'dev', reason: 'le CV ouvert ne change pas');
  });

  testWidgets('annuler le renommage ne change rien', (tester) async {
    await pumpDialog(tester);

    await tester.tap(inRow('design', find.byTooltip('Renommer')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Autre');
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(repository.documents['design']!.name, 'CV design');
  });

  testWidgets('dupliquer ajoute une copie sans l’ouvrir', (tester) async {
    await pumpDialog(tester);

    await tester.tap(inRow('design', find.byTooltip('Dupliquer')));
    await tester.pumpAndSettle();

    expect(find.text('CV design (copie)'), findsOneWidget);
    expect(find.text('3 CV enregistrés sur cet ordinateur'), findsOneWidget);
    expect(openId(), 'dev');
  });

  testWidgets('supprimer demande confirmation', (tester) async {
    await pumpDialog(tester);

    await tester.tap(inRow('design', find.byTooltip('Supprimer')));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer ce CV ?'), findsOneWidget);
    expect(
      find.text(
        '« CV design » sera supprimé définitivement de cet ordinateur. '
        'Cette action est irréversible.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(repository.documents.containsKey('design'), isTrue);

    await tester.tap(inRow('design', find.byTooltip('Supprimer')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.documents.containsKey('design'), isFalse);
    expect(rowOf('design'), findsNothing);
    expect(find.byType(CvLibraryDialog), findsOneWidget);
  });

  testWidgets('supprimer le CV ouvert ouvre le suivant', (tester) async {
    await pumpDialog(tester);

    await tester.tap(inRow('dev', find.byTooltip('Supprimer')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(openId(), 'design');
    expect(find.text('Modifié le 12 septembre 2026 · Ouvert'), findsOneWidget);
  });

  testWidgets('supprimer le dernier CV ferme le dialogue', (tester) async {
    await pumpDialog(
      tester,
      documents: [cv('seul', 'CV unique', DateTime(2026, 9, 1))],
    );
    expect(find.text('1 CV enregistré sur cet ordinateur'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.byType(CvLibraryDialog), findsNothing);
    expect(libraryIds(), isEmpty);
  });

  testWidgets('un échec est signalé sans fermer le dialogue', (tester) async {
    await pumpDialog(tester);
    repository.failWrites = true;

    await tester.tap(inRow('design', find.byTooltip('Dupliquer')));
    await tester.pumpAndSettle();

    expect(find.text('Opération impossible'), findsOneWidget);
    expect(find.byType(CvLibraryDialog), findsOneWidget);
    expect(libraryIds(), hasLength(2));
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('un CV illisible ne s’ouvre pas et le signale', (tester) async {
    await pumpDialog(tester);
    repository.unreadable.add('design');

    await tester.tap(find.text('CV design'));
    await tester.pumpAndSettle();

    expect(openId(), 'dev');
    expect(find.text('Opération impossible'), findsOneWidget);
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('« Fermer » referme le dialogue', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    expect(find.byType(CvLibraryDialog), findsNothing);
  });
}
