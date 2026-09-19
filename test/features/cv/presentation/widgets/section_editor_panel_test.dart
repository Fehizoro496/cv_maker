import 'dart:convert';

import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_personal_info.dart';
import 'package:cv_maker/features/cv/domain/cv_presentation_preferences.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/save_status_chip.dart';
import 'package:cv_maker/features/cv/presentation/widgets/section_editor_panel.dart';
import 'package:flutter/material.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
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

  testWidgets('le format de la photo se règle puis revient au modèle', (
    tester,
  ) async {
    await pumpPanel(tester);
    // Sans photo, aucun réglage de format n'est proposé.
    expect(find.text('Format dans le CV'), findsNothing);

    container
        .read(cvSessionProvider.notifier)
        .setPhoto(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
          ),
        );
    await tester.pump();
    expect(find.text('Format dans le CV'), findsOneWidget);
    expect(find.text('Selon le modèle'), findsOneWidget);
    expect(find.text('25 mm'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Forme Carré'));
    await tester.pump();
    CvPresentationPreferences presentation() =>
        container.read(cvSessionProvider).document.presentation;
    expect(presentation().photoShape, CvPhotoShape.square);
    expect(find.text('Selon le modèle'), findsNothing);

    // La taille avance d'un millimètre à chaque pression.
    await tester.tap(find.byTooltip('Agrandir la photo'));
    await tester.pump();
    await tester.tap(find.byTooltip('Agrandir la photo'));
    await tester.pump();
    expect(presentation().photoSizeMm, 27);
    expect(find.text('27 mm'), findsOneWidget);
    await tester.tap(find.byTooltip('Réduire la photo'));
    await tester.pump();
    expect(presentation().photoSizeMm, 26);
    // Le changement de taille garde la forme choisie.
    expect(presentation().photoShape, CvPhotoShape.square);

    await tester.tap(find.text('Rétablir le modèle'));
    await tester.pump();
    expect(presentation().photoShape, isNull);
    expect(presentation().photoSizeMm, isNull);
    expect(find.text('Selon le modèle'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
      expect(find.byType(SaveStatusChip), findsOneWidget);
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
      expect(
        container.read(cvSessionProvider).document.personalInfo.firstName,
        'Camille',
      );
    },
  );

  testWidgets('les champs suivent le CV ouvert', (tester) async {
    await pumpPanel(tester);
    final editor = container.read(cvSessionProvider.notifier);
    TextField field(String label) =>
        tester.widget<TextField>(find.widgetWithText(TextField, label));

    editor.open(
      CvDocument.empty(
        id: 'other',
        now: DateTime.utc(2026),
      ).copyWith(personalInfo: const CvPersonalInfo(firstName: 'Bruno')),
    );
    await tester.pumpAndSettle();
    expect(field('Prénom').controller!.text, 'Bruno');
    expect(field('Nom').controller!.text, isEmpty);

    container
        .read(selectedSectionProvider.notifier)
        .select(CvSection.experiences);
    await tester.pumpAndSettle();
    expect(find.text('Nexora'), findsNothing);

    editor.open(exampleCvDocument());
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Nexora'), findsOneWidget);
  });

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

    final entry = container.read(cvSessionProvider).document.experiences.first;
    expect(entry.period.start, const CvMonthYear(2023, 1));
    expect(find.text('janv. 2023'), findsOneWidget);
  });

  group('sections personnalisées', () {
    Future<CvCustomSectionRef> selectCustom(
      WidgetTester tester,
      CvCustomSectionType type,
    ) async {
      final editor = container.read(cvSessionProvider.notifier);
      final ref = CvCustomSectionRef(
        editor.addCustomSection('Publications', type),
      );
      container.read(selectedSectionProvider.notifier).select(ref);
      await tester.pumpAndSettle();
      return ref;
    }

    CvCustomSection sectionOf(CvCustomSectionRef ref) =>
        container.read(cvSessionProvider).document.customSectionById(ref.id)!;

    testWidgets('l’en-tête signale la section, son type et ses éléments', (
      tester,
    ) async {
      await pumpPanel(tester);
      final ref = await selectCustom(tester, CvCustomSectionType.datedList);
      expect(find.text('Publications'), findsOneWidget);
      expect(find.text('PERSONNALISÉE'), findsOneWidget);
      expect(find.text('Liste datée · 0 élément'), findsOneWidget);
      expect(find.byTooltip('Renommer la section'), findsOneWidget);
      expect(find.byTooltip('Supprimer la section'), findsOneWidget);

      await tester.tap(find.text('Ajouter un élément'));
      await tester.pumpAndSettle();
      expect(sectionOf(ref).items, hasLength(1));
      expect(find.text('Liste datée · 1 élément'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Titre'),
        'Accessibilité et Flutter',
      );
      await tester.pump();
      expect(sectionOf(ref).items.single.title, 'Accessibilité et Flutter');
      expect(find.widgetWithText(TextField, 'Sous-titre'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
    });

    testWidgets('une section standard n’a ni badge ni actions de section', (
      tester,
    ) async {
      await pumpPanel(tester);
      expect(find.text('PERSONNALISÉE'), findsNothing);
      expect(find.byTooltip('Renommer la section'), findsNothing);
    });

    testWidgets('un texte libre s’édite dans un seul champ', (tester) async {
      await pumpPanel(tester);
      final ref = await selectCustom(tester, CvCustomSectionType.freeText);
      expect(find.text('Texte libre'), findsOneWidget);
      expect(find.text('Ajouter un élément'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Texte'),
        'Un paragraphe.',
      );
      await tester.pump();
      expect(sectionOf(ref).text, 'Un paragraphe.');

      container.read(cvSessionProvider.notifier).undo();
      await tester.pump();
      expect(sectionOf(ref).text, isEmpty);
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Texte'))
            .controller!
            .text,
        isEmpty,
        reason: 'le champ suit l’état restauré',
      );
    });

    testWidgets('une liste simple n’a que titre et description courte', (
      tester,
    ) async {
      await pumpPanel(tester);
      await selectCustom(tester, CvCustomSectionType.simpleList);
      await tester.tap(find.text('Ajouter un élément'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Titre'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Description courte'),
        findsOneWidget,
      );
      expect(find.text('Début'), findsNothing);
    });

    testWidgets('renommer la section depuis l’en-tête', (tester) async {
      await pumpPanel(tester);
      final ref = await selectCustom(tester, CvCustomSectionType.simpleList);
      await tester.tap(find.byTooltip('Renommer la section'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Distinctions',
      );
      await tester.tap(find.text('Renommer'));
      await tester.pumpAndSettle();
      expect(sectionOf(ref).name, 'Distinctions');
      expect(find.text('Distinctions'), findsOneWidget);
    });

    testWidgets('supprimer la section revient à l’en-tête, Ctrl+Z la rend', (
      tester,
    ) async {
      await pumpPanel(tester);
      final ref = await selectCustom(tester, CvCustomSectionType.simpleList);
      await tester.tap(find.byTooltip('Supprimer la section'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
      await tester.pumpAndSettle();
      final document = container.read(cvSessionProvider).document;
      expect(document.customSectionById(ref.id), isNull);
      expect(container.read(selectedSectionProvider), CvSection.personalInfo);
      expect(find.text('Informations personnelles'), findsOneWidget);

      container.read(cvSessionProvider.notifier).undo();
      await tester.pump();
      expect(
        container.read(cvSessionProvider).document.customSectionById(ref.id),
        isNotNull,
      );
    });

    testWidgets('masquer plutôt que supprimer conserve la section', (
      tester,
    ) async {
      await pumpPanel(tester);
      final ref = await selectCustom(tester, CvCustomSectionType.simpleList);
      await tester.tap(find.byTooltip('Supprimer la section'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masquer'));
      await tester.pumpAndSettle();
      expect(sectionOf(ref).visible, isFalse);
      expect(container.read(selectedSectionProvider), ref);
    });
  });
}
