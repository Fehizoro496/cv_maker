import 'package:cv_maker/features/cv/presentation/editor/editor_screen.dart';
import 'package:cv_maker/features/cv/presentation/preview/widgets/pdf_preview_panel.dart';
import 'package:cv_maker/features/cv/presentation/editor/widgets/section_editor_panel.dart';
import 'package:cv_maker/features/cv/presentation/editor/widgets/section_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';
import '../../../../helpers/preview_override.dart';
import 'package:cv_maker/app/app_theme.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, {required Size size}) async {
    useDesktopView(tester, size: size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [previewOverride],
        child: MaterialApp(theme: buildAppTheme(), home: const EditorScreen()),
      ),
    );
  }

  group('fenêtre large', () {
    testWidgets('affiche les trois colonnes aux dimensions du design', (
      tester,
    ) async {
      await pumpScreen(tester, size: const Size(1440, 900));

      final navigation = tester.getRect(find.byType(SectionNavigation));
      final editor = tester.getRect(find.byType(SectionEditorPanel));
      final preview = tester.getRect(find.byType(PdfPreviewPanel));

      expect(navigation.width, EditorScreen.navigationWidth);
      expect(preview.width, EditorScreen.previewWidth);
      expect(navigation.right, lessThanOrEqualTo(editor.left));
      expect(editor.right, lessThanOrEqualTo(preview.left));
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets("réduit l'aperçu sans descendre sous sa largeur minimale", (
      tester,
    ) async {
      await pumpScreen(tester, size: const Size(1100, 800));

      final preview = tester.getRect(find.byType(PdfPreviewPanel));

      expect(preview.width, EditorScreen.previewMinWidth);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('la navigation change la section affichée', (tester) async {
      await pumpScreen(tester, size: const Size(1440, 900));

      await tester.tap(
        find.descendant(
          of: find.byType(SectionNavigation),
          matching: find.text('Formations'),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(SectionEditorPanel),
          matching: find.text('Formations'),
        ),
        findsOneWidget,
      );
    });
  });

  group('fenêtre étroite', () {
    testWidgets('garde la navigation et affiche les onglets', (tester) async {
      await pumpScreen(tester, size: const Size(900, 760));

      expect(find.byType(SectionNavigation), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Édition'), findsOneWidget);
      expect(find.text('Aperçu'), findsOneWidget);
      expect(find.byType(SectionEditorPanel), findsOneWidget);
      expect(find.byType(PdfPreviewPanel), findsNothing);
    });

    testWidgets("l'onglet Aperçu affiche le PDF à 85 %", (tester) async {
      await pumpScreen(tester, size: const Size(900, 760));

      await tester.tap(find.text('Aperçu'));
      await tester.pumpAndSettle();

      expect(find.byType(PdfPreviewPanel), findsOneWidget);
      expect(find.text('85 %'), findsOneWidget);
    });

    testWidgets('conserve la section sélectionnée en changeant de largeur', (
      tester,
    ) async {
      await pumpScreen(tester, size: const Size(1440, 900));
      await tester.tap(find.text('Langues'));
      await tester.pump();

      tester.view.physicalSize = const Size(900, 760);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SectionEditorPanel),
          matching: find.text('Langues'),
        ),
        findsOneWidget,
      );
    });
  });
}
