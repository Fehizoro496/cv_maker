import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_workspace.dart';
import 'package:cv_maker/features/cv/presentation/welcome_screen.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/desktop_view.dart';
import '../../../helpers/memory_cv_repository.dart';

void main() {
  late MemoryCvRepository repository;
  late ProviderContainer container;

  Future<void> pumpWelcome(WidgetTester tester) async {
    useDesktopView(tester);
    repository = MemoryCvRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cvRepositoryProvider.overrideWithValue(repository),
          initialCvLibraryProvider.overrideWithValue(const []),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) =>
              ToastLayer(child: child ?? const SizedBox()),
          home: const WelcomeScreen(),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(WelcomeScreen)),
    );
  }

  testWidgets('invite à créer un premier CV, hors ligne', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('Bienvenue dans CV Maker'), findsOneWidget);
    expect(find.text('Fonctionne hors ligne, sans compte'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Créer mon CV'), findsOneWidget);
  });

  testWidgets('« Créer mon CV » enregistre et ouvre un CV vide', (
    tester,
  ) async {
    await pumpWelcome(tester);

    await tester.tap(find.text('Créer mon CV'));
    await tester.pumpAndSettle();

    final document = container.read(cvSessionProvider).document;
    expect(document.name, CvWorkspace.newCvName);
    expect(repository.documents.keys, [document.id]);
    expect(container.read(cvLibraryProvider).single.id, document.id);
  });

  testWidgets('un échec de création est signalé avec « Réessayer »', (
    tester,
  ) async {
    await pumpWelcome(tester);
    repository.failWrites = true;

    await tester.tap(find.text('Créer mon CV'));
    await tester.pumpAndSettle();

    expect(find.text('Création impossible'), findsOneWidget);
    expect(container.read(cvLibraryProvider), isEmpty);

    repository.failWrites = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(container.read(cvLibraryProvider), hasLength(1));
    container.read(appToastsProvider.notifier).dismissAll();
    await tester.pumpAndSettle();
  });
}
