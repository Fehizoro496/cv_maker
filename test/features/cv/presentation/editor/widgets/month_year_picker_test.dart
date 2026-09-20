import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:cv_maker/features/cv/presentation/editor/widgets/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/desktop_view.dart';

void main() {
  late CvMonthYearSelection? result;
  var closed = false;

  Future<void> openPicker(WidgetTester tester, {CvMonthYear? initial}) async {
    useDesktopView(tester);
    closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showMonthYearPicker(
                  context,
                  label: 'Début',
                  initialValue: initial,
                );
                closed = true;
              },
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
    await openPicker(tester, initial: const CvMonthYear(2023, 9));

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
    await openPicker(tester, initial: const CvMonthYear(2023, 9));

    await tester.tap(find.byTooltip('Année précédente'));
    await tester.pump();
    await tester.tap(find.text('mars'));
    await tester.pumpAndSettle();

    expect(result?.value, const CvMonthYear(2022, 3));
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('« Année seule » retourne uniquement l\'année', (tester) async {
    await openPicker(tester, initial: const CvMonthYear(2019));

    await tester.tap(find.byTooltip('Année suivante'));
    await tester.pump();
    await tester.tap(find.text('Année 2020 seule'));
    await tester.pumpAndSettle();

    expect(result?.value, const CvMonthYear(2020));
  });

  testWidgets('Effacer retourne une sélection vide', (tester) async {
    await openPicker(tester, initial: const CvMonthYear(2021, 1));

    await tester.tap(find.text('Effacer'));
    await tester.pumpAndSettle();

    // Un effacement se distingue d'une annulation : la sélection existe.
    expect(closed, isTrue);
    expect(result, isNotNull);
    expect(result?.value, isNull);
  });

  testWidgets('Annuler ne retourne aucune sélection', (tester) async {
    await openPicker(tester, initial: const CvMonthYear(2021, 1));

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, isNull);
  });
}
