import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/shared/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/desktop_view.dart';

void main() {
  late Color? result;
  var closed = false;

  Future<void> openPicker(
    WidgetTester tester, {
    Color initial = const Color(0xFF2F5D8C),
    List<Color> suggestions = const [],
  }) async {
    useDesktopView(tester);
    result = null;
    closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showColorPicker(
                  context,
                  initial: initial,
                  suggestions: suggestions,
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

  Color previewColor(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.byKey(const Key('color-picker-preview')),
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  group('la notation hexadécimale', () {
    test('s’écrit sans canal alpha, en majuscules', () {
      expect(ColorPickerDialog.hexOf(const Color(0xFF2F5D8C)), '#2F5D8C');
      expect(ColorPickerDialog.hexOf(const Color(0xFF000000)), '#000000');
      expect(ColorPickerDialog.hexOf(const Color(0x00AB12CD)), '#AB12CD');
    });

    test('se relit, avec ou sans dièse', () {
      expect(ColorPickerDialog.parseHex('#2F5D8C'), const Color(0xFF2F5D8C));
      expect(ColorPickerDialog.parseHex('2f5d8c'), const Color(0xFF2F5D8C));
      expect(ColorPickerDialog.parseHex('  #FFFFFF '), const Color(0xFFFFFFFF));
    });

    test('refuse une notation incomplète ou invalide', () {
      expect(ColorPickerDialog.parseHex('#2F5D8'), isNull);
      expect(ColorPickerDialog.parseHex(''), isNull);
      expect(ColorPickerDialog.parseHex('#ZZZZZZ'), isNull);
    });

    test('tout aller-retour conserve la couleur', () {
      for (final color in [
        const Color(0xFF2F5D8C),
        const Color(0xFF1E5233),
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
      ]) {
        expect(
          ColorPickerDialog.parseHex(ColorPickerDialog.hexOf(color)),
          color,
        );
      }
    });
  });

  testWidgets('le sélecteur s’ouvre sur la couleur fournie', (tester) async {
    await openPicker(tester, initial: const Color(0xFF1E5233));
    expect(find.text('Couleur d’accent'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('color-picker-hex')))
          .controller!
          .text,
      '#1E5233',
    );
    expect(previewColor(tester), const Color(0xFF1E5233));
  });

  testWidgets('une saisie hexadécimale valide met à jour l’aperçu', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    expect(previewColor(tester), const Color(0xFFAB12CD));
  });

  testWidgets('une saisie incomplète laisse l’aperçu tranquille', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.enterText(find.byKey(const Key('color-picker-hex')), '#AB12');
    await tester.pump();
    expect(previewColor(tester), const Color(0xFF2F5D8C));
  });

  testWidgets('choisir retourne la couleur composée', (tester) async {
    await openPicker(tester);
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Choisir'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(result, const Color(0xFFAB12CD));
  });

  testWidgets('annuler ne retourne aucune couleur', (tester) async {
    await openPicker(tester);
    await tester.enterText(
      find.byKey(const Key('color-picker-hex')),
      '#AB12CD',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(result, isNull);
  });

  testWidgets('la barre de teintes change la couleur', (tester) async {
    await openPicker(tester);
    final before = previewColor(tester);
    final bar = tester.getRect(find.byKey(const Key('color-picker-hue')));
    // Un clic au tiers de la barre : une autre teinte que le bleu de départ.
    await tester.tapAt(Offset(bar.left + bar.width / 3, bar.center.dy));
    await tester.pumpAndSettle();
    expect(previewColor(tester), isNot(before));
  });

  testWidgets('la zone de saturation change la couleur', (tester) async {
    await openPicker(tester);
    final before = previewColor(tester);
    final area = tester.getRect(find.byKey(const Key('color-picker-area')));
    // En haut à droite : saturation maximale, luminosité maximale.
    await tester.tapAt(Offset(area.right - 2, area.top + 2));
    await tester.pumpAndSettle();
    final after = previewColor(tester);
    expect(after, isNot(before));
    // Le champ suit la couleur choisie dans la zone.
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('color-picker-hex')))
          .controller!
          .text,
      ColorPickerDialog.hexOf(after),
    );
  });

  testWidgets('sans suggestions, aucune pastille n’est proposée', (
    tester,
  ) async {
    await openPicker(tester);
    expect(find.text('SUGGESTIONS'), findsNothing);
  });

  testWidgets('une suggestion applique sa couleur', (tester) async {
    const suggestions = [Color(0xFF2F5D8C), Color(0xFF7A2F4A)];
    await openPicker(tester, suggestions: suggestions);
    expect(find.text('SUGGESTIONS'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('suggestion-#7A2F4A')));
    await tester.pumpAndSettle();
    expect(previewColor(tester), const Color(0xFF7A2F4A));
    await tester.tap(find.widgetWithText(FilledButton, 'Choisir'));
    await tester.pumpAndSettle();
    expect(result, const Color(0xFF7A2F4A));
  });
}
