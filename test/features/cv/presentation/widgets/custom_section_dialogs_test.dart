import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/presentation/widgets/custom_section_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';

void main() {
  const publications = CvCustomSection(
    id: 'pubs',
    name: 'Publications',
    type: CvCustomSectionType.datedList,
    items: [
      CvCustomItem(id: 'a'),
      CvCustomItem(id: 'b'),
    ],
  );
  final document = exampleCvDocument().copyWith(
    customSections: const [publications],
  );

  /// Ouvre le dialogue produit par [open] et renvoie la valeur qu'il rend.
  Future<List<T?>> pumpDialog<T>(
    WidgetTester tester,
    Future<T?> Function(BuildContext context) open,
  ) async {
    useDesktopView(tester);
    final results = <T?>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(await open(context)),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    return results;
  }

  group('Nouvelle section', () {
    Future<List<NewCustomSection?>> open(
      WidgetTester tester, [
      CvDocument? on,
    ]) => pumpDialog(
      tester,
      (context) => showNewCustomSectionDialog(context, on ?? document),
    );

    testWidgets('présente les trois types et la mention du type figé', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Nouvelle section'), findsOneWidget);
      expect(find.text('Texte libre'), findsOneWidget);
      expect(find.text('Liste datée'), findsOneWidget);
      expect(find.text('Liste simple'), findsOneWidget);
      expect(
        find.text('Le type ne pourra plus être changé après la création.'),
        findsOneWidget,
      );
      // Le champ du nom a le focus dès l'ouverture.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
    });

    testWidgets('rend le nom et le type choisis', (tester) async {
      final results = await open(tester);
      await tester.enterText(find.byType(TextField), '  Bénévolat ');
      await tester.tap(find.text('Liste simple'));
      await tester.pump();
      await tester.tap(find.text('Créer la section'));
      await tester.pumpAndSettle();
      expect(results, hasLength(1));
      expect(results.single?.name, 'Bénévolat');
      expect(results.single?.type, CvCustomSectionType.simpleList);
    });

    testWidgets('refuse un nom vide sans fermer', (tester) async {
      final results = await open(tester);
      expect(find.text('Donnez un nom à la section.'), findsNothing);
      await tester.tap(find.text('Créer la section'));
      await tester.pump();
      expect(find.text('Donnez un nom à la section.'), findsOneWidget);
      expect(find.text('Nouvelle section'), findsOneWidget);
      expect(results, isEmpty);
    });

    testWidgets('refuse un doublon, y compris d’une section standard', (
      tester,
    ) async {
      final results = await open(tester);
      await tester.enterText(find.byType(TextField), 'publications');
      await tester.pump();
      expect(find.text('Une section porte déjà ce nom.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Compétences');
      await tester.pump();
      expect(find.text('Une section porte déjà ce nom.'), findsOneWidget);
      await tester.tap(find.text('Créer la section'));
      await tester.pump();
      expect(results, isEmpty);
    });

    testWidgets('limite la saisie à 40 caractères', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), 'a' * 60);
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, hasLength(40));
    });

    testWidgets('Annuler ne rend rien', (tester) async {
      final results = await open(tester);
      await tester.enterText(find.byType(TextField), 'Bénévolat');
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(results, [null]);
    });
  });

  group('Renommer la section', () {
    testWidgets('part du nom actuel et rend le nouveau', (tester) async {
      final results = await pumpDialog(
        tester,
        (context) =>
            showRenameCustomSectionDialog(context, document, publications),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Publications');
      await tester.enterText(find.byType(TextField), 'Articles ');
      await tester.tap(find.text('Renommer'));
      await tester.pumpAndSettle();
      expect(results, ['Articles']);
    });

    testWidgets('désactive le renommage vers un nom déjà pris', (tester) async {
      await pumpDialog(
        tester,
        (context) =>
            showRenameCustomSectionDialog(context, document, publications),
      );
      FilledButton rename() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Renommer'),
      );
      expect(rename().onPressed, isNotNull);
      await tester.enterText(find.byType(TextField), 'Projets');
      await tester.pump();
      expect(find.text('Une section porte déjà ce nom.'), findsOneWidget);
      expect(rename().onPressed, isNull);
    });
  });

  group('Supprimer la section', () {
    Future<List<CustomSectionRemoval?>> open(
      WidgetTester tester,
      CvCustomSection section,
    ) => pumpDialog(
      tester,
      (context) => showRemoveCustomSectionDialog(context, section),
    );

    testWidgets('rappelle le nombre d’éléments et propose le masquage', (
      tester,
    ) async {
      final results = await open(tester, publications);
      expect(
        find.text('Supprimer la section « Publications » ?'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Ses 2 éléments seront supprimés'),
        findsOneWidget,
      );
      expect(find.textContaining('masquez-la plutôt'), findsOneWidget);
      await tester.tap(find.text('Masquer'));
      await tester.pumpAndSettle();
      expect(results, [CustomSectionRemoval.hide]);
    });

    testWidgets('confirme la suppression', (tester) async {
      final results = await open(tester, publications);
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(results, [CustomSectionRemoval.delete]);
    });

    testWidgets('Annuler ne supprime rien', (tester) async {
      final results = await open(tester, publications);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(results, [null]);
    });

    testWidgets('une section déjà masquée ne propose pas de la masquer', (
      tester,
    ) async {
      await open(tester, publications.copyWith(visible: false, items: []));
      expect(find.text('Masquer'), findsNothing);
      expect(find.textContaining('aucun élément'), findsOneWidget);
    });
  });
}
