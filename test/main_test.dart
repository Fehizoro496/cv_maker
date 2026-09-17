import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/desktop_view.dart';

void main() {
  testWidgets('main lance CvMakerApp dans un ProviderScope', (tester) async {
    useDesktopView(tester);

    app.main();
    await tester.pump();

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(CvMakerApp), findsOneWidget);
  });
}
