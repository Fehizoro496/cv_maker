import 'package:cv_maker/features/cv/domain/document/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/session/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/preview/preview_input_provider.dart';
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
    final editor = container.read(cvSessionProvider.notifier);
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    await tester.pump(const Duration(milliseconds: 600));
    final experience = container
        .read(cvSessionProvider)
        .document
        .experiences
        .first;
    editor.updateEntry(
      CvSection.experiences,
      experience.copyWith(position: 'Designer'),
    );
    await tester.pump(const Duration(milliseconds: 600));
    editor.setDocumentField(CvDocumentFields.profile, 'Nouveau profil');
    expect(
      container.read(cvSessionProvider).document.personalInfo.firstName,
      'Alice',
    );
    expect(container.read(previewDirtyProvider), isTrue);
    await tester.pump(const Duration(milliseconds: 899));
    expect(updates, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(updates, 1);
    final document = container.read(previewInputProvider).document;
    expect(document.personalInfo.firstName, 'Alice');
    expect(document.profile, 'Nouveau profil');
    expect(document.experiences.first.position, 'Designer');
    expect(container.read(previewDirtyProvider), isFalse);
  });

  testWidgets('flush publishes latest inputs once and cancels the timer', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var updates = 0;
    container.listen(previewInputProvider, (_, _) => updates++);
    final editor = container.read(cvSessionProvider.notifier);
    editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
    editor.setSectionVisible(CvSection.projects, false);
    container.read(previewInputProvider.notifier).flush();
    expect(updates, 1);
    final document = container.read(previewInputProvider).document;
    expect(document.personalInfo.lastName, 'Martin');
    expect(document.isVisible(CvSection.projects), isFalse);
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
    final editor = container.read(cvSessionProvider.notifier);
    final experience = container
        .read(cvSessionProvider)
        .document
        .experiences
        .first;
    editor.setDocumentField(CvDocumentFields.firstName, 'Camille');
    editor.updateEntry(CvSection.experiences, experience);
    await tester.pump(const Duration(seconds: 2));
    expect(updates, 0);
    expect(editor.canUndo, isFalse);
  });

  testWidgets(
    'disposing cancels the timer and undo publishes the restored value',
    (tester) async {
      final container = ProviderContainer();
      container.listen(previewInputProvider, (_, _) {});
      final editor = container.read(cvSessionProvider.notifier);
      editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
      editor.undo();
      await tester.pump(const Duration(milliseconds: 900));
      expect(
        container.read(previewInputProvider).document.personalInfo.lastName,
        'Moreau',
      );
      editor.redo();
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
}
