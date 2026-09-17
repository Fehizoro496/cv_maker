import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/presentation/widgets/design_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(900, 760),
    const Size(480, 640),
  ]) {
    testWidgets(
      'catalog shows previews and selects a design at ${size.width}',
      (tester) async {
        useDesktopView(tester, size: size);
        CvDesign? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showDialog<CvDesign>(
                      context: context,
                      builder: (_) =>
                          const DesignCatalog(selected: CvDesign.professional),
                    );
                  },
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Ouvrir'));
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsNWidgets(3));
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('choose-design-professional')),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
        final choose = find.byKey(const ValueKey('choose-design-modern'));
        await tester.ensureVisible(choose);
        await tester.pumpAndSettle();
        await tester.tap(choose);
        await tester.pumpAndSettle();
        expect(result, CvDesign.modern);
        expect(find.byType(DesignCatalog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('closing the catalog does not select another design', (
    tester,
  ) async {
    useDesktopView(tester);
    CvDesign? result = CvDesign.minimal;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showDialog<CvDesign>(
                  context: context,
                  builder: (_) =>
                      const DesignCatalog(selected: CvDesign.minimal),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fermer le catalogue'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
