import 'dart:io';
import 'dart:ui' as ui;
import 'package:cv_maker/app/cv_maker_app.dart';
import 'package:cv_maker/features/cv/domain/document/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/selected_section_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/widgets/section_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/desktop_view.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1100, 800),
    const Size(900, 760),
  ]) {
    testWidgets(
      'handoff form and list fit ${size.width.toInt()} px without overflow',
      (tester) async {
        useDesktopView(tester, size: size);
        const capture = bool.fromEnvironment('CAPTURE_DESIGN');
        final pages = <Uint8List>[];
        if (capture) {
          await tester.runAsync(() async {
            final font = FontLoader('Segoe UI')
              ..addFont(
                File(
                  'C:/Windows/Fonts/segoeui.ttf',
                ).readAsBytes().then((b) => ByteData.sublistView(b)),
              );
            await font.load();
            final icons = FontLoader('MaterialIcons')
              ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
            await icons.load();
            pages.add(
              await File('build/design-review/example.png').readAsBytes(),
            );
          });
        }
        final container = ProviderContainer(
          overrides: [
            draftPreviewProvider.overrideWith(
              (ref) async => DraftPreview(Uint8List(0), pages),
            ),
          ],
        );
        addTearDown(container.dispose);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(key: boundary, child: const CvMakerApp()),
          ),
        );
        await tester.pumpAndSettle();
        // L'application s'ouvre sur le tableau de bord.
        await tester.tap(find.text('CV de Camille Moreau'));
        await tester.pumpAndSettle();
        if (capture) {
          await tester.runAsync(
            () => precacheImage(
              MemoryImage(pages.first),
              boundary.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
        }
        expect(find.text('Prénom'), findsOneWidget);
        expect(find.text('Photo (facultative)'), findsOneWidget);
        expect(
          find.text('Formulaire « Informations personnelles » à venir.'),
          findsNothing,
        );
        expect(tester.getSize(find.byType(SectionNavigation)).width, 240);
        expect(tester.takeException(), isNull);
        Future<void> screenshot(String name) async {
          if (!capture) return;
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              'build/design-review/$name-${size.width.toInt()}.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }

        await screenshot('identity');
        container
            .read(selectedSectionProvider.notifier)
            .select(CvSection.experiences);
        await tester.pumpAndSettle();
        expect(find.text('Poste'), findsOneWidget);
        expect(find.text('En cours'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await screenshot('experiences');
        if (size.width < 1100) {
          await tester.tap(find.text('Aperçu'));
          await tester.pumpAndSettle();
          expect(find.text('85 %'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await screenshot('preview');
        }
      },
    );
  }
}
