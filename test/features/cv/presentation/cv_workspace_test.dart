import 'dart:io';
import 'dart:typed_data';

import 'package:cv_maker/app/bootstrap.dart';
import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_autosave.dart';
import 'package:cv_maker/features/cv/presentation/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/cv_workspace.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Une application lancée sur le fichier de base du test.
class _Launch {
  _Launch(this.db, this.container);

  final CvDatabase db;
  final ProviderContainer container;

  CvWorkspace get workspace => container.read(cvWorkspaceProvider);
  CvSessionNotifier get editor => container.read(cvSessionProvider.notifier);
  String get openId => container.read(cvSessionProvider).document.id;
  List<String> get libraryIds =>
      container.read(cvLibraryProvider).map((s) => s.id).toList();
  DriftCvRepository get repository => DriftCvRepository(db);

  /// Ferme l'application comme la fenêtre le ferait : écriture de ce qui
  /// attend, puis arrêt.
  Future<void> close() async {
    await workspace.saveBeforeExit();
    await quit();
  }

  /// Arrête l'application sans rien écrire.
  Future<void> quit() async {
    container.dispose();
    await db.close();
  }
}

void main() {
  late File file;
  var tick = DateTime.utc(2026, 9, 18, 10);
  final running = <_Launch>[];

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('cv_workspace_test');
    file = File('${dir.path}/cv_maker.sqlite');
    tick = DateTime.utc(2026, 9, 18, 10);
    // Windows refuse de supprimer un fichier encore ouvert : les bases se
    // ferment avant le dossier.
    addTearDown(() async {
      for (final launch in running) {
        try {
          await launch.quit();
        } catch (_) {
          // Déjà arrêtée par le test.
        }
      }
      running.clear();
      await dir.delete(recursive: true);
    });
  });

  /// Lance l'application comme `main`, mais sur le fichier du test et avec
  /// une horloge qui avance d'une seconde à chaque lecture.
  Future<_Launch> launch() async {
    final db = CvDatabase(NativeDatabase(file));
    final container = ProviderContainer(
      overrides: [
        ...await startupOverrides(DriftCvRepository(db)),
        clockProvider.overrideWithValue(
          () => tick = tick.add(const Duration(seconds: 1)),
        ),
      ],
    );
    container.read(cvAutosaveProvider);
    final app = _Launch(db, container);
    running.add(app);
    return app;
  }

  /// Un premier lancement suivi de la création de [count] CV.
  Future<_Launch> launchWith(int count) async {
    final app = await launch();
    for (var i = 0; i < count; i++) {
      await app.workspace.create();
    }
    return app;
  }

  group('premier lancement', () {
    test('une base vide ne liste aucun CV', () async {
      final app = await launch();

      expect(app.libraryIds, isEmpty);
    });

    test('créer un CV l’enregistre et l’ouvre sur l’identité', () async {
      final app = await launch();
      app.container
          .read(selectedSectionProvider.notifier)
          .select(CvSection.skills);

      await app.workspace.create();

      final document = app.container.read(cvSessionProvider).document;
      expect(document.name, CvWorkspace.newCvName);
      expect(document.personalInfo.firstName, isEmpty);
      expect(app.libraryIds, [document.id]);
      expect(await app.repository.read(document.id), document);
      expect(
        app.container.read(selectedSectionProvider),
        CvSection.personalInfo,
      );
      expect(app.editor.canUndo, isFalse);
    });
  });

  group('changer de CV', () {
    test('écrit les modifications en attente avant de changer', () async {
      final app = await launchWith(2);
      final first = app.libraryIds.last;
      final second = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

      await app.workspace.open(first);

      expect(app.openId, first);
      final saved = await app.repository.read(second);
      expect(saved!.personalInfo.firstName, 'Alice', reason: 'sans attendre');
    });

    test('un changement de CV avec sauvegarde en attente survit au '
        'redémarrage', () async {
      final app = await launchWith(2);
      final first = app.libraryIds.last;
      final second = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
      await app.workspace.open(first);
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Bruno');
      await app.close();

      final next = await launch();
      final repository = next.repository;

      expect((await repository.read(second))!.personalInfo.firstName, 'Alice');
      expect((await repository.read(first))!.personalInfo.firstName, 'Bruno');
    });

    test('ouvrir un CV inconnu échoue sans rien changer', () async {
      final app = await launchWith(1);
      final open = app.openId;

      expect(await app.workspace.open('absent'), isFalse);
      expect(app.openId, open);
    });

    test('ouvrir le CV courant ne fait rien', () async {
      final app = await launchWith(1);
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

      expect(await app.workspace.open(app.openId), isTrue);
      expect(app.editor.canUndo, isTrue);
    });

    test('chaque CV garde son historique, vide au redémarrage', () async {
      final app = await launchWith(2);
      final first = app.libraryIds.last;
      final second = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
      await app.workspace.open(first);
      expect(app.editor.canUndo, isFalse);

      await app.workspace.open(second);
      expect(app.editor.canUndo, isTrue);
      app.editor.undo();
      expect(app.editor.document.personalInfo.firstName, isEmpty);
      await app.close();

      final next = await launch();
      await next.workspace.open(second);
      expect(next.editor.canUndo, isFalse);
      expect(next.editor.canRedo, isFalse);
      expect(
        next.editor.document.personalInfo.firstName,
        isEmpty,
        reason: 'l’annulation a été enregistrée',
      );
    });
  });

  group('fermeture', () {
    test('une sauvegarde en attente est écrite avant la fermeture', () async {
      final app = await launchWith(1);
      final id = app.openId;
      app.editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
      expect(app.container.read(cvSaveStatusProvider), CvSaveStatus.saving);

      await app.close();

      final next = await launch();
      await next.workspace.open(id);
      expect(next.editor.document.personalInfo.lastName, 'Martin');
    });

    test(
      'sans écriture avant l’arrêt, la dernière frappe est perdue',
      () async {
        final app = await launchWith(1);
        final id = app.openId;
        app.editor.setDocumentField(CvDocumentFields.lastName, 'Martin');

        await app.quit();

        final next = await launch();
        await next.workspace.open(id);
        expect(next.editor.document.personalInfo.lastName, isEmpty);
      },
    );

    test('le dernier CV modifié est en tête de liste au lancement', () async {
      final app = await launchWith(3);
      final oldest = app.libraryIds.last;
      await app.workspace.open(oldest);
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Récent');
      await app.close();

      final next = await launch();

      expect(next.libraryIds.first, oldest);
      expect(
        next.libraryIds,
        isNot(contains(next.openId)),
        reason: 'aucun CV n’est ouvert avant le choix sur le tableau de bord',
      );
    });

    test('un échec d’écriture est signalé à la fermeture', () async {
      final app = await launchWith(1);
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
      await app.db.close();

      expect(await app.workspace.saveBeforeExit(), isFalse);
      expect(app.container.read(cvSaveStatusProvider), CvSaveStatus.error);
    });
  });

  group('contenu retrouvé après redémarrage', () {
    test('sections personnalisées, contenu, ordre et visibilité', () async {
      final app = await launchWith(1);
      final id = app.openId;
      final editor = app.editor;
      final dated = editor.addCustomSection(
        'Publications',
        CvCustomSectionType.datedList,
      );
      final text = editor.addCustomSection(
        'Motivation',
        CvCustomSectionType.freeText,
      );
      final simple = editor.addCustomSection(
        'Distinctions',
        CvCustomSectionType.simpleList,
      );
      final item = editor.addEntry(CvCustomSectionRef(dated));
      final entry =
          editor.entriesOf(CvCustomSectionRef(dated)).single as CvCustomItem;
      editor.updateEntry(
        CvCustomSectionRef(dated),
        entry.copyWith(title: 'Article'),
      );
      editor.setCustomSectionText(text, 'Un paragraphe.');
      editor.setSectionVisible(CvCustomSectionRef(simple), false);
      editor.setSectionVisible(CvSection.projects, false);
      final expected = editor.document;
      await app.close();

      final next = await launch();
      await next.workspace.open(id);
      final document = next.editor.document;

      expect(document.customSections, expected.customSections);
      expect(document.customSections.map((s) => s.id), [dated, text, simple]);
      expect(document.customSectionById(dated)!.items.single.id, item);
      expect(document.customSectionById(text)!.text, 'Un paragraphe.');
      expect(document.isVisible(CvCustomSectionRef(simple)), isFalse);
      expect(document.isVisible(CvSection.projects), isFalse);
    });

    test('le modèle, la couleur d’accent et l’affichage de la photo', () async {
      final app = await launchWith(1);
      final id = app.openId;
      app.editor.applyTemplate(
        design: CvDesign.academic,
        accentArgb: 0xFF8C1D18,
        showPhoto: false,
      );
      await app.close();

      final next = await launch();
      await next.workspace.open(id);
      final presentation = next.editor.document.presentation;

      expect(presentation.design, CvDesign.academic);
      expect(presentation.accentColor, 0xFF8C1D18);
      expect(presentation.showPhoto, isFalse);
    });
  });

  group('photos de session', () {
    test(
      'propres à chaque CV, jamais écrites, absentes au redémarrage',
      () async {
        final app = await launchWith(2);
        final first = app.libraryIds.last;
        final second = app.openId;
        final photo = Uint8List.fromList(List.filled(64, 0xAB));
        app.editor.setPhoto(photo);
        app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

        await app.workspace.open(first);
        expect(app.container.read(cvSessionProvider).photo, isNull);
        await app.workspace.open(second);
        expect(app.container.read(cvSessionProvider).photo, same(photo));

        final records = await app.db.select(app.db.cvRecords).get();
        for (final record in records) {
          expect(record.document, isNot(contains('photo')));
          expect(record.document, isNot(contains('171,171,171')));
        }
        await app.close();

        final next = await launch();
        await next.workspace.open(second);
        expect(next.container.read(cvSessionProvider).photo, isNull);
        expect(next.editor.document.personalInfo.firstName, 'Alice');
      },
    );
  });

  group('renommer', () {
    test('le CV ouvert : enregistré aussitôt et annulable', () async {
      final app = await launchWith(1);
      final id = app.openId;

      await app.workspace.rename(id, 'CV candidature');

      expect(app.editor.document.name, 'CV candidature');
      expect(
        app.container.read(cvLibraryProvider).first.name,
        'CV candidature',
      );
      expect((await app.repository.read(id))!.name, 'CV candidature');

      app.editor.undo();
      expect(app.editor.document.name, CvWorkspace.newCvName);
    });

    test('un CV fermé : le renommage s’annule une fois ouvert', () async {
      final app = await launchWith(2);
      final closed = app.libraryIds.last;

      await app.workspace.rename(closed, 'Ancien CV');

      expect(app.openId, isNot(closed));
      expect((await app.repository.read(closed))!.name, 'Ancien CV');
      await app.workspace.open(closed);
      expect(app.editor.document.name, 'Ancien CV');
      app.editor.undo();
      expect(app.editor.document.name, CvWorkspace.newCvName);
    });

    test('un nom inchangé n’écrit rien', () async {
      final app = await launchWith(1);
      final before = (await app.repository.read(app.openId))!.updatedAt;

      await app.workspace.rename(app.openId, CvWorkspace.newCvName);

      expect((await app.repository.read(app.openId))!.updatedAt, before);
      expect(app.editor.canUndo, isFalse);
    });
  });

  group('dupliquer', () {
    test('copie le dernier état sans ouvrir la copie', () async {
      final app = await launchWith(1);
      final source = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

      await app.workspace.duplicate(source);

      expect(app.openId, source);
      expect(app.libraryIds, hasLength(2));
      final copyId = app.libraryIds.firstWhere((id) => id != source);
      final copy = await app.repository.read(copyId);
      expect(copy!.name, '${CvWorkspace.newCvName} (copie)');
      expect(copy.personalInfo.firstName, 'Alice');
      expect(app.libraryIds.first, copyId, reason: 'la plus récente');
    });
  });

  group('supprimer', () {
    test('un CV fermé disparaît de la base et de la liste', () async {
      final app = await launchWith(2);
      final closed = app.libraryIds.last;
      final open = app.openId;

      expect(await app.workspace.delete(closed), isTrue);

      expect(app.libraryIds, [open]);
      expect(await app.repository.read(closed), isNull);
      expect(app.openId, open);
    });

    test('le CV ouvert laisse la place au plus récent des autres', () async {
      final app = await launchWith(3);
      final ids = app.libraryIds;
      final open = app.openId;
      app.editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

      await app.workspace.delete(open);
      await Future<void>.delayed(
        CvAutosave.delay + const Duration(milliseconds: 100),
      );

      expect(app.openId, ids[1]);
      expect(
        await app.repository.read(open),
        isNull,
        reason: 'la sauvegarde en attente ne le recrée pas',
      );
      expect(app.container.read(cvSaveStatusProvider), CvSaveStatus.saved);
    });

    test('supprimer le dernier CV vide la liste', () async {
      final app = await launchWith(1);

      expect(await app.workspace.delete(app.openId), isFalse);

      expect(app.libraryIds, isEmpty);
      expect(await app.repository.list(), isEmpty);
    });
  });
}
