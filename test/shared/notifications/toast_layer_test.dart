import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/desktop_view.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpLayer(WidgetTester tester) async {
    useDesktopView(tester);
    container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) =>
              ToastLayer(child: child ?? const SizedBox()),
          home: const Scaffold(body: Center(child: Text('écran'))),
        ),
      ),
    );
    await tester.pump();
  }

  AppToastsNotifier toasts() => container.read(appToastsProvider.notifier);

  testWidgets('la couche laisse passer l’écran et n’affiche rien', (
    tester,
  ) async {
    await pumpLayer(tester);
    expect(find.text('écran'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('une notification apparaît avec son titre et son texte', (
    tester,
  ) async {
    await pumpLayer(tester);
    toasts().show(
      kind: AppToastKind.success,
      title: 'PDF exporté',
      message: 'C:/Users/moi/CV.pdf',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('PDF exporté'), findsOneWidget);
    expect(find.text('C:/Users/moi/CV.pdf'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    // Laisser le minuteur expirer : un test ne doit pas s'achever sur un Timer.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('PDF exporté'), findsNothing);
  });

  testWidgets('la croix referme la notification', (tester) async {
    await pumpLayer(tester);
    toasts().show(kind: AppToastKind.info, title: 'Modèle appliqué');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Modèle appliqué'), findsNothing);
    expect(container.read(appToastsProvider), isEmpty);
  });

  testWidgets('l’action est exécutée et referme la notification', (
    tester,
  ) async {
    await pumpLayer(tester);
    var retries = 0;
    toasts().show(
      kind: AppToastKind.error,
      title: "L’export a échoué",
      actionLabel: 'Réessayer',
      actionIcon: Icons.refresh,
      onAction: () => retries++,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Réessayer'));
    await tester.pump();
    expect(retries, 1);
    expect(container.read(appToastsProvider), isEmpty);
  });

  testWidgets('trois notifications au maximum sont affichées', (tester) async {
    await pumpLayer(tester);
    for (final title in ['A', 'B', 'C', 'D']) {
      toasts().show(kind: AppToastKind.info, title: title);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('A'), findsNothing);
    expect(find.byIcon(Icons.close), findsNWidgets(3));
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('une notification reste visible par-dessus un dialogue', (
    tester,
  ) async {
    await pumpLayer(tester);
    toasts().show(kind: AppToastKind.info, title: 'Modèle appliqué');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final context = tester.element(find.text('écran'));
    showDialog<void>(
      context: context,
      builder: (_) => const Dialog(child: Text('catalogue')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('catalogue'), findsOneWidget);
    expect(find.text('Modèle appliqué'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
