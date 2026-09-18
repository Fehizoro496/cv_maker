import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/presentation/cv_autosave.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/save_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/memory_cv_repository.dart';

void main() {
  late MemoryCvRepository repository;
  late ProviderContainer container;

  Future<void> pumpChip(WidgetTester tester, {bool compact = false}) async {
    repository = MemoryCvRepository([exampleCvDocument()]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cvRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                ref.watch(cvAutosaveProvider);
                return Center(child: SaveStatusChip(compact: compact));
              },
            ),
          ),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(SaveStatusChip)),
    );
  }

  void edit(String value) => container
      .read(cvSessionProvider.notifier)
      .setDocumentField(CvDocumentFields.firstName, value);

  testWidgets('au départ, tout est enregistré', (tester) async {
    await pumpChip(tester);

    expect(find.text('Enregistré'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(tester.getSize(find.byType(SaveStatusChip)).height, 28);
  });

  testWidgets('une modification passe en cours puis enregistré', (
    tester,
  ) async {
    await pumpChip(tester);

    edit('Alice');
    await tester.pump();
    expect(find.text('Enregistrement…'), findsOneWidget);

    await tester.pump(CvAutosave.delay);
    await tester.pump();
    expect(find.text('Enregistré'), findsOneWidget);
    expect(repository.documents['example']!.personalInfo.firstName, 'Alice');
  });

  testWidgets('un échec affiche l’erreur et « Réessayer » relance', (
    tester,
  ) async {
    await pumpChip(tester);
    repository.failWrites = true;

    edit('Alice');
    await tester.pump(CvAutosave.delay);
    await tester.pump();
    expect(find.text('Erreur d’enregistrement'), findsOneWidget);
    expect(repository.documents['example']!.personalInfo.firstName, 'Camille');

    repository.failWrites = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Enregistré'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
    expect(repository.documents['example']!.personalInfo.firstName, 'Alice');
  });

  testWidgets('le mode compact réduit la puce', (tester) async {
    await pumpChip(tester, compact: true);

    expect(tester.getSize(find.byType(SaveStatusChip)).height, 26);
    expect(tester.widget<Text>(find.text('Enregistré')).style?.fontSize, 11);
  });

  testWidgets('en erreur dans un en-tête étroit, le libellé se tronque', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 170,
                  child: Row(children: [Flexible(child: SaveStatusChip())]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    ProviderScope.containerOf(
      tester.element(find.byType(SaveStatusChip)),
    ).read(cvSaveStatusProvider.notifier).set(CvSaveStatus.error);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(tester.getSize(find.byType(SaveStatusChip)).width, lessThan(171));
  });
}
