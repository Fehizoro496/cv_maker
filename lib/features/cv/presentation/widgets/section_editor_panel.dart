import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/images/photo_bytes.dart';
import '../../../../shared/widgets/soft_panel.dart';
import '../../domain/cv_custom_section.dart';
import '../../domain/cv_design_spec.dart';
import '../../domain/cv_entry.dart';
import '../../domain/cv_month_year.dart';
import '../../domain/cv_presentation_preferences.dart';
import '../../domain/cv_section.dart';
import '../cv_section_forms.dart';
import '../cv_section_presentation.dart';
import '../cv_session_provider.dart';
import '../selected_section_provider.dart';
import 'custom_section_dialogs.dart';
import 'month_year_picker.dart';
import 'save_status_chip.dart';

class SectionEditorPanel extends ConsumerWidget {
  const SectionEditorPanel({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedSectionProvider);
    final document = ref.watch(cvSessionProvider).document;
    final editor = ref.read(cvSessionProvider.notifier);
    final custom = switch (section) {
      CvCustomSectionRef(:final id) => document.customSectionById(id),
      CvSection() => null,
    };
    return SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 18, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final title = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            section.labelIn(document),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontSize: compact ? 16 : 18),
                          ),
                        ),
                        if (custom != null) ...[
                          const SizedBox(width: 10),
                          const _CustomBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      section.helpTextIn(document),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Annuler (Ctrl+Z)',
                      onPressed: editor.canUndo ? editor.undo : null,
                      icon: const Icon(Icons.undo),
                    ),
                    IconButton(
                      tooltip: 'Rétablir (Ctrl+Y)',
                      onPressed: editor.canRedo ? editor.redo : null,
                      icon: const Icon(Icons.redo),
                    ),
                    if (custom != null) _CustomSectionActions(section: custom),
                    const SizedBox(width: 12),
                    Flexible(child: SaveStatusChip(compact: compact)),
                  ],
                );
                if (constraints.maxWidth < 490) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 12),
                    actions,
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: PageStorageKey(switch (section) {
                CvSection(:final name) => 'form-$name',
                CvCustomSectionRef(:final id) => 'form-custom-$id',
              }),
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
              child: switch (section) {
                CvSection.personalInfo => _PersonalForm(compact: compact),
                CvSection.profile => const _DocumentFieldInput(
                  field: CvDocumentFields.profile,
                ),
                // Une liste par CV : l'élément déplié ne passe pas d'un CV à
                // l'autre.
                CvSection() => _EntryList(
                  key: ValueKey((document.id, section)),
                  section: section,
                ),
                CvCustomSectionRef() => switch (custom) {
                  null => const SizedBox.shrink(),
                  CvCustomSection(type: CvCustomSectionType.freeText) =>
                    _TextInput(
                      key: ValueKey(section),
                      label: 'Texte',
                      value: custom.text,
                      lines: 6,
                      onChanged: (value) =>
                          editor.setCustomSectionText(custom.id, value),
                    ),
                  _ => _EntryList(
                    key: ValueKey((document.id, section)),
                    section: section,
                  ),
                },
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Le badge « PERSONNALISÉE » de l'en-tête.
class _CustomBadge extends StatelessWidget {
  const _CustomBadge();

  @override
  Widget build(BuildContext context) => Container(
    height: 20,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Text(
      'PERSONNALISÉE',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.onSurfaceVariant,
      ),
    ),
  );
}

/// Renommer et supprimer une section personnalisée.
class _CustomSectionActions extends ConsumerWidget {
  const _CustomSectionActions({required this.section});
  final CvCustomSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.read(cvSessionProvider.notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Renommer la section',
          onPressed: () async {
            final name = await showRenameCustomSectionDialog(
              context,
              editor.document,
              section,
            );
            if (name != null) editor.renameCustomSection(section.id, name);
          },
          icon: const Icon(Icons.drive_file_rename_outline),
        ),
        IconButton(
          tooltip: 'Supprimer la section',
          onPressed: () async {
            final choice = await showRemoveCustomSectionDialog(
              context,
              section,
            );
            switch (choice) {
              case CustomSectionRemoval.delete:
                editor.removeCustomSection(section.id);
              case CustomSectionRemoval.hide:
                editor.setSectionVisible(CvCustomSectionRef(section.id), false);
              case null:
                break;
            }
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

/// Un champ du document : nom, coordonnées, profil.
class _DocumentFieldInput extends ConsumerWidget {
  const _DocumentFieldInput({required this.field});
  final CvDocumentField field;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(cvSessionProvider).document;
    return _TextInput(
      label: field.label,
      value: field.read(document),
      lines: field.lines,
      onChanged: (value) =>
          ref.read(cvSessionProvider.notifier).setDocumentField(field, value),
    );
  }
}

class _PersonalForm extends StatelessWidget {
  const _PersonalForm({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _FieldRow(
        children: [
          _DocumentFieldInput(field: CvDocumentFields.firstName),
          _DocumentFieldInput(field: CvDocumentFields.lastName),
        ],
      ),
      const SizedBox(height: 18),
      const _DocumentFieldInput(field: CvDocumentFields.headline),
      const SizedBox(height: 18),
      _PhotoCard(compact: compact),
      const SizedBox(height: 18),
      const _FieldRow(
        children: [
          _DocumentFieldInput(field: CvDocumentFields.location),
          _DocumentFieldInput(field: CvDocumentFields.phone),
        ],
      ),
      const SizedBox(height: 14),
      const _FieldRow(
        children: [
          _DocumentFieldInput(field: CvDocumentFields.email),
          _DocumentFieldInput(field: CvDocumentFields.website),
        ],
      ),
      const SizedBox(height: 18),
      Text('Liens', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      const _EntryList(section: CvSection.personalInfo),
    ],
  );
}

/// Le rayon des coins d'une photo de côté [side] découpée en [shape].
double _photoRadius(CvPhotoShape shape, double side) => switch (shape) {
  CvPhotoShape.circle => side / 2,
  CvPhotoShape.rounded => side * CvPhotoShape.roundedCornerRatio,
  CvPhotoShape.square => 0,
};

/// La forme et la taille de la photo dans le CV.
///
/// Sans réglage, la photo garde la forme et la taille du modèle ; les réglages
/// suivent ensuite le CV d'un modèle à l'autre.
class _PhotoFormat extends ConsumerWidget {
  const _PhotoFormat();

  /// Hauteur commune des deux contrôles, alignés sur une même ligne.
  static const controlHeight = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(cvSessionProvider).document;
    final presentation = document.presentation;
    final header = document.designSpec.header;
    final editor = ref.read(cvSessionProvider.notifier);
    final customized =
        presentation.photoShape != null || presentation.photoSizeMm != null;
    const min = CvPresentationPreferences.minPhotoSizeMm;
    const max = CvPresentationPreferences.maxPhotoSizeMm;
    final size = header.photoDiameterMm.clamp(min, max).roundToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Format dans le CV',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // L'origine du format : le modèle, ou un réglage que l'on peut
            // annuler d'un geste.
            SizedBox(
              height: 32,
              child: customized
                  ? TextButton.icon(
                      onPressed: () =>
                          editor.setPhotoFormat(shape: null, sizeMm: null),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.restart_alt, size: 16),
                      label: const Text('Rétablir le modèle'),
                    )
                  : const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Selon le modèle',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Les deux réglages tiennent sur une ligne, et passent l'un sous
        // l'autre dans un panneau étroit.
        Wrap(
          spacing: 24,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LabeledControl(
              label: 'Forme',
              child: _ShapeSelector(
                selected: header.photoShape,
                onSelected: (shape) => editor.setPhotoFormat(
                  shape: shape,
                  sizeMm: presentation.photoSizeMm,
                ),
              ),
            ),
            _LabeledControl(
              label: 'Taille',
              child: _SizeStepper(
                sizeMm: size,
                min: min,
                max: max,
                onChanged: (value) => editor.setPhotoFormat(
                  shape: presentation.photoShape,
                  sizeMm: value,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Un réglage précédé de son libellé, sur la même ligne.
class _LabeledControl extends StatelessWidget {
  const _LabeledControl({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Une largeur fixe aligne les contrôles quand ils passent l'un sous
      // l'autre.
      SizedBox(
        width: 42,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
      child,
    ],
  );
}

/// Le cadre commun des deux contrôles de format.
BoxDecoration _formatControlDecoration() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppRadii.control),
  border: Border.all(color: AppColors.cardBorder),
);

/// Les formes de photo, en choix exclusif : chaque option dessine sa forme.
class _ShapeSelector extends StatelessWidget {
  const _ShapeSelector({required this.selected, required this.onSelected});

  final CvPhotoShape selected;
  final ValueChanged<CvPhotoShape> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: _PhotoFormat.controlHeight,
    padding: const EdgeInsets.all(3),
    decoration: _formatControlDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final shape in CvPhotoShape.values)
          _ShapeOption(
            shape: shape,
            selected: shape == selected,
            onTap: () => onSelected(shape),
          ),
      ],
    ),
  );
}

class _ShapeOption extends StatelessWidget {
  const _ShapeOption({
    required this.shape,
    required this.selected,
    required this.onTap,
  });

  final CvPhotoShape shape;
  final bool selected;
  final VoidCallback onTap;

  /// Côté du glyphe qui représente la forme.
  static const _glyph = 13.0;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: 'Forme ${shape.label}',
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primaryTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.control - 3),
        child: InkWell(
          onTap: selected ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadii.control - 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _glyph,
                  height: _glyph,
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: .18) : null,
                    borderRadius: BorderRadius.circular(
                      _photoRadius(shape, _glyph),
                    ),
                    border: Border.all(color: color, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  shape.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La taille de la photo, millimètre par millimètre, entre [min] et [max].
class _SizeStepper extends StatelessWidget {
  const _SizeStepper({
    required this.sizeMm,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double sizeMm;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, String tooltip, double delta) {
      final next = sizeMm + delta;
      final enabled = next >= min && next <= max;
      return IconButton(
        tooltip: tooltip,
        onPressed: enabled ? () => onChanged(next) : null,
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(_PhotoFormat.controlHeight - 6),
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.onSurface,
          disabledForegroundColor: AppColors.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control - 3),
          ),
        ),
      );
    }

    return Container(
      height: _PhotoFormat.controlHeight,
      padding: const EdgeInsets.all(2),
      decoration: _formatControlDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          step(Icons.remove, 'Réduire la photo', -1),
          SizedBox(
            width: 52,
            child: Semantics(
              liveRegion: true,
              label: 'Taille de la photo : ${sizeMm.round()} millimètres',
              excludeSemantics: true,
              child: Text(
                '${sizeMm.round()} mm',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          step(Icons.add, 'Agrandir la photo', 1),
        ],
      ),
    );
  }
}

class _PhotoCard extends ConsumerWidget {
  const _PhotoCard({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(cvSessionProvider);
    final photo = session.photo;
    final avatarSide = compact ? 52.0 : 64.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La vignette reprend la forme de la photo dans le CV.
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  _photoRadius(
                    session.document.designSpec.header.photoShape,
                    avatarSide,
                  ),
                ),
                child: Container(
                  width: avatarSide,
                  height: avatarSide,
                  color: AppColors.primaryTint,
                  child: photo == null
                      ? const Icon(
                          Icons.account_circle_outlined,
                          size: 30,
                          color: AppColors.primary,
                        )
                      : Image.memory(
                          photo,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo (facultative)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final file = await openFile(
                                acceptedTypeGroups: [
                                  const XTypeGroup(
                                    label: 'Images',
                                    extensions: ['png', 'jpg', 'jpeg'],
                                  ),
                                ],
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              // Décoder avant d'accepter l'image dans la
                              // session, et la ramener à une taille qui
                              // n'alourdit ni la base ni le PDF.
                              final photo = await normalizePhoto(bytes);
                              if (context.mounted) {
                                ref
                                    .read(cvSessionProvider.notifier)
                                    .setPhoto(photo);
                              }
                            } catch (_) {
                              if (context.mounted) {
                                await showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Image illisible'),
                                    content: const Text(
                                      'Choisissez une image PNG ou JPEG valide.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Fermer'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.upload, size: 16),
                          label: Text(
                            compact ? 'Choisir…' : 'Choisir une image',
                          ),
                        ),
                        TextButton(
                          onPressed: photo == null
                              ? null
                              : () => ref
                                    .read(cvSessionProvider.notifier)
                                    .setPhoto(null),
                          child: const Text('Retirer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 15,
                          color: AppColors.outline,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "La photo n'est pas enregistrée : elle devra être ajoutée à nouveau au prochain lancement.",
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.45,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (photo != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.cardBorder),
            ),
            const _PhotoFormat(),
          ],
        ],
      ),
    );
  }
}

class _EntryList extends ConsumerStatefulWidget {
  const _EntryList({super.key, required this.section});
  final CvSectionRef section;
  @override
  ConsumerState<_EntryList> createState() => _EntryListState();
}

class _EntryListState extends ConsumerState<_EntryList> {
  String? _expanded;
  bool _initialized = false;

  /// La valeur d'un champ, telle qu'elle s'affiche dans le résumé replié.
  String _textOf(CvEntryField field, CvEntry entry) => switch (field) {
    CvEntryTextField() => field.read(entry),
    CvEntryMonthYearField() => field.read(entry)?.format() ?? '',
    CvEntryFlagField() => field.read(entry) ? field.label : '',
  };

  /// La période résumée d'un élément : « sept. 2023 → aujourd'hui ».
  String _periodOf(CvSectionForm form, CvEntry entry) {
    final dates = form.fields.whereType<CvEntryMonthYearField>().toList();
    if (dates.isEmpty) return '';
    final start = dates.first.read(entry);
    if (start == null) return '';
    if (dates.length == 1) return start.format();
    final flags = form.fields.whereType<CvEntryFlagField>().toList();
    final current = flags.isNotEmpty && flags.first.read(entry);
    final end = current ? 'aujourd’hui' : dates[1].read(entry)?.format() ?? '';
    return '${start.format()} → $end';
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final document = ref.watch(cvSessionProvider).document;
    final form = cvSectionFormOf(section, document);
    if (form == null) return const SizedBox.shrink();
    final entries = form.read(document);
    final editor = ref.read(cvSessionProvider.notifier);
    if (!_initialized) {
      _expanded = section == CvSection.experiences && entries.isNotEmpty
          ? entries.first.id
          : null;
      _initialized = true;
    }
    void add() => setState(() => _expanded = editor.addEntry(section));
    final addButton = section == CvSection.personalInfo
        ? OutlinedButton.icon(
            onPressed: add,
            icon: const Icon(Icons.add, size: 17),
            label: Text(form.addLabel),
          )
        : FilledButton.tonalIcon(
            onPressed: add,
            icon: const Icon(Icons.add, size: 18),
            label: Text(form.addLabel),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                Icon(section.icon, size: 28, color: AppColors.disabled),
                const SizedBox(height: 8),
                Text(
                  'Aucun élément pour l’instant',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ajoutez un élément : il apparaîtra dans l’aperçu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: entries.length,
          onReorderItem: (oldIndex, newIndex) =>
              editor.reorderEntries(section, oldIndex, newIndex),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final id = entry.id;
            final expanded = _expanded == id;
            final title = _textOf(form.titleField, entry);
            final subtitleField = form.subtitleField;
            final subtitle = subtitleField == null
                ? ''
                : _textOf(subtitleField, entry);
            final period = _periodOf(form, entry);
            return AnimatedContainer(
              key: ValueKey(id),
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: expanded
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.cardBorder,
                ),
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: expanded ? appSoftShadow : null,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Icon(
                              Icons.drag_indicator,
                              size: 18,
                              color: AppColors.disabled,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(
                              () => _expanded = expanded ? null : id,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: title.isEmpty
                                          ? 'Nouvel élément'
                                          : title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty)
                                      TextSpan(
                                        text: ' · $subtitle',
                                        style: const TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    if (period.isNotEmpty)
                                      TextSpan(
                                        text: ' — $period',
                                        style: const TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        _SmallButton(
                          tooltip: 'Supprimer cet élément',
                          icon: Icons.delete_outline,
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                title: const Text('Supprimer cet élément ?'),
                                content: const Text(
                                  'Cet élément sera retiré du CV. Vous pourrez annuler avec Ctrl+Z.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              editor.removeEntry(section, id);
                            }
                          },
                        ),
                        _SmallButton(
                          tooltip: expanded ? 'Replier' : 'Modifier',
                          icon: section == CvSection.personalInfo
                              ? Icons.edit_outlined
                              : expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          onPressed: () =>
                              setState(() => _expanded = expanded ? null : id),
                        ),
                      ],
                    ),
                  ),
                  if (expanded) ...[
                    const Divider(color: AppColors.divider),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var row = 0; row < form.rows.length; row++) ...[
                            if (row > 0) const SizedBox(height: 14),
                            _EntryRow(
                              section: section,
                              entry: entry,
                              fields: form.rows[row],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        addButton,
      ],
    );
  }
}

/// Une rangée de champs d'un élément répétable.
///
/// Une rangée réduite à une case à cocher n'occupe pas toute la largeur.
class _EntryRow extends ConsumerWidget {
  const _EntryRow({
    required this.section,
    required this.entry,
    required this.fields,
  });

  final CvSectionRef section;
  final CvEntry entry;
  final List<CvEntryField> fields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void write(CvEntry updated, String coalesceKey) => ref
        .read(cvSessionProvider.notifier)
        .updateEntry(section, updated, coalesceKey: coalesceKey);

    Widget input(CvEntryField field) {
      final key = '${entry.id}/${field.label}';
      return switch (field) {
        CvEntryTextField() => _TextInput(
          key: ValueKey(key),
          label: field.label,
          value: field.read(entry),
          lines: field.lines,
          onChanged: (value) => write(field.write(entry, value), key),
        ),
        CvEntryMonthYearField() => _MonthYearInput(
          key: ValueKey(key),
          label: field.label,
          value: field.read(entry),
          enabled: field.isEnabled?.call(entry) ?? true,
          onChanged: (value) => write(field.write(entry, value), key),
        ),
        CvEntryFlagField() => _FlagInput(
          key: ValueKey(key),
          label: field.label,
          value: field.read(entry),
          onChanged: (value) => write(field.write(entry, value), key),
        ),
      };
    }

    if (fields.length == 1 && fields.first is CvEntryFlagField) {
      return Align(alignment: Alignment.centerLeft, child: input(fields.first));
    }
    return _FieldRow(children: [for (final field in fields) input(field)]);
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size.square(28),
      minimumSize: const Size.square(28),
      foregroundColor: AppColors.outline,
    ),
    icon: Icon(icon, size: 18),
  );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: 14),
        Expanded(child: children[i]),
      ],
    ],
  );
}

/// Une case à cocher : « En cours », par exemple.
class _FlagInput extends StatelessWidget {
  const _FlagInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 28,
        height: 34,
        child: Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
        ),
      ),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}

/// Un mois et une année, choisis dans le sélecteur plutôt que saisis.
class _MonthYearInput extends StatefulWidget {
  const _MonthYearInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });
  final String label;
  final CvMonthYear? value;
  final ValueChanged<CvMonthYear?> onChanged;
  final bool enabled;

  @override
  State<_MonthYearInput> createState() => _MonthYearInputState();
}

class _MonthYearInputState extends State<_MonthYearInput> {
  late final _controller = TextEditingController(text: _text);

  String get _text => widget.value?.format() ?? '';

  @override
  void didUpdateWidget(covariant _MonthYearInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != _text) _controller.text = _text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final selection = await showMonthYearPicker(
      context,
      label: widget.label,
      initialValue: widget.value,
    );
    if (selection == null || selection.value == widget.value) return;
    widget.onChanged(selection.value);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: TextField(
      controller: _controller,
      enabled: widget.enabled,
      // Les dates se choisissent dans le sélecteur, sans saisie libre.
      readOnly: true,
      onTap: _pick,
      mouseCursor: SystemMouseCursors.click,
      maxLines: 1,
      style: const TextStyle(fontSize: 13, height: 1.2),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: widget.enabled
            ? AppColors.surfaceContainerLow
            : AppColors.disabledFill,
        hintText: 'Choisir…',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.disabled),
        suffixIcon: const Icon(Icons.calendar_month_outlined, size: 17),
        suffixIconConstraints: const BoxConstraints(minWidth: 28),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    ),
  );
}

class _TextInput extends StatefulWidget {
  const _TextInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.lines = 1,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int lines;
  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Une annulation restaure l'état : le champ doit suivre.
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.lines == 1 ? 44 : null,
    child: TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      minLines: widget.lines,
      maxLines: widget.lines == 1 ? 1 : null,
      style: TextStyle(fontSize: 13, height: widget.lines == 1 ? 1.2 : 1.6),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: AppColors.surfaceContainerLow,
        suffixIconConstraints: const BoxConstraints(minWidth: 28),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    ),
  );
}
