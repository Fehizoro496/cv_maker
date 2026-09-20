import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../session/cv_session_provider.dart';
import '../preview/widgets/pdf_preview_panel.dart';
import 'widgets/section_editor_panel.dart';
import 'widgets/section_navigation.dart';

/// Écran principal : navigation, formulaire et aperçu PDF.
///
/// Sous [tabsBreakpoint], le formulaire et l'aperçu passent en onglets et la
/// navigation reste visible.
class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  static const navigationWidth = 240.0;
  static const previewWidth = 620.0;
  static const previewMinWidth = 420.0;
  static const editorMinWidth = 440.0;
  static const tabsBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(cvSessionProvider.notifier);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            editor.undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            editor.redo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): editor.redo,
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < tabsBreakpoint;
            final contentWidth = constraints.maxWidth - navigationWidth - 6;

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 6, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    width: navigationWidth,
                    child: SectionNavigation(),
                  ),
                  Expanded(
                    child: isNarrow
                        ? const _EditorTabs()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(child: SectionEditorPanel()),
                              SizedBox(
                                width: _previewWidthFor(contentWidth),
                                child: const PdfPreviewPanel(),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static double _previewWidthFor(double contentWidth) {
    final available = contentWidth - editorMinWidth;
    return available.clamp(previewMinWidth, previewWidth);
  }
}

class _EditorTabs extends StatelessWidget {
  const _EditorTabs();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      animationDuration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadii.control + 2),
              ),
              child: const TabBar(
                tabs: [
                  Tab(
                    height: 34,
                    child: _TabLabel(icon: Icons.edit_note, label: 'Édition'),
                  ),
                  Tab(
                    height: 34,
                    child: _TabLabel(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Aperçu',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                SectionEditorPanel(compact: true),
                PdfPreviewPanel(initialZoom: 85),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    );
  }
}
