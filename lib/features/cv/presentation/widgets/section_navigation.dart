import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/notifications/app_toast.dart';
import '../../domain/cv_section.dart';
import '../../../../shared/formatting/modified_label.dart';
import '../catalog_preview_provider.dart';
import '../cv_library_provider.dart';
import '../cv_section_presentation.dart';
import '../cv_session_provider.dart';
import '../selected_section_provider.dart';
import 'custom_section_dialogs.dart';
import 'cv_library_dialog.dart';
import 'design_catalog.dart';

class SectionNavigation extends ConsumerWidget {
  const SectionNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSectionProvider);
    final document = ref.watch(cvSessionProvider).document;
    final mainSections = CvSection.values.where((s) => !s.isOptional);
    final optionalSections = CvSection.values.where((s) => s.isOptional);

    Widget row(CvSectionRef section) => _SectionRow(
      // `ValueKey` compare aussi son type : la clé garde le type concret de
      // la section pour rester retrouvable par `ValueKey(CvSection.x)`.
      key: switch (section) {
        final CvSection standard => ValueKey(standard),
        final CvCustomSectionRef custom => ValueKey(custom),
      },
      section: section,
      label: section.labelIn(document),
      isSelected: section == selected,
      isVisible: document.isVisible(section),
    );

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 6, 4),
            child: _OpenCvHeader(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
              children: [
                const _GroupLabel('Sections'),
                ...mainSections.map(row),
                const SizedBox(height: 14),
                const _GroupLabel('Sections facultatives'),
                ...optionalSections.map(row),
                for (final custom in document.customSections)
                  row(CvCustomSectionRef(custom.id)),
                const SizedBox(height: 10),
                const _AddSectionButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 12),
            child: OutlinedButton.icon(
              onPressed: () async {
                final session = ref.read(cvSessionProvider);
                final presentation = session.document.presentation;
                final choice = await showDialog<CatalogChoice>(
                  context: context,
                  builder: (_) => DesignCatalog(
                    selected: presentation.design,
                    accentArgb: presentation.accentColor,
                    showPhoto: presentation.showPhoto,
                    hasPhoto: session.hasPhoto,
                  ),
                );
                if (choice == null || !context.mounted) return;
                ref
                    .read(cvSessionProvider.notifier)
                    .applyTemplate(
                      design: choice.design,
                      accentArgb: choice.accentArgb,
                      showPhoto: choice.showPhoto,
                    );
                ref
                    .read(appToastsProvider.notifier)
                    .show(
                      kind: AppToastKind.info,
                      title: 'Modèle appliqué',
                      message: choice.design.label,
                    );
              },
              icon: const Icon(Icons.style, size: 18),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Catalogue des modèles'),
                  Text(
                    ref
                        .watch(
                          cvSessionProvider.select(
                            (session) => session.document.design,
                          ),
                        )
                        .label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const _OfflineFooter(),
        ],
      ),
    );
  }
}

class _OpenCvHeader extends ConsumerWidget {
  const _OpenCvHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final document = ref.watch(cvSessionProvider).document;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: appSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CV OUVERT', style: textTheme.labelSmall),
                const SizedBox(height: 1),
                Text(
                  document.name.isEmpty ? 'Sans titre' : document.name,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  modifiedLabel(
                    document.updatedAt,
                    now: ref.read(clockProvider)(),
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Mes CV',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.primary,
              fixedSize: const Size.square(32),
              minimumSize: const Size.square(32),
            ),
            onPressed: () => showCvLibraryDialog(context),
            icon: const Icon(Icons.folder_open_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _SectionRow extends ConsumerStatefulWidget {
  const _SectionRow({
    super.key,
    required this.section,
    required this.label,
    required this.isSelected,
    required this.isVisible,
  });

  final CvSectionRef section;
  final String label;
  final bool isSelected;
  final bool isVisible;

  @override
  ConsumerState<_SectionRow> createState() => _SectionRowState();
}

class _SectionRowState extends ConsumerState<_SectionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final isSelected = widget.isSelected;
    final isVisible = widget.isVisible;
    final Color textColor;
    final Color iconColor;
    if (!isVisible) {
      textColor = AppColors.disabled;
      iconColor = AppColors.disabled;
    } else if (isSelected) {
      textColor = AppColors.onSecondaryContainer;
      iconColor = AppColors.primary;
    } else {
      textColor = AppColors.onSurfaceVariant;
      iconColor = AppColors.outline;
    }
    // Une section qu'on peut masquer porte l'œil à la place du compteur.
    final canHide = switch (section) {
      CvSection(:final isOptional) => isOptional,
      CvCustomSectionRef() => true,
    };
    final count =
        canHide ||
            section == CvSection.personalInfo ||
            section == CvSection.profile
        ? null
        : ref.watch(cvSessionProvider).document.entriesOf(section).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              ref.read(selectedSectionProvider.notifier).select(section),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              // Blanc transparent : un fondu depuis Colors.transparent (noir)
              // assombrit la ligne pendant l'animation.
              color: isSelected
                  ? AppColors.surface
                  : _hovered
                  ? AppColors.hover
                  : AppColors.surface.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(AppRadii.control),
              boxShadow: isSelected ? appSoftShadow : null,
            ),
            child: SizedBox(
              height: 36,
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: canHide ? 4 : 10),
                child: Row(
                  children: [
                    Icon(section.icon, size: 18, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (canHide)
                      IconButton(
                        tooltip: isVisible
                            ? 'Affichée dans le CV'
                            : 'Masquée dans le CV',
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(28),
                          fixedSize: const Size.square(28),
                          foregroundColor: isVisible
                              ? AppColors.outline
                              : AppColors.disabledBorder,
                        ),
                        iconSize: 16,
                        onPressed: () => ref
                            .read(cvSessionProvider.notifier)
                            .setSectionVisible(section, !isVisible),
                        icon: Icon(
                          isVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    if (count != null)
                      Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryTint
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ouvre le dialogue « Nouvelle section », crée la section et la sélectionne.
class _AddSectionButton extends ConsumerWidget {
  const _AddSectionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => CustomPaint(
    foregroundPainter: const _DashedBorderPainter(
      color: AppColors.disabledBorder,
      radius: 18,
    ),
    child: SizedBox(
      height: 36,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final choice = await showNewCustomSectionDialog(
            context,
            ref.read(cvSessionProvider).document,
          );
          if (choice == null || !context.mounted) return;
          final id = ref
              .read(cvSessionProvider.notifier)
              .addCustomSection(choice.name, choice.type);
          ref
              .read(selectedSectionProvider.notifier)
              .select(CvCustomSectionRef(id));
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Ajouter une section'),
      ),
    ),
  );
}

/// Bordure pointillée arrondie : Flutter n'en fournit pas.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.5),
      );
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += dash + gap) {
        canvas.drawPath(metric.extractPath(at, at + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _OfflineFooter extends StatelessWidget {
  const _OfflineFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 8, 12, 12),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 14, color: AppColors.outline),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Hors ligne — données sur cet ordinateur',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }
}
