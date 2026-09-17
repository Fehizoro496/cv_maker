import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../domain/cv_section.dart';
import '../../domain/cv_design.dart';
import 'design_catalog.dart';
import '../cv_section_presentation.dart';
import '../editor_draft_provider.dart';
import '../section_visibility_provider.dart';
import '../selected_section_provider.dart';

class SectionNavigation extends ConsumerWidget {
  const SectionNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSectionProvider);
    final visibility = ref.watch(sectionVisibilityProvider);
    final mainSections = CvSection.values.where((s) => !s.isOptional);
    final optionalSections = CvSection.values.where((s) => s.isOptional);

    Widget row(CvSection section) => _SectionRow(
      key: ValueKey(section),
      section: section,
      isSelected: section == selected,
      isVisible: visibility[section] ?? true,
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 12),
            child: OutlinedButton.icon(
              onPressed: () async {
                final design = await showDialog<CvDesign>(
                  context: context,
                  builder: (_) => DesignCatalog(
                    selected: ref.read(editorDraftProvider).design,
                  ),
                );
                if (design != null && context.mounted) {
                  ref.read(editorDraftProvider.notifier).setDesign(design);
                }
              },
              icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Catalogue des designs'),
                  Text(
                    ref
                        .watch(
                          editorDraftProvider.select((draft) => draft.design),
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
                  ref.watch(editorDraftProvider).name,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Exemple · non enregistré',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          // Le dialogue « Mes CV » sera branché au jalon J5.
          const IconButton(
            tooltip: 'Mes CV',
            onPressed: null,
            icon: Icon(Icons.unfold_more, size: 18),
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
    required this.isSelected,
    required this.isVisible,
  });

  final CvSection section;
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
    final count =
        section.isOptional ||
            section == CvSection.personalInfo ||
            section == CvSection.profile
        ? null
        : ref.watch(editorDraftProvider).entries[section]?.length ?? 0;

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
                padding: EdgeInsets.only(
                  left: 10,
                  right: section.isOptional ? 4 : 10,
                ),
                child: Row(
                  children: [
                    Icon(section.icon, size: 18, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section.label,
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
                    if (section.isOptional)
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
                            .read(sectionVisibilityProvider.notifier)
                            .toggle(section),
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
