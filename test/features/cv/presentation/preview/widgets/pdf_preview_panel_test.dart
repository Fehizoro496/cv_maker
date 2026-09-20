import 'package:cv_maker/features/cv/presentation/preview/widgets/pdf_preview_panel.dart';
import 'package:flutter/gestures.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/preview_input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../helpers/preview_override.dart';
import 'package:cv_maker/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/desktop_view.dart';

void main() {
  testWidgets('typing keeps the preview stable and refresh flushes once', (
    tester,
  ) async {
    useDesktopView(tester);
    var generations = 0;
    final container = ProviderContainer(
      overrides: [
        draftPreviewProvider.overrideWith((ref) async {
          ref.watch(previewInputProvider);
          generations++;
          return DraftPreview(Uint8List(0), []);
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(
            body: SizedBox(width: 620, child: PdfPreviewPanel()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final editor = container.read(cvSessionProvider.notifier);
    editor.setDocumentField(CvDocumentFields.firstName, 'A');
    await tester.pump(const Duration(milliseconds: 400));
    editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
    await tester.pump(const Duration(milliseconds: 400));
    expect(generations, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('À actualiser'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(generations, 2);
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    await tester.pump();
    await tester.tap(find.byTooltip('Rafraîchir'));
    await tester.pumpAndSettle();
    expect(generations, 3);
    await tester.pump(const Duration(seconds: 1));
    expect(generations, 3);
  });
  const pageKey = Key('a4-page-placeholder');

  Future<void> pumpPanel(WidgetTester tester, {int initialZoom = 100}) async {
    useDesktopView(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [previewOverride],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SizedBox(
              width: 620,
              child: PdfPreviewPanel(initialZoom: initialZoom),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche la barre d\'outils du design', (tester) async {
    await pumpPanel(tester);

    expect(find.text('Aperçu PDF'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(find.byTooltip('Rafraîchir'), findsOneWidget);
    expect(find.text('Exporter'), findsOneWidget);
    expect(find.text('Page 1 sur 1'), findsOneWidget);
  });

  testWidgets('à 100 %, la page A4 occupe la largeur du panneau', (
    tester,
  ) async {
    await pumpPanel(tester);

    final page = tester.getSize(find.byKey(pageKey));

    expect(page.width, PdfPreviewPanel.referencePageWidth);
    expect(page.width / page.height, closeTo(210 / 297, 0.001));
  });

  testWidgets('les boutons de zoom changent la taille de la page', (
    tester,
  ) async {
    await pumpPanel(tester);
    final initialWidth = tester.getSize(find.byKey(pageKey)).width;

    await tester.tap(find.byTooltip('Zoom avant'));
    await tester.pump();

    expect(find.text('125 %'), findsOneWidget);
    expect(tester.getSize(find.byKey(pageKey)).width, initialWidth * 1.25);

    await tester.tap(find.byTooltip('Zoom arrière'));
    await tester.tap(find.byTooltip('Zoom arrière'));
    await tester.pump();

    expect(find.text('75 %'), findsOneWidget);
  });

  testWidgets('le zoom reste entre 50 % et 200 %', (tester) async {
    await pumpPanel(tester, initialZoom: 50);

    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Zoom arrière'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('Zoom avant'));
      await tester.pump();
    }

    expect(find.text('200 %'), findsOneWidget);
  });

  testWidgets('Ctrl + molette zoome la page', (tester) async {
    await pumpPanel(tester);
    final center = tester.getCenter(find.byKey(pageKey));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(center));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(find.text('125 %'), findsOneWidget);
  });
}
