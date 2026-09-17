import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simule une fenêtre de bureau pour les tests de widgets.
void useDesktopView(WidgetTester tester, {Size size = const Size(1400, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
