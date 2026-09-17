import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nature d'une notification, qui détermine sa couleur et son icône.
enum AppToastKind { progress, info, success, error }

/// Une notification ponctuelle affichée en bas à droite de la fenêtre.
///
/// Les notifications sont des données : le contrôleur les empile, la couche
/// d'affichage les rend. Aucune ne dépend d'un `BuildContext`, ce qui permet de
/// les émettre depuis un provider comme depuis un widget.
@immutable
class AppToast {
  const AppToast({
    required this.id,
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  /// Identifiant de la notification, utilisé pour la refermer.
  final String id;
  final AppToastKind kind;

  /// Titre court, toujours présent.
  final String title;

  /// Texte secondaire facultatif : chemin de fichier, cause d'un échec.
  final String? message;

  /// Libellé de l'action facultative, par exemple « Ouvrir le dossier ».
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  bool get hasAction => actionLabel != null && onAction != null;

  /// Une notification porteuse d'une action reste affichée plus longtemps.
  Duration get duration =>
      hasAction ? const Duration(seconds: 6) : const Duration(seconds: 4);
}

/// Les notifications visibles, de la plus ancienne à la plus récente.
///
/// La plus récente s'affiche en bas de la pile, comme le prévoit le design.
final appToastsProvider = NotifierProvider<AppToastsNotifier, List<AppToast>>(
  AppToastsNotifier.new,
);

class AppToastsNotifier extends Notifier<List<AppToast>> {
  /// Au-delà, la plus ancienne notification laisse la place.
  static const maxVisible = 3;

  final _timers = <String, Timer>{};
  var _sequence = 0;

  @override
  List<AppToast> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });
    return const [];
  }

  /// Affiche une notification et retourne son identifiant.
  ///
  /// [progress] désigne une notification d'attente : elle ne disparaît pas
  /// d'elle-même, car c'est la fin de l'opération qui la referme.
  String show({
    required AppToastKind kind,
    required String title,
    String? message,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    final toast = AppToast(
      id: 'toast-${_sequence++}',
      kind: kind,
      title: title,
      message: message,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      onAction: onAction,
    );
    final kept = [...state, toast];
    // La plus ancienne cède la place : au-delà de trois, la pile devient
    // illisible et masque l'aperçu.
    while (kept.length > maxVisible) {
      dismiss(kept.removeAt(0).id, keepState: true);
    }
    state = kept;
    if (kind != AppToastKind.progress) {
      _timers[toast.id] = Timer(toast.duration, () => dismiss(toast.id));
    }
    return toast.id;
  }

  /// Referme une notification, à la demande de l'utilisateur ou du minuteur.
  ///
  /// [keepState] sert au remplacement interne d'une notification trop ancienne,
  /// dont l'état est déjà en cours de recalcul.
  void dismiss(String id, {bool keepState = false}) {
    _timers.remove(id)?.cancel();
    if (keepState) return;
    if (!state.any((toast) => toast.id == id)) return;
    state = [
      for (final toast in state)
        if (toast.id != id) toast,
    ];
  }

  void dismissAll() {
    for (final id in state.map((toast) => toast.id).toList()) {
      _timers.remove(id)?.cancel();
    }
    state = const [];
  }
}
