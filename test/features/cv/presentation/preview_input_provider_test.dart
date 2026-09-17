import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/editor_draft_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview_input_provider.dart';
import 'package:cv_maker/features/cv/presentation/section_visibility_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all fields share one trailing debounce without delaying input', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var updates = 0;
    container.listen(previewInputProvider, (_, _) => updates++);
    final editor = container.read(editorDraftProvider.notifier);
    editor.setField('Prénom', 'Alice');
    await tester.pump(const Duration(milliseconds: 600));
    editor.setEntry(CvSection.experiences, 'exp-1', 'Poste', 'Designer');
    await tester.pump(const Duration(milliseconds: 600));
    editor.setField('Profil professionnel', 'Nouveau profil');
    expect(container.read(editorDraftProvider).fields['Prénom'], 'Alice');
    expect(container.read(previewDirtyProvider), isTrue);
    await tester.pump(const Duration(milliseconds: 899));
    expect(updates, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(updates, 1);
    final input = container.read(previewInputProvider);
    expect(input.draft.fields['Prénom'], 'Alice');
    expect(input.draft.fields['Profil professionnel'], 'Nouveau profil');
    expect(
      input.draft.entries[CvSection.experiences]!.first['Poste'],
      'Designer',
    );
    expect(container.read(previewDirtyProvider), isFalse);
  });

  testWidgets('flush publishes latest inputs once and cancels the timer', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var updates = 0;
    container.listen(previewInputProvider, (_, _) => updates++);
    container.read(editorDraftProvider.notifier).setField('Nom', 'Martin');
    container
        .read(sectionVisibilityProvider.notifier)
        .toggle(CvSection.projects);
    container.read(previewInputProvider.notifier).flush();
    expect(updates, 1);
    expect(container.read(previewInputProvider).draft.fields['Nom'], 'Martin');
    expect(
      container.read(previewInputProvider).visibility[CvSection.projects],
      isFalse,
    );
    await tester.pump(const Duration(seconds: 2));
    container.read(previewInputProvider.notifier).flush();
    expect(updates, 1);
  });

  testWidgets('unchanged values do not schedule another refresh', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var updates = 0;
    container.listen(previewInputProvider, (_, _) => updates++);
    final editor = container.read(editorDraftProvider.notifier);
    editor.setField('Prénom', 'Camille');
    editor.setEntry(
      CvSection.experiences,
      'exp-1',
      'Poste',
      'Développeuse Front-End',
    );
    await tester.pump(const Duration(seconds: 2));
    expect(updates, 0);
    expect(editor.canUndo, isFalse);
  });

  testWidgets(
    'disposing cancels the timer and undo publishes the restored value',
    (tester) async {
      final container = ProviderContainer();
      container.listen(previewInputProvider, (_, _) {});
      final editor = container.read(editorDraftProvider.notifier);
      editor.setField('Nom', 'Martin');
      editor.undo();
      await tester.pump(const Duration(milliseconds: 900));
      expect(
        container.read(previewInputProvider).draft.fields['Nom'],
        'Moreau',
      );
      editor.redo();
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
}
