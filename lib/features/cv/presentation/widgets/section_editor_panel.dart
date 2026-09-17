import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/soft_panel.dart';
import '../../domain/cv_section.dart';
import '../cv_section_presentation.dart';
import '../editor_draft_provider.dart';
import '../selected_section_provider.dart';
import 'month_year_picker.dart';

class SectionEditorPanel extends ConsumerWidget {
  const SectionEditorPanel({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedSectionProvider);
    ref.watch(editorDraftProvider);
    final editor = ref.read(editorDraftProvider.notifier);
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
                    Text(
                      section.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: compact ? 16 : 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      section.helpText,
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
                    const SizedBox(width: 12),
                    Tooltip(
                      message:
                          "Exemple modifiable en mémoire. La sauvegarde locale n'est pas encore disponible.",
                      child: Container(
                        height: compact ? 26 : 28,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Non enregistré',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
              key: PageStorageKey('form-${section.name}'),
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
              child: switch (section) {
                CvSection.personalInfo => _PersonalForm(compact: compact),
                CvSection.profile => _DraftField(
                  label: 'Profil professionnel',
                  value:
                      ref
                          .watch(editorDraftProvider)
                          .fields['Profil professionnel'] ??
                      '',
                  lines: 6,
                  onChanged: (value) =>
                      editor.setField('Profil professionnel', value),
                ),
                _ => _EntryList(key: ValueKey(section), section: section),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalForm extends ConsumerWidget {
  const _PersonalForm({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(editorDraftProvider);
    final editor = ref.read(editorDraftProvider.notifier);
    Widget field(String label) => _DraftField(
      label: label,
      value: draft.fields[label] ?? '',
      onChanged: (value) => editor.setField(label, value),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldRow(children: [field('Prénom'), field('Nom')]),
        const SizedBox(height: 18),
        field('Titre professionnel'),
        const SizedBox(height: 18),
        _PhotoCard(compact: compact),
        const SizedBox(height: 18),
        _FieldRow(children: [field('Localisation'), field('Téléphone')]),
        const SizedBox(height: 14),
        _FieldRow(children: [field('E-mail'), field('Site / portfolio')]),
        const SizedBox(height: 18),
        Text('Liens', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _EntryList(section: CvSection.personalInfo),
      ],
    );
  }
}

class _PhotoCard extends ConsumerWidget {
  const _PhotoCard({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(editorDraftProvider).photo;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: compact ? 26 : 32,
            backgroundColor: AppColors.primaryTint,
            backgroundImage: photo == null ? null : MemoryImage(photo),
            child: photo == null
                ? const Icon(
                    Icons.account_circle_outlined,
                    size: 30,
                    color: AppColors.primary,
                  )
                : null,
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
                          // Decode before accepting an invalid image into the session.
                          final image = await decodeImageFromList(bytes);
                          image.dispose();
                          if (context.mounted) {
                            ref
                                .read(editorDraftProvider.notifier)
                                .setPhoto(bytes);
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
                      label: Text(compact ? 'Choisir…' : 'Choisir une image'),
                    ),
                    TextButton(
                      onPressed: photo == null
                          ? null
                          : () => ref
                                .read(editorDraftProvider.notifier)
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
    );
  }
}

const _fields = <CvSection, List<String>>{
  CvSection.personalInfo: ['Libellé', 'URL'],
  CvSection.experiences: [
    'Poste',
    'Entreprise',
    'Lieu',
    'Début',
    'Fin',
    'Description / réalisations',
  ],
  CvSection.education: [
    'Diplôme',
    'Établissement',
    'Lieu',
    'Début',
    'Fin',
    'Description (facultative)',
  ],
  CvSection.skills: ['Nom', 'Catégorie (facultative)', 'Niveau (facultatif)'],
  CvSection.languages: ['Langue', 'Niveau'],
  CvSection.certifications: ['Intitulé', 'Organisme', 'Date', 'Description'],
  CvSection.projects: ['Intitulé', 'Description'],
  CvSection.interests: ['Intitulé', 'Description'],
  CvSection.references: ['Intitulé', 'Description'],
};

const _addLabels = <CvSection, String>{
  CvSection.personalInfo: 'Ajouter un lien',
  CvSection.experiences: 'Ajouter une expérience',
  CvSection.education: 'Ajouter une formation',
  CvSection.skills: 'Ajouter une compétence',
  CvSection.languages: 'Ajouter une langue',
  CvSection.certifications: 'Ajouter une certification',
  CvSection.projects: 'Ajouter un projet',
  CvSection.interests: "Ajouter un centre d'intérêt",
  CvSection.references: 'Ajouter une référence',
};

class _EntryList extends ConsumerStatefulWidget {
  const _EntryList({super.key, required this.section});
  final CvSection section;
  @override
  ConsumerState<_EntryList> createState() => _EntryListState();
}

class _EntryListState extends ConsumerState<_EntryList> {
  String? _expanded;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final entries = ref.watch(editorDraftProvider).entries[section] ?? [];
    final editor = ref.read(editorDraftProvider.notifier);
    if (!_initialized) {
      _expanded = section == CvSection.experiences && entries.isNotEmpty
          ? entries.first['id']
          : null;
      _initialized = true;
    }
    void add() => setState(() => _expanded = editor.add(section));
    final addButton = section == CvSection.personalInfo
        ? OutlinedButton.icon(
            onPressed: add,
            icon: const Icon(Icons.add, size: 17),
            label: Text(_addLabels[section]!),
          )
        : FilledButton.tonalIcon(
            onPressed: add,
            icon: const Icon(Icons.add, size: 18),
            label: Text(_addLabels[section]!),
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
              editor.reorder(section, oldIndex, newIndex),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final id = entry['id']!;
            final expanded = _expanded == id;
            final labels = _fields[section]!;
            Widget field(String label) => _DraftField(
              key: ValueKey('$id/$label'),
              label: label,
              value: entry[label] ?? '',
              enabled: label != 'Fin' || entry['En cours'] != 'true',
              lines: label.startsWith('Description') ? 4 : 1,
              calendar: ['Début', 'Fin', 'Date'].contains(label),
              onChanged: (value) => editor.setEntry(section, id, label, value),
            );
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
                                      text: (entry[labels.first] ?? '').isEmpty
                                          ? 'Nouvel élément'
                                          : entry[labels.first],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if ((entry[labels[1]] ?? '').isNotEmpty)
                                      TextSpan(
                                        text: ' · ${entry[labels[1]]}',
                                        style: const TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    if ((entry['Début'] ?? '').isNotEmpty)
                                      TextSpan(
                                        text:
                                            " — ${entry['Début']} → ${entry['En cours'] == 'true' ? 'aujourd’hui' : entry['Fin'] ?? ''}",
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
                              editor.remove(section, id);
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
                          _FieldRow(
                            children: [field(labels[0]), field(labels[1])],
                          ),
                          if (section == CvSection.experiences ||
                              section == CvSection.education) ...[
                            const SizedBox(height: 14),
                            _FieldRow(
                              children: [
                                field('Lieu'),
                                field('Début'),
                                field('Fin'),
                              ],
                            ),
                            if (section == CvSection.experiences)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 34,
                                      child: Checkbox(
                                        value: entry['En cours'] == 'true',
                                        onChanged: (value) => editor.setEntry(
                                          section,
                                          id,
                                          'En cours',
                                          '$value',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('En cours'),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 14),
                            field(labels.last),
                          ] else
                            for (final label in labels.skip(2)) ...[
                              const SizedBox(height: 14),
                              field(label),
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

class _DraftField extends StatefulWidget {
  const _DraftField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.lines = 1,
    this.enabled = true,
    this.calendar = false,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int lines;
  final bool enabled;
  final bool calendar;
  @override
  State<_DraftField> createState() => _DraftFieldState();
}

class _DraftFieldState extends State<_DraftField> {
  late final _controller = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant _DraftField oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Future<void> _pickDate() async {
    final value = await showMonthYearPicker(
      context,
      label: widget.label,
      initialValue: _controller.text,
    );
    if (value == null || value == _controller.text || !mounted) return;
    _controller.text = value;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.lines == 1 ? 44 : null,
    child: TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      // Les dates se choisissent dans le sélecteur, sans saisie libre.
      readOnly: widget.calendar,
      onTap: widget.calendar ? _pickDate : null,
      mouseCursor: widget.calendar ? SystemMouseCursors.click : null,
      minLines: widget.lines,
      maxLines: widget.lines == 1 ? 1 : null,
      style: TextStyle(fontSize: 13, height: widget.lines == 1 ? 1.2 : 1.6),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: widget.enabled
            ? AppColors.surfaceContainerLow
            : AppColors.disabledFill,
        hintText: widget.calendar ? 'Choisir…' : null,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.disabled),
        suffixIcon: widget.calendar
            ? const Icon(Icons.calendar_month_outlined, size: 17)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 28),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    ),
  );
}
