import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cv/presentation/session/cv_autosave.dart';
import '../features/cv/presentation/library/cv_workspace.dart';
import '../features/cv/presentation/library/dashboard_screen.dart';
import '../shared/notifications/app_toast.dart';
import '../shared/notifications/toast_layer.dart';
import 'app_theme.dart';

class CvMakerApp extends ConsumerStatefulWidget {
  const CvMakerApp({super.key});

  @override
  ConsumerState<CvMakerApp> createState() => _CvMakerAppState();
}

class _CvMakerAppState extends ConsumerState<CvMakerApp> {
  late final AppLifecycleListener _lifecycle;

  /// Vrai après un premier refus de fermer : la fermeture suivante quitte
  /// même si l'écriture échoue encore.
  bool _exitWarned = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onExitRequested: _onExitRequested);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Écrit les modifications en attente avant de laisser la fenêtre se
  /// fermer. Un échec retient la fermeture une fois, le temps de le signaler.
  Future<AppExitResponse> _onExitRequested() async {
    final saved = await ref.read(cvWorkspaceProvider).saveBeforeExit();
    if (saved || _exitWarned) return AppExitResponse.exit;
    _exitWarned = true;
    ref
        .read(appToastsProvider.notifier)
        .show(
          kind: AppToastKind.error,
          title: 'Modifications non enregistrées',
          message:
              'L’enregistrement a échoué. Réessayez, ou fermez de nouveau '
              'pour quitter sans les enregistrer.',
        );
    return AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) {
    // La sauvegarde automatique vit aussi longtemps que l'application.
    ref.watch(cvAutosaveProvider);
    return MaterialApp(
      title: 'CV Maker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Les notifications se posent au-dessus du Navigator : elles restent
      // visibles par-dessus un dialogue et après un changement d'onglet.
      builder: (context, child) => ToastLayer(child: child ?? const SizedBox()),
      // L'éditeur se pousse par-dessus le tableau de bord à l'ouverture d'un
      // CV.
      home: const DashboardScreen(),
    );
  }
}
