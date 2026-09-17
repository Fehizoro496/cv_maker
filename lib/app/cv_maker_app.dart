import 'package:flutter/material.dart';

import '../features/cv/presentation/editor_screen.dart';
import 'app_theme.dart';

class CvMakerApp extends StatelessWidget {
  const CvMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Maker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const EditorScreen(),
    );
  }
}
