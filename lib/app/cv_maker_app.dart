import 'package:flutter/material.dart';

import '../features/cv/presentation/editor_screen.dart';
import '../shared/notifications/toast_layer.dart';
import 'app_theme.dart';

class CvMakerApp extends StatelessWidget {
  const CvMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Maker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Les notifications se posent au-dessus du Navigator : elles restent
      // visibles par-dessus un dialogue et après un changement d'onglet.
      builder: (context, child) => ToastLayer(child: child ?? const SizedBox()),
      home: const EditorScreen(),
    );
  }
}
