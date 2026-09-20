import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/domain/document/cv_example.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_autosave.dart';
import 'package:cv_maker/features/cv/presentation/library/cv_library_provider.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/memory_cv_repository.dart';

void main() {
  late MemoryCvRepository repository;
  late ProviderContainer container;
  late CvSessionNotifier editor;
  late CvAutosave autosave;
  var now = DateTime.utc(2026, 9, 18, 14);

  setUp(() {
    now = DateTime.utc(2026, 9, 18, 14);
    repository = MemoryCvRepository([exampleCvDocument()]);
    container = ProviderContainer(
      overrides: [
        cvRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    editor = container.read(cvSessionProvider.notifier);
    autosave = container.read(cvAutosaveProvider);
  });

  CvSaveStatus status() => container.read(cvSaveStatusProvider);
  Future<void> pause() =>
      Future<void>.delayed(CvAutosave.delay + const Duration(milliseconds: 80));
  CvDocument stored([String id = 'example']) => repository.documents[id]!;

  test('rien n’est écrit tant que la saisie continue', () async {
    editor.setDocumentField(CvDocumentFields.firstName, 'A');
    expect(status(), CvSaveStatus.saving);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    editor.setDocumentField(CvDocumentFields.firstName, 'Al');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(repository.saves, isEmpty, reason: 'la pause est repartie à zéro');

    await pause();
    expect(repository.saves, hasLength(1));
    expect(stored().personalInfo.firstName, 'Al');
    expect(status(), CvSaveStatus.saved);
  });

  test('l’écriture est datée par l’horloge et met la liste à jour', () async {
    editor.rename('example', 'CV candidature');
    now = DateTime.utc(2026, 9, 18, 15);

    await autosave.flush();

    expect(stored().updatedAt, now);
    final summary = container.read(cvLibraryProvider).single;
    expect(summary.name, 'CV candidature');
    expect(summary.updatedAt, now);
  });

  test('un état restauré par annulation est enregistré', () async {
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    await autosave.flush();
    now = now.add(const Duration(seconds: 1));

    editor.undo();
    await pause();

    expect(stored().personalInfo.firstName, 'Camille');

    now = now.add(const Duration(seconds: 1));
    editor.redo();
    await autosave.flush();
    expect(stored().personalInfo.firstName, 'Alice');
  });

  test('changer la photo n’écrit rien', () async {
    editor.setPhoto(Uint8List.fromList([1, 2, 3]));
    await pause();

    expect(repository.saves, isEmpty);
    expect(status(), CvSaveStatus.saved);
  });

  test('ouvrir un autre CV n’est pas une modification', () async {
    editor.open(CvDocument.empty(id: 'other', now: now));
    await pause();

    expect(repository.saves, isEmpty);
  });

  test('un CV quitté avant l’écriture est enregistré quand même', () async {
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    editor.open(CvDocument.empty(id: 'other', now: now));

    await pause();

    expect(stored().personalInfo.firstName, 'Alice');
    expect(repository.documents.containsKey('other'), isFalse);
  });

  test('un échec passe en erreur et garde les modifications', () async {
    repository.failWrites = true;
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

    expect(await autosave.flush(), isFalse);
    expect(status(), CvSaveStatus.error);
    expect(autosave.hasPending, isTrue);
    expect(editor.document.personalInfo.firstName, 'Alice');

    repository.failWrites = false;
    expect(await autosave.flush(), isTrue, reason: 'réessayer');
    expect(status(), CvSaveStatus.saved);
    expect(stored().personalInfo.firstName, 'Alice');
  });

  test('une frappe après un échec repart en attente', () async {
    repository.failWrites = true;
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    await autosave.flush();
    repository.failWrites = false;

    editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
    expect(status(), CvSaveStatus.saving);
    await pause();

    expect(status(), CvSaveStatus.saved);
    expect(stored().personalInfo.lastName, 'Martin');
  });

  test('flush sans rien en attente réussit sans écrire', () async {
    expect(await autosave.flush(), isTrue);
    expect(repository.saves, isEmpty);
  });

  test('discard renonce à l’écriture d’un CV', () async {
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');

    autosave.discard('example');
    await pause();

    expect(repository.saves, isEmpty);
    expect(status(), CvSaveStatus.saved);
  });

  test('une modification pendant l’écriture reste en attente', () async {
    repository.writeDelay = const Duration(milliseconds: 60);
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    final writing = autosave.flush();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repository.saves, hasLength(1), reason: 'écriture commencée');
    editor.setDocumentField(CvDocumentFields.lastName, 'Martin');

    await writing;

    expect(autosave.hasPending, isTrue);
    expect(stored().personalInfo.lastName, 'Moreau');
    await pause();
    await pause();
    expect(stored().personalInfo.lastName, 'Martin');
  });

  test('les opérations s’exécutent dans l’ordre de leur demande', () async {
    final order = <int>[];

    await Future.wait([
      autosave.run(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        order.add(1);
      }),
      autosave.run(() async => order.add(2)),
    ]);

    expect(order, [1, 2]);
  });

  test('une opération qui échoue ne bloque pas les suivantes', () async {
    final failing = autosave.run<void>(() async => throw StateError('échec'));

    await expectLater(failing, throwsStateError);
    expect(await autosave.run(() async => 42), 42);
  });

  group('photo', () {
    final photo = Uint8List.fromList(List.filled(16, 0xAB));

    test('une photo choisie est écrite après la pause', () async {
      editor.setPhoto(photo);
      expect(status(), CvSaveStatus.saving);
      expect(repository.photos, isEmpty);

      await pause();

      expect(repository.photos['example'], photo);
      expect(status(), CvSaveStatus.saved);
    });

    test('elle s’écrit sans faire réécrire le document', () async {
      await autosave.flush();
      repository.saves.clear();

      editor.setPhoto(photo);
      await autosave.flush();

      expect(repository.photos['example'], photo);
      expect(repository.saves, isEmpty, reason: 'le document n’a pas changé');
    });

    test('retirer la photo l’efface', () async {
      editor.setPhoto(photo);
      await autosave.flush();

      editor.setPhoto(null);
      await autosave.flush();

      expect(repository.photos, isEmpty);
    });

    test('une annulation réenregistre la photo restaurée', () async {
      editor.setPhoto(photo);
      await autosave.flush();
      editor.setPhoto(null);
      await autosave.flush();

      editor.undo();
      await autosave.flush();

      expect(repository.photos['example'], photo);
    });

    test('un échec d’écriture laisse la photo en attente', () async {
      repository.failWrites = true;

      editor.setPhoto(photo);
      expect(await autosave.flush(), isFalse);
      expect(status(), CvSaveStatus.error);
      expect(autosave.hasPending, isTrue);

      repository.failWrites = false;
      expect(await autosave.flush(), isTrue);
      expect(repository.photos['example'], photo);
      expect(status(), CvSaveStatus.saved);
    });
  });
}
