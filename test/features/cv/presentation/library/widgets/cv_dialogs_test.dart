import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/presentation/library/widgets/cv_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Ouvre [dialog] et retourne une fonction qui lit sa valeur de retour.
  Future<T? Function()> show<T>(WidgetTester tester, Widget dialog) async {
    T? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<T>(
                context: context,
                builder: (_) => dialog,
              );
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    return () => result;
  }

  FilledButton renameButton(WidgetTester tester) =>
      tester.widget(find.widgetWithText(FilledButton, 'Renommer'));

  group('renommer', () {
    testWidgets('le nom actuel est présélectionné', (tester) async {
      await show<String>(tester, const RenameCvDialog(name: 'CV design'));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'CV design');
      expect(field.controller!.selection.start, 0);
      expect(field.controller!.selection.end, 'CV design'.length);
    });

    testWidgets('un nom vide est refusé', (tester) async {
      await show<String>(tester, const RenameCvDialog(name: 'CV'));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      expect(renameButton(tester).onPressed, isNull);
    });

    testWidgets('renvoie le nom sans espaces superflus', (tester) async {
      final result = await show<String>(
        tester,
        const RenameCvDialog(name: 'CV'),
      );

      await tester.enterText(find.byType(TextField), '  CV graphisme ');
      await tester.pump();
      await tester.tap(find.text('Renommer'));
      await tester.pumpAndSettle();

      expect(result(), 'CV graphisme');
    });

    testWidgets('Entrée valide le nom', (tester) async {
      final result = await show<String>(
        tester,
        const RenameCvDialog(name: 'CV'),
      );

      await tester.enterText(find.byType(TextField), 'Autre');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result(), 'Autre');
    });

    testWidgets('annuler renvoie null', (tester) async {
      final result = await show<String>(
        tester,
        const RenameCvDialog(name: 'CV'),
      );

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result(), isNull);
    });
  });

  group('supprimer', () {
    testWidgets('rappelle le nom et le caractère définitif', (tester) async {
      await show<bool>(tester, const DeleteCvDialog(name: 'CV design'));

      expect(find.text('Supprimer ce CV ?'), findsOneWidget);
      expect(
        find.text(
          '« CV design » sera supprimé définitivement de cet ordinateur. '
          'Cette action est irréversible.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('confirmer renvoie true, annuler false', (tester) async {
      var result = await show<bool>(tester, const DeleteCvDialog(name: 'CV'));
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(result(), isTrue);

      result = await show<bool>(tester, const DeleteCvDialog(name: 'CV'));
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(result(), isFalse);
    });
  });
}
