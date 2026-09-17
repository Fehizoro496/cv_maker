import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/features/cv/presentation/editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/desktop_view.dart';

void main() {
  testWidgets("affiche l'écran d'édition avec le titre CV Maker", (
    tester,
  ) async {
    useDesktopView(tester);

    await tester.pumpWidget(const ProviderScope(child: CvMakerApp()));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'CV Maker');
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
    expect(find.byType(EditorScreen), findsOneWidget);
  });
}
