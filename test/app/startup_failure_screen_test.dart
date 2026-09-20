import 'package:cv_maker/app/startup_failure_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/desktop_view.dart';

void main() {
  testWidgets('annonce l’échec et propose de réessayer', (tester) async {
    useDesktopView(tester);
    var retries = 0;

    await tester.pumpWidget(StartupFailureApp(onRetry: () async => retries++));

    expect(find.text('Les CV enregistrés n’ont pas pu être lus'), findsOne);
    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('affiche la cause technique quand elle est connue', (
    tester,
  ) async {
    useDesktopView(tester);

    await tester.pumpWidget(
      StartupFailureApp(
        onRetry: () async {},
        details: 'SqliteException(11): database disk image is malformed',
      ),
    );

    expect(find.textContaining('disk image is malformed'), findsOne);
  });

  testWidgets('sans cause technique, aucun encart ne s’affiche', (
    tester,
  ) async {
    useDesktopView(tester);

    await tester.pumpWidget(
      const MaterialApp(home: StartupFailureScreen(onRetry: _nothing)),
    );

    expect(find.byType(Text), findsNWidgets(3));
  });
}

Future<void> _nothing() async {}
