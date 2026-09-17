import 'dart:typed_data';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/editor_draft_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });
  test('editing a field preserves the example and supports undo/redo', () {
    final before = container.read(editorDraftProvider);
    final editor = container.read(editorDraftProvider.notifier);
    editor.setField('Prénom', 'Alice');
    editor.setField('Prénom', 'Alicia');
    expect(before.fields['Prénom'], 'Camille');
    expect(container.read(editorDraftProvider).name, 'Alicia Moreau');
    editor.undo();
    expect(container.read(editorDraftProvider).name, 'Camille Moreau');
    editor.redo();
    expect(container.read(editorDraftProvider).name, 'Alicia Moreau');
  });
  test(
    'entries can be added, edited, reordered and removed without losing IDs',
    () {
      final editor = container.read(editorDraftProvider.notifier);
      final id = editor.add(CvSection.experiences);
      editor.setEntry(CvSection.experiences, id, 'Poste', 'Designer');
      editor.reorder(CvSection.experiences, 3, 0);
      expect(
        container
            .read(editorDraftProvider)
            .entries[CvSection.experiences]!
            .first['id'],
        id,
      );
      editor.remove(CvSection.experiences, id);
      expect(
        container
            .read(editorDraftProvider)
            .entries[CvSection.experiences]!
            .length,
        3,
      );
      editor.undo();
      expect(
        container
            .read(editorDraftProvider)
            .entries[CvSection.experiences]!
            .first['Poste'],
        'Designer',
      );
    },
  );
  test(
    'photo changes can be undone and a new session does not retain them',
    () {
      final editor = container.read(editorDraftProvider.notifier);
      editor.setPhoto(Uint8List.fromList([1, 2, 3]));
      editor.setPhoto(null);
      editor.undo();
      expect(container.read(editorDraftProvider).photo, [1, 2, 3]);
      final next = ProviderContainer();
      addTearDown(next.dispose);
      expect(next.read(editorDraftProvider).photo, isNull);
      expect(next.read(editorDraftProvider.notifier).canUndo, isFalse);
    },
  );
}
