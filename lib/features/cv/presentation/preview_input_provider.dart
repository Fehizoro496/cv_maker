import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_section.dart';
import 'editor_draft_provider.dart';
import 'section_visibility_provider.dart';

class PreviewInput {
  const PreviewInput(this.draft, this.visibility);

  final EditorDraft draft;
  final Map<CvSection, bool> visibility;
}

/// One trailing debounce shared by every field and section of the editor.
final previewInputProvider =
    NotifierProvider<PreviewInputNotifier, PreviewInput>(
      PreviewInputNotifier.new,
    );

final previewDirtyProvider = Provider<bool>((ref) {
  final input = ref.watch(previewInputProvider);
  return !identical(input.draft, ref.watch(editorDraftProvider)) ||
      !identical(input.visibility, ref.watch(sectionVisibilityProvider));
});

class PreviewInputNotifier extends Notifier<PreviewInput> {
  static const delay = Duration(milliseconds: 900);
  Timer? _timer;

  PreviewInput _current() => PreviewInput(
    ref.read(editorDraftProvider),
    ref.read(sectionVisibilityProvider),
  );

  @override
  PreviewInput build() {
    ref.listen(editorDraftProvider, (_, _) => _schedule());
    ref.listen(sectionVisibilityProvider, (_, _) => _schedule());
    ref.onDispose(() => _timer?.cancel());
    return _current();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  /// Refresh and export consume the latest edits without waiting for the timer.
  void flush() {
    _timer?.cancel();
    _timer = null;
    final latest = _current();
    if (!identical(state.draft, latest.draft) ||
        !identical(state.visibility, latest.visibility)) {
      state = latest;
    }
  }
}
