import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/shared/widgets/soft_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dessine une surface arrondie avec une ombre douce', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SoftPanel(child: Text('Contenu')),
      ),
    );

    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .ancestor(
                        of: find.text('Contenu'),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;

    expect(find.text('Contenu'), findsOneWidget);
    expect(decoration.color, AppColors.surface);
    expect(decoration.borderRadius, BorderRadius.circular(SoftPanel.radius));
    expect(decoration.boxShadow, appSoftShadow);
  });

  testWidgets('applique la marge autour du panneau', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 200,
            height: 100,
            child: SoftPanel(
              margin: EdgeInsets.all(10),
              child: SizedBox.expand(key: Key('child')),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('child'))), const Size(180, 80));
  });
}
