import 'dart:typed_data';

import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/presentation/library/dashboard_screen.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_catalog_provider.dart';
import 'package:cv_maker/main.dart' as app;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';

import 'helpers/desktop_view.dart';

void main() {
  // `main` ouvre la base du dossier de données de l'utilisateur : le test
  // passe par `runCvMaker`, qui la reçoit, pour ne jamais y écrire.
  testWidgets('runCvMaker lance CvMakerApp dans un ProviderScope', (
    tester,
  ) async {
    useDesktopView(tester);
    final printing = PrintingPlatform.instance;
    PrintingPlatform.instance = _TestPrinting();
    addTearDown(() => PrintingPlatform.instance = printing);
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.runAsync(() => app.runCvMaker(DriftCvRepository(db)));
    await tester.pump();

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(CvMakerApp), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Attend les vignettes lancées au démarrage avant de restaurer le plugin.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CvMakerApp)),
    );
    await tester.runAsync(() async {
      for (final template in container.read(templateCatalogProvider)) {
        expect(
          await container.read(templateThumbnailProvider(template.id).future),
          isNotEmpty,
        );
      }
    });
  });
}

class _TestPrinting extends PrintingPlatform {
  @override
  Stream<PdfRaster> raster(
    Uint8List document,
    List<int>? pages,
    double dpi,
  ) async* {
    yield PdfRaster(1, 1, Uint8List.fromList([0, 0, 0, 255]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
