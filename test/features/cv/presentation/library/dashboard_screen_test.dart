import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_workspace.dart';
import 'package:cv_maker/features/cv/presentation/library/dashboard_screen.dart';
import 'package:cv_maker/features/cv/presentation/editor/editor_screen.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/desktop_view.dart';
import '../../../../helpers/memory_cv_repository.dart';
import '../../../../helpers/preview_override.dart';

void main() {
  late MemoryCvRepository repository;
  late ProviderContainer container;
  final now = DateTime(2026, 9, 18, 16);

  CvDocument cv(String id, String name, DateTime at) =>
      CvDocument.empty(id: id, now: at, name: name);

  final defaults = [
    cv('dev', 'CV Développeuse', DateTime(2026, 9, 18, 14, 2)),
    cv('design', 'Portfolio design', DateTime(2026, 9, 12, 10)),
    cv('anglais', 'Anglais — resume', DateTime(2026, 8, 1, 9)),
  ];

  Future<void> pumpDashboard(
    WidgetTester tester, {
    List<CvDocument>? documents,
  }) async {
    useDesktopView(tester);
    repository = MemoryCvRepository(documents ?? defaults);
    final overrides = await startupOverrides(repository);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          previewOverride,
          cvThumbnailOverride,
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) =>
              ToastLayer(child: child ?? const SizedBox()),
          home: const DashboardScreen(),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(DashboardScreen)),
    );
  }

  Finder cardOf(String id) => find.byKey(ValueKey(id));

  /// Les CV affichés, dans l'ordre de lecture de la grille.
  List<String> visibleIds(WidgetTester tester) {
    Offset at(String id) => tester.getTopLeft(cardOf(id));
    return [
      for (final id in repository.documents.keys)
        if (tester.any(cardOf(id))) id,
    ]..sort((a, b) {
      final byRow = at(a).dy.compareTo(at(b).dy);
      return byRow != 0 ? byRow : at(a).dx.compareTo(at(b).dx);
    });
  }

  Future<void> chooseAction(
    WidgetTester tester,
    String id,
    String label,
  ) async {
    await tester.tap(
      find.descendant(of: cardOf(id), matching: find.byTooltip('Actions')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  String openId() => container.read(cvSessionProvider).document.id;

  testWidgets('liste les CV du plus récent au plus ancien', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Mes CV'), findsOneWidget);
    expect(find.text('3 CV enregistrés sur cet ordinateur'), findsOneWidget);
    expect(visibleIds(tester), ['dev', 'design', 'anglais']);
    expect(find.text('Modifié aujourd’hui à 14:02'), findsOneWidget);
    expect(find.text('Modifié le 12 septembre 2026'), findsOneWidget);
    expect(find.text('Partir d’un CV vide'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la recherche ignore casse et accents', (tester) async {
    await pumpDashboard(tester);

    await search(tester, 'developpeuse');
    expect(visibleIds(tester), ['dev']);
    expect(
      find.text('Partir d’un CV vide'),
      findsNothing,
      reason: 'la tuile de création s’efface pendant une recherche',
    );

    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(visibleIds(tester), ['dev', 'design', 'anglais']);
  });

  testWidgets('une recherche sans résultat le dit et s’efface', (tester) async {
    await pumpDashboard(tester);

    await search(tester, 'introuvable');

    expect(
      find.text('Aucun CV ne correspond à « introuvable »'),
      findsOneWidget,
    );
    await tester.tap(find.text('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(visibleIds(tester), hasLength(3));
  });

  testWidgets('trie par nom', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Nom'));
    await tester.pumpAndSettle();

    expect(visibleIds(tester), ['anglais', 'dev', 'design']);
  });

  testWidgets('Ctrl+F place le curseur dans la recherche', (tester) async {
    await pumpDashboard(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('un clic sur une carte ouvre le CV dans l’éditeur', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Portfolio design'));
    await tester.pumpAndSettle();

    expect(openId(), 'design');
    expect(find.byType(EditorScreen), findsOneWidget);
  });

  testWidgets('« Ouvrir » du menu ouvre aussi le CV', (tester) async {
    await pumpDashboard(tester);

    await chooseAction(tester, 'anglais', 'Ouvrir');

    expect(openId(), 'anglais');
    expect(find.byType(EditorScreen), findsOneWidget);
  });

  for (final (label, trigger) in [
    ('le bouton', (WidgetTester t) => t.tap(find.text('Nouveau CV').first)),
    ('la tuile', (WidgetTester t) => t.tap(find.text('Partir d’un CV vide'))),
    (
      'Ctrl+N',
      (WidgetTester t) async {
        await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await t.sendKeyEvent(LogicalKeyboardKey.keyN);
        await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      },
    ),
  ]) {
    testWidgets('$label crée un CV et l’ouvre', (tester) async {
      await pumpDashboard(tester);

      await trigger(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EditorScreen), findsOneWidget);
      expect(repository.documents, hasLength(4));
      expect(
        container.read(cvSessionProvider).document.name,
        CvWorkspace.newCvName,
      );
    });
  }

  testWidgets('renommer depuis le menu', (tester) async {
    await pumpDashboard(tester);

    await chooseAction(tester, 'design', 'Renommer');
    await tester.enterText(find.widgetWithText(TextField, 'Nom du CV'), 'Book');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Renommer'));
    await tester.pumpAndSettle();

    expect(repository.documents['design']!.name, 'Book');
    expect(find.text('Book'), findsOneWidget);
    expect(find.byType(EditorScreen), findsNothing);
  });

  testWidgets('dupliquer depuis le menu', (tester) async {
    await pumpDashboard(tester);

    await chooseAction(tester, 'design', 'Dupliquer');

    expect(find.text('Portfolio design (copie)'), findsOneWidget);
    expect(find.text('4 CV enregistrés sur cet ordinateur'), findsOneWidget);
  });

  testWidgets('supprimer depuis le menu, après confirmation', (tester) async {
    await pumpDashboard(tester);

    await chooseAction(tester, 'design', 'Supprimer');
    expect(find.text('Supprimer ce CV ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(repository.documents.containsKey('design'), isTrue);

    await chooseAction(tester, 'design', 'Supprimer');
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.documents.containsKey('design'), isFalse);
    expect(cardOf('design'), findsNothing);
  });

  testWidgets('sans CV, l’accueil invite à en créer un', (tester) async {
    await pumpDashboard(tester, documents: const []);

    expect(find.text('Bienvenue dans CV Maker'), findsOneWidget);
    expect(find.text('Aucun CV enregistré sur cet ordinateur'), findsOneWidget);
    expect(find.byType(TextField), findsNothing, reason: 'pas de recherche');
    expect(find.text('Nouveau CV'), findsNothing, reason: 'un seul bouton');

    await tester.tap(find.text('Créer mon CV'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
    expect(repository.documents, hasLength(1));
  });

  testWidgets('supprimer le dernier CV ramène l’accueil', (tester) async {
    await pumpDashboard(tester, documents: [defaults.first]);

    await chooseAction(tester, 'dev', 'Supprimer');
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue dans CV Maker'), findsOneWidget);
  });

  testWidgets('un échec de création est signalé avec « Réessayer »', (
    tester,
  ) async {
    await pumpDashboard(tester);
    repository.failWrites = true;

    await tester.tap(find.text('Nouveau CV').first);
    await tester.pumpAndSettle();

    expect(find.text('Création impossible'), findsOneWidget);
    expect(find.byType(EditorScreen), findsNothing);

    repository.failWrites = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.byType(EditorScreen), findsOneWidget);
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('un CV illisible ne s’ouvre pas et le signale', (tester) async {
    await pumpDashboard(tester);
    repository.unreadable.add('design');

    await tester.tap(find.text('Portfolio design'));
    await tester.pumpAndSettle();

    expect(find.text('Ouverture impossible'), findsOneWidget);
    expect(find.byType(EditorScreen), findsNothing);
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('un échec de gestion est signalé', (tester) async {
    await pumpDashboard(tester);
    repository.failWrites = true;

    await chooseAction(tester, 'design', 'Dupliquer');

    expect(find.text('Opération impossible'), findsOneWidget);
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('tient dans une fenêtre étroite', (tester) async {
    await pumpDashboard(tester);
    useDesktopView(tester, size: const Size(700, 600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
