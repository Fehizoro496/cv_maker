import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cv_maker/app/app_theme.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/draft_preview_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor_screen.dart';
import 'package:cv_maker/features/cv/presentation/preview_input_provider.dart';
import 'package:cv_maker/shared/notifications/toast_layer.dart';
import 'package:cv_maker/shared/system/reveal_file.dart';
import 'package:cv_maker/shared/system/save_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/desktop_view.dart';
import '../helpers/memory_cv_repository.dart';

/// Laisse tourner l'application sans attendre le repos complet.
///
/// `pumpAndSettle` n'aboutirait pas : l'aperçu affiche un indicateur de
/// progression tant qu'il régénère le PDF, et une animation infinie ne se
/// stabilise jamais. Une seconde simulée suffit ici, et laisse les
/// notifications affichées, qui s'effacent après quatre.
Future<void> settle(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Les critères d'export et de notification de la section 12 du cahier des
/// charges, vérifiés à travers l'interface.
///
/// L'aperçu produit ici des octets dérivés du document plutôt qu'un vrai PDF :
/// générer le PDF demanderait de lire les polices sur le disque, ce qu'un test
/// de widgets ne peut pas faire pendant qu'il pompe des images. Ce que ces
/// tests vérifient est intact : l'export écrit exactement les octets que
/// l'aperçu détient, et attend ceux des dernières modifications. Le contenu du
/// PDF lui-même est couvert par `mvp_acceptance_test.dart` et `cv_pdf_test.dart`.
///
/// Le dialogue d'enregistrement et l'ouverture du dossier passent par leurs
/// providers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory folder;
  late List<String> revealed;
  late List<String> asked;
  String? target;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('cv_export');
    revealed = [];
    asked = [];
    target = '${folder.path}/CV.pdf';
    // Windows garde parfois le fichier exporté ouvert un instant après
    // l'écriture : l'échec du ménage ne doit pas faire échouer le test.
    addTearDown(() {
      try {
        folder.deleteSync(recursive: true);
      } catch (_) {}
    });
  });

  Future<ProviderContainer> pumpEditor(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    useDesktopView(tester);
    final scope = ProviderScope(
      overrides: [
        cvRepositoryProvider.overrideWithValue(
          MemoryCvRepository([exampleCvDocument()]),
        ),
        initialCvLibraryProvider.overrideWithValue(const []),
        draftPreviewProvider.overrideWith((ref) async {
          final session = ref.watch(previewInputProvider);
          return DraftPreview(_bytesOf(session.document), const []);
        }),
        saveLocationProvider.overrideWithValue(({
          required String suggestedName,
        }) async {
          asked.add(suggestedName);
          return target;
        }),
        // L'écriture est synchrone dans le test : une entrée-sortie réelle ne
        // se termine pas sous le temps simulé, et l'export resterait suspendu.
        saveBytesProvider.overrideWithValue(
          (path, bytes) async => File(path).writeAsBytesSync(bytes),
        ),
        revealFileProvider.overrideWithValue((path) async {
          revealed.add(path);
          return true;
        }),
        ...overrides,
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) =>
            ToastLayer(child: child ?? const SizedBox()),
        home: const EditorScreen(),
      ),
    );
    await tester.pumpWidget(scope);
    await settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(EditorScreen)));
  }

  Future<void> export(WidgetTester tester) async {
    await tester.tap(find.text('Exporter'));
    await settle(tester);
  }

  testWidgets('le PDF exporté est identique à celui affiché', (tester) async {
    final container = await pumpEditor(tester);

    await export(tester);

    expect(asked, ['CV.pdf'], reason: 'le nom proposé est celui du handoff');
    final shown = (await container.read(draftPreviewProvider.future)).bytes;
    final exported = File(target!).readAsBytesSync();
    expect(exported, shown);
    expect(find.text('PDF exporté'), findsOne);
  });

  testWidgets('un export demandé avant la mise à jour attend la '
      'régénération des dernières modifications', (tester) async {
    final container = await pumpEditor(tester);
    container
        .read(cvSessionProvider.notifier)
        .setDocumentField(CvDocumentFields.lastName, 'Duparc');

    // Sans laisser passer le debounce : l'aperçu affiché est encore périmé.
    expect(container.read(previewDirtyProvider), isTrue);
    await export(tester);

    final exported = File(target!).readAsBytesSync();
    expect(exported, _bytesOf(container.read(cvSessionProvider).document));
    expect(
      (await container.read(draftPreviewProvider.future)).bytes,
      exported,
      reason: 'l’aperçu affiche à son tour ces octets',
    );
    expect(
      container.read(cvSessionProvider).document.personalInfo.lastName,
      'Duparc',
    );
    expect(find.text('PDF exporté'), findsOne);
  });

  testWidgets('un export réussi propose d’ouvrir le dossier', (tester) async {
    await pumpEditor(tester);

    await export(tester);
    await tester.tap(find.text('Ouvrir le dossier'));
    await settle(tester);

    expect(revealed, [target]);
  });

  testWidgets('un export échoué est signalé et se réessaie', (tester) async {
    // Un dossier inexistant : l'écriture échoue comme un fichier verrouillé.
    target = '${folder.path}/absent/CV.pdf';
    await pumpEditor(tester);

    await export(tester);
    expect(find.text('L’export a échoué'), findsOne);

    target = '${folder.path}/CV.pdf';
    await tester.tap(find.text('Réessayer'));
    await settle(tester);

    expect(File(target!).existsSync(), isTrue);
    expect(find.text('PDF exporté'), findsOne);
  });

  testWidgets('en fenêtre étroite, la notification survit au changement '
      'd’onglet', (tester) async {
    await pumpEditor(tester);
    tester.view.physicalSize = const Size(900, 760);
    await settle(tester);

    await tester.tap(find.text('Aperçu'));
    await settle(tester);
    await export(tester);
    await tester.tap(find.text('Édition'));
    await settle(tester, frames: 3);

    expect(find.byType(TabBar), findsOne);
    expect(find.text('PDF exporté'), findsOne);
  });
}

/// Des octets qui changent avec le document, comme le ferait le PDF.
Uint8List _bytesOf(CvDocument document) =>
    Uint8List.fromList(utf8.encode(jsonEncode(document.toJson())));
