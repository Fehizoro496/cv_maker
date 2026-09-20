import 'dart:ui';

import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/features/cv/domain/document/cv_example.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_autosave.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/library/dashboard_screen.dart';
import 'package:cv_maker/features/cv/presentation/editor/editor_screen.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/desktop_view.dart';
import '../helpers/memory_cv_repository.dart';
import '../helpers/preview_override.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpApp(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    useDesktopView(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [previewOverride, ...overrides],
        child: const CvMakerApp(),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
  }

  testWidgets('s’ouvre sur le tableau de bord, titré CV Maker', (tester) async {
    await pumpApp(tester);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'CV Maker');
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(EditorScreen), findsNothing);
  });

  testWidgets('ouvrir un CV mène à l’éditeur, « Mes CV » y ramène', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('CV de Camille Moreau'));
    await tester.pumpAndSettle();
    expect(find.byType(EditorScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Mes CV'));
    await tester.pumpAndSettle();
    expect(find.byType(EditorScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('sans CV enregistré, l’accueil mène à l’éditeur', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        cvRepositoryProvider.overrideWithValue(MemoryCvRepository()),
        initialCvLibraryProvider.overrideWithValue(const []),
      ],
    );
    expect(find.text('Bienvenue dans CV Maker'), findsOneWidget);

    await tester.tap(find.text('Créer mon CV'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorScreen), findsOneWidget);
    expect(find.text('Informations personnelles'), findsWidgets);
  });

  group('fermeture de la fenêtre', () {
    late MemoryCvRepository repository;

    Future<void> pumpEdited(WidgetTester tester) async {
      repository = MemoryCvRepository([exampleCvDocument()]);
      await pumpApp(
        tester,
        overrides: [cvRepositoryProvider.overrideWithValue(repository)],
      );
      container
          .read(cvSessionProvider.notifier)
          .setDocumentField(CvDocumentFields.firstName, 'Alice');
    }

    testWidgets('écrit la saisie en attente avant de quitter', (tester) async {
      await pumpEdited(tester);

      final response = await tester.binding.handleRequestAppExit();

      expect(response, AppExitResponse.exit);
      expect(repository.documents['example']!.personalInfo.firstName, 'Alice');
    });

    testWidgets('un échec retient la fermeture une fois et le signale', (
      tester,
    ) async {
      await pumpEdited(tester);
      repository.failWrites = true;

      final first = await tester.binding.handleRequestAppExit();
      await tester.pump();

      expect(first, AppExitResponse.cancel);
      expect(find.text('Modifications non enregistrées'), findsOneWidget);
      expect(container.read(cvSaveStatusProvider), CvSaveStatus.error);

      final second = await tester.binding.handleRequestAppExit();
      expect(second, AppExitResponse.exit, reason: 'quitter quand même');
      container.read(appToastsProvider.notifier).dismissAll();
      await tester.pump();
    });
  });
}
