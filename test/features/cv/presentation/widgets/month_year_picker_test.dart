import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/presentation/widgets/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

void main() {
  late String? result;

  Future<void> openPicker(WidgetTester tester, {String initial = ''}) async {
    useDesktopView(tester);
    result = 'non fermé';
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showMonthYearPicker(
                context,
                label: 'Début',
                initialValue: initial,
              ),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
  }

  String shownYear(WidgetTester tester) => tester
      .widget<Text>(find.byKey(const Key('month-year-picker-year')))
      .data!;

  testWidgets("s'ouvre sur l'année de la date existante", (tester) async {
    await openPicker(tester, initial: 'sept. 2023');

    expect(find.text('Début'), findsOneWidget);
    expect(shownYear(tester), '2023');
    expect(
      find.widgetWithText(FilledButton, 'sept.'),
      findsOneWidget,
      reason: 'le mois actuel est mis en évidence',
    );
  });

  testWidgets("s'ouvre sur l'année en cours sans date", (tester) async {
    await openPicker(tester);

    expect(shownYear(tester), '${DateTime.now().year}');
    expect(find.text('Effacer'), findsNothing);
  });

  testWidgets('choisir un mois retourne le mois et l\'année', (tester) async {
    await openPicker(tester, initial: 'sept. 2023');

    await tester.tap(find.byTooltip('Année précédente'));
    await tester.pump();
    await tester.tap(find.text('mars'));
    await tester.pumpAndSettle();

    expect(result, 'mars 2022');
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('« Année seule » retourne uniquement l\'année', (tester) async {
    await openPicker(tester, initial: '2019');

    await tester.tap(find.byTooltip('Année suivante'));
    await tester.pump();
    await tester.tap(find.text('Année 2020 seule'));
    await tester.pumpAndSettle();

    expect(result, '2020');
  });

  testWidgets('Effacer retourne une chaîne vide', (tester) async {
    await openPicker(tester, initial: 'janv. 2021');

    await tester.tap(find.text('Effacer'));
    await tester.pumpAndSettle();

    expect(result, '');
  });

  testWidgets('Annuler retourne null', (tester) async {
    await openPicker(tester, initial: 'janv. 2021');

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
