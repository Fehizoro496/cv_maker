import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_session.dart';
import 'cv_session_provider.dart';

/// La session telle que l'aperçu la connaît : la saisie s'y répercute après
/// une courte pause.
///
/// Un seul debounce couvre toutes les modifications du CV, quelle que soit la
/// section ou le champ édité.
final previewInputProvider = NotifierProvider<PreviewInputNotifier, CvSession>(
  PreviewInputNotifier.new,
);

/// Vrai lorsque la session contient des modifications que l'aperçu n'a pas
/// encore prises en compte.
final previewDirtyProvider = Provider<bool>(
  (ref) =>
      !identical(ref.watch(previewInputProvider), ref.watch(cvSessionProvider)),
);

class PreviewInputNotifier extends Notifier<CvSession> {
  static const delay = Duration(milliseconds: 900);
  Timer? _timer;

  @override
  CvSession build() {
    ref.listen(cvSessionProvider, (_, _) => _schedule());
    ref.onDispose(() => _timer?.cancel());
    return ref.read(cvSessionProvider);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  /// Refresh and export consume the latest edits without waiting for the timer.
  void flush() {
    _timer?.cancel();
    _timer = null;
    final latest = ref.read(cvSessionProvider);
    if (!identical(state, latest)) state = latest;
  }
}
