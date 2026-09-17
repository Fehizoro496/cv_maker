import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/catalog_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_presentation.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/section_navigation.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

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
}
