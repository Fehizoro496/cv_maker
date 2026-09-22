import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/entries/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/document/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/preview/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_presentation.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/selected_section_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/widgets/section_navigation.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/desktop_view.dart';

/// Un PNG 1×1 valide : les vignettes du catalogue ne sont pas le sujet ici.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
);

void main() {
  late ProviderContainer container;

  Future<void> pumpNavigation(WidgetTester tester) async {
    useDesktopView(tester);
    container = ProviderContainer(
      overrides: [
        catalogPreviewProvider.overrideWith(
          (ref, choice) async => Uint8List.fromList(_png),
        ),
        templateThumbnailProvider.overrideWith(
          (ref, templateId) async => Uint8List.fromList(_png),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) =>
              ToastLayer(child: child ?? const SizedBox()),
          home: const Scaffold(
            body: SizedBox(width: 240, child: SectionNavigation()),
          ),
        ),
      ),
    );
  }

  Finder rowOf(CvSection section) => find.byKey(ValueKey(section));

  testWidgets('le catalogue applique le modèle et le notifie', (tester) async {
    await pumpNavigation(tester);
    expect(find.text(CvDesign.classic.label), findsOneWidget);

    await tester.tap(find.text('Catalogue des modèles'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(CvDesign.banner.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(CvDesign.banner.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Appliquer le modèle'));
    await tester.pumpAndSettle();

    final presentation = container
        .read(cvSessionProvider)
        .document
        .presentation;
    expect(presentation.design, CvDesign.banner);
    expect(find.text('Modèle appliqué'), findsOneWidget);
    expect(find.text(CvDesign.banner.label), findsWidgets);

    // Le changement de modèle s'annule comme les autres modifications.
    container.read(cvSessionProvider.notifier).undo();
    await tester.pumpAndSettle();
    expect(container.read(cvSessionProvider).document.design, CvDesign.classic);
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pump();
  });

  testWidgets('annuler le catalogue ne change rien', (tester) async {
    await pumpNavigation(tester);
    await tester.tap(find.text('Catalogue des modèles'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(CvDesign.compact.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(CvDesign.compact.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();
    expect(container.read(cvSessionProvider).document.design, CvDesign.classic);
    expect(container.read(cvSessionProvider.notifier).canUndo, isFalse);
    expect(find.text('Modèle appliqué'), findsNothing);
  });

  Text labelOf(WidgetTester tester, CvSection section) => tester.widget<Text>(
    find.descendant(of: rowOf(section), matching: find.text(section.label)),
  );

  testWidgets("affiche l'en-tête, les deux groupes et le pied", (tester) async {
    await pumpNavigation(tester);

    expect(find.text('CV OUVERT'), findsOneWidget);
    expect(find.byTooltip('Mes CV'), findsOneWidget);
    expect(find.text('SECTIONS'), findsOneWidget);
    expect(find.text('SECTIONS FACULTATIVES'), findsOneWidget);
    expect(
      find.text('Hors ligne — données sur cet ordinateur'),
      findsOneWidget,
    );
    for (final section in CvSection.values) {
      expect(find.text(section.label), findsOneWidget);
    }
  });

  testWidgets('seules les sections facultatives ont un bouton de visibilité', (
    tester,
  ) async {
    await pumpNavigation(tester);

    for (final section in CvSection.values) {
      expect(
        find.descendant(
          of: rowOf(section),
          // Toutes les sections du CV d'exemple sont visibles au départ.
          matching: find.byIcon(Icons.visibility_outlined),
        ),
        section.isOptional ? findsOneWidget : findsNothing,
      );
    }
  });

  testWidgets('met en évidence la section sélectionnée', (tester) async {
    await pumpNavigation(tester);

    expect(
      labelOf(tester, CvSection.personalInfo).style?.fontWeight,
      FontWeight.w600,
    );

    await tester.tap(rowOf(CvSection.languages));
    await tester.pump();

    expect(container.read(selectedSectionProvider), CvSection.languages);
    expect(
      labelOf(tester, CvSection.languages).style?.color,
      AppColors.onSecondaryContainer,
    );
    expect(
      labelOf(tester, CvSection.personalInfo).style?.fontWeight,
      FontWeight.w400,
    );
  });

  testWidgets('masquer une section grise sa rangée', (tester) async {
    await pumpNavigation(tester);

    await tester.tap(
      find.descendant(
        of: rowOf(CvSection.certifications),
        matching: find.byTooltip('Affichée dans le CV'),
      ),
    );
    await tester.pump();

    expect(
      container
          .read(cvSessionProvider)
          .document
          .isVisible(CvSection.certifications),
      isFalse,
    );
    expect(
      find.descendant(
        of: rowOf(CvSection.certifications),
        matching: find.byIcon(Icons.visibility_off_outlined),
      ),
      findsOneWidget,
    );
    expect(
      labelOf(tester, CvSection.certifications).style?.color,
      AppColors.disabled,
    );
    expect(container.read(selectedSectionProvider), CvSection.personalInfo);
  });

  group('sections personnalisées', () {
    testWidgets('« Ajouter une section » crée la section et la sélectionne', (
      tester,
    ) async {
      await pumpNavigation(tester);
      await tester.tap(find.text('Ajouter une section'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Publications');
      await tester.tap(find.text('Liste simple'));
      await tester.tap(find.text('Créer la section'));
      await tester.pumpAndSettle();

      final sections = container
          .read(cvSessionProvider)
          .document
          .customSections;
      expect(sections, hasLength(1));
      expect(sections.single.name, 'Publications');
      expect(sections.single.type, CvCustomSectionType.simpleList);
      final ref = CvCustomSectionRef(sections.single.id);
      expect(container.read(selectedSectionProvider), ref);
      expect(find.byKey(ValueKey(ref)), findsOneWidget);
      expect(find.text('Publications'), findsOneWidget);
    });

    testWidgets('annuler le dialogue ne crée rien', (tester) async {
      await pumpNavigation(tester);
      await tester.tap(find.text('Ajouter une section'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(
        container.read(cvSessionProvider).document.customSections,
        isEmpty,
      );
      expect(container.read(cvSessionProvider.notifier).canUndo, isFalse);
    });

    testWidgets('la ligne d’une section personnalisée la masque et la '
        'sélectionne', (tester) async {
      await pumpNavigation(tester);
      final id = container
          .read(cvSessionProvider.notifier)
          .addCustomSection('Bénévolat', CvCustomSectionType.datedList);
      await tester.pump();
      final ref = CvCustomSectionRef(id);
      final row = find.byKey(ValueKey(ref));

      expect(
        find.descendant(of: row, matching: find.byIcon(Icons.label_outline)),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byIcon(Icons.visibility_outlined),
        ),
      );
      await tester.pump();
      expect(
        container.read(cvSessionProvider).document.isVisible(ref),
        isFalse,
      );
      expect(
        find.descendant(
          of: row,
          matching: find.byIcon(Icons.visibility_off_outlined),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Bénévolat'));
      await tester.pump();
      expect(container.read(selectedSectionProvider), ref);
    });

    testWidgets('les sections personnalisées suivent leur ordre de création', (
      tester,
    ) async {
      await pumpNavigation(tester);
      final editor = container.read(cvSessionProvider.notifier);
      editor.addCustomSection('Zèbre', CvCustomSectionType.freeText);
      editor.addCustomSection('Abeille', CvCustomSectionType.freeText);
      await tester.pump();
      final references = tester.getTopLeft(find.text('Références')).dy;
      final first = tester.getTopLeft(find.text('Zèbre')).dy;
      final second = tester.getTopLeft(find.text('Abeille')).dy;
      final add = tester.getTopLeft(find.text('Ajouter une section')).dy;
      expect(references, lessThan(first));
      expect(first, lessThan(second));
      expect(second, lessThan(add));
    });
  });

  testWidgets('l’en-tête montre le CV ouvert et sa date de modification', (
    tester,
  ) async {
    await pumpNavigation(tester);

    expect(find.text('CV de Camille Moreau'), findsOneWidget);
    expect(find.text('Modifié le 12 janvier 2026'), findsOneWidget);

    container.read(cvSessionProvider.notifier).rename('example', 'Candidature');
    await tester.pump();
    expect(find.text('Candidature'), findsOneWidget);
    expect(find.textContaining('Modifié aujourd’hui à'), findsOneWidget);
  });

  testWidgets('le bouton « Mes CV » quitte l’éditeur', (tester) async {
    await pumpNavigation(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: SizedBox(width: 240, child: SectionNavigation()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SectionNavigation), findsOneWidget);

    await tester.tap(find.byTooltip('Mes CV'));
    await tester.pumpAndSettle();

    expect(navigator.canPop(), isFalse);
  });
}
