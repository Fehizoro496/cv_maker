import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/presentation/welcome_screen.dart';
import 'package:cv_maker/main.dart' as app;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/desktop_view.dart';

void main() {
  // `main` ouvre la base du dossier de données de l'utilisateur : le test
  // passe par `runCvMaker`, qui la reçoit, pour ne jamais y écrire.
  testWidgets('runCvMaker lance CvMakerApp dans un ProviderScope', (
    tester,
  ) async {
    useDesktopView(tester);
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.runAsync(() => app.runCvMaker(DriftCvRepository(db)));
    await tester.pump();

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(CvMakerApp), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
