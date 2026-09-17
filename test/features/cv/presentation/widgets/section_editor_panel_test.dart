import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/section_editor_panel.dart';
import 'package:flutter/material.dart';
import 'package:cv_maker/features/cv/presentation/editor_draft_provider.dart';
import 'package:cv_maker/app/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpPanel(WidgetTester tester, {bool compact = false}) async {
    useDesktopView(tester);
    container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(body: SectionEditorPanel(compact: compact)),
        ),
      ),
    );
  }

  IconButton buttonWithTooltip(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );

  testWidgets('affiche le titre et l\'aide de la section sélectionnée', (
    tester,
  ) async {
    await pumpPanel(tester);

    expect(find.text('Informations personnelles'), findsOneWidget);
    expect(
      find.text('Ces informations apparaissent en haut de votre CV.'),
      findsOneWidget,
    );

    container.read(selectedSectionProvider.notifier).select(CvSection.projects);
    await tester.pump();

    expect(find.text('Projets'), findsOneWidget);
    expect(find.text('Informations personnelles'), findsNothing);
  });

  testWidgets('les boutons annuler et rétablir sont désactivés', (
    tester,
  ) async {
    await pumpPanel(tester);

    expect(buttonWithTooltip(tester, 'Annuler (Ctrl+Z)').onPressed, isNull);
    expect(buttonWithTooltip(tester, 'Rétablir (Ctrl+Y)').onPressed, isNull);
  });

  testWidgets('le mode compact réduit le titre à 16 px', (tester) async {
    await pumpPanel(tester, compact: true);

    final title = tester.widget<Text>(find.text('Informations personnelles'));

    expect(title.style?.fontSize, 16);
  });
  testWidgets(
    'fields use the handoff dimensions and restore edits after navigation',
    (tester) async {
      await pumpPanel(tester);
      final firstName = find.widgetWithText(TextField, 'Prénom');
      expect(tester.getSize(firstName).height, 44);
      expect(find.text('Photo (facultative)'), findsOneWidget);
      expect(find.text('Non enregistré'), findsOneWidget);
      await tester.enterText(firstName, 'Alice');
      container
          .read(selectedSectionProvider.notifier)
          .select(CvSection.experiences);
      await tester.pumpAndSettle();
      expect(find.text('En cours'), findsOneWidget);
      container
          .read(selectedSectionProvider.notifier)
          .select(CvSection.personalInfo);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      await tester.tap(find.byTooltip('Annuler (Ctrl+Z)'));
      await tester.pumpAndSettle();
      expect(find.text('Camille'), findsOneWidget);
      expect(container.read(editorDraftProvider).fields['Prénom'], 'Camille');
    },
  );

  testWidgets('les dates se choisissent avec le sélecteur de mois', (
    tester,
  ) async {
    await pumpPanel(tester);
    container
        .read(selectedSectionProvider.notifier)
        .select(CvSection.experiences);
    await tester.pumpAndSettle();

    final start = find.widgetWithText(TextField, 'Début');
    expect(tester.widget<TextField>(start).readOnly, isTrue);

    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.text('janv.'));
    await tester.pumpAndSettle();

    final entry = container
        .read(editorDraftProvider)
        .entries[CvSection.experiences]!
        .first;
    expect(entry['Début'], 'janv. 2023');
    expect(find.text('janv. 2023'), findsOneWidget);
  });
}
