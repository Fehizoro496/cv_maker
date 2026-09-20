import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/app_theme.dart';
import '../../../domain/entries/cv_custom_section.dart';
import '../../../domain/document/cv_document.dart';
import '../cv_section_presentation.dart';

/// Le nom et le type choisis dans le dialogue « Nouvelle section ».
typedef NewCustomSection = ({String name, CvCustomSectionType type});

/// Ce que l'utilisateur décide dans la confirmation de suppression.
enum CustomSectionRemoval {
  /// Supprimer la section et son contenu.
  delete,

  /// La masquer plutôt, sans rien perdre.
  hide,
}

/// Ouvre le dialogue de création ; `null` si l'utilisateur annule.
Future<NewCustomSection?> showNewCustomSectionDialog(
  BuildContext context,
  CvDocument document,
) => showDialog<NewCustomSection>(
  context: context,
  builder: (_) => NewCustomSectionDialog(document: document),
);

/// Ouvre le dialogue de renommage ; `null` si l'utilisateur annule.
Future<String?> showRenameCustomSectionDialog(
  BuildContext context,
  CvDocument document,
  CvCustomSection section,
) => showDialog<String>(
  context: context,
  builder: (_) =>
      RenameCustomSectionDialog(document: document, section: section),
);

/// Demande confirmation avant de supprimer [section] ; `null` si
/// l'utilisateur annule.
Future<CustomSectionRemoval?> showRemoveCustomSectionDialog(
  BuildContext context,
  CvCustomSection section,
) => showDialog<CustomSectionRemoval>(
  context: context,
  builder: (context) {
    final count = section.itemCount;
    final lost = switch (count) {
      0 => 'Elle ne contient encore aucun élément.',
      1 => 'Son élément sera supprimé avec elle.',
      _ => 'Ses $count éléments seront supprimés avec elle.',
    };
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, color: AppColors.error),
      title: Text('Supprimer la section « ${section.name} » ?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Text(
          '$lost Pour la retirer du CV sans perdre son contenu, '
          "masquez-la plutôt avec l'icône œil.",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (section.visible)
          TextButton(
            onPressed: () => Navigator.pop(context, CustomSectionRemoval.hide),
            child: const Text('Masquer'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, CustomSectionRemoval.delete),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Supprimer'),
        ),
      ],
    );
  },
);

/// Le dialogue « Nouvelle section » : un nom et un type de contenu.
class NewCustomSectionDialog extends StatefulWidget {
  const NewCustomSectionDialog({super.key, required this.document});

  /// Le CV dont les noms de sections sont déjà pris.
  final CvDocument document;

  @override
  State<NewCustomSectionDialog> createState() => _NewCustomSectionDialogState();
}

class _NewCustomSectionDialogState extends State<NewCustomSectionDialog> {
  final _name = TextEditingController();
  var _type = CvCustomSectionType.datedList;
  var _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? get _error => customSectionNameError(_name.text, widget.document);

  void _submit() {
    if (_error != null) {
      setState(() => _submitted = true);
      return;
    }
    Navigator.pop<NewCustomSection>(context, (
      name: _name.text.trim(),
      type: _type,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Un nom vide n'est signalé qu'après une tentative de création : l'erreur
    // n'accueille pas l'utilisateur à l'ouverture.
    final error = _submitted || _name.text.isNotEmpty ? _error : null;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nouvelle section',
                style: textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Elle sera ajoutée à la fin de votre CV. '
                'Vous pourrez la masquer à tout moment.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              _NameField(
                controller: _name,
                error: error,
                onChanged: (_) => setState(() {}),
                onSubmitted: _submit,
              ),
              const SizedBox(height: 18),
              Text('Type de contenu', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final type in CvCustomSectionType.values) ...[
                _TypeCard(
                  type: type,
                  selected: type == _type,
                  onTap: () => setState(() => _type = type),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 15, color: AppColors.outline),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Le type ne pourra plus être changé après la création.',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Créer la section'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le dialogue de renommage : seul le nom change, jamais le type.
class RenameCustomSectionDialog extends StatefulWidget {
  const RenameCustomSectionDialog({
    super.key,
    required this.document,
    required this.section,
  });

  final CvDocument document;
  final CvCustomSection section;

  @override
  State<RenameCustomSectionDialog> createState() =>
      _RenameCustomSectionDialogState();
}

class _RenameCustomSectionDialogState extends State<RenameCustomSectionDialog> {
  late final _name = TextEditingController(text: widget.section.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? get _error => customSectionNameError(
    _name.text,
    widget.document,
    exceptId: widget.section.id,
  );

  void _submit() {
    if (_error != null) return;
    Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Renommer la section'),
    content: SizedBox(
      width: 440,
      child: _NameField(
        controller: _name,
        error: _error,
        onChanged: (_) => setState(() {}),
        onSubmitted: _submit,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: _error == null ? _submit : null,
        child: const Text('Renommer'),
      ),
    ],
  );
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.error,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: true,
    onChanged: onChanged,
    onSubmitted: (_) => onSubmitted(),
    // La limite est aussi imposée à la saisie ; la validation la couvre pour
    // un texte collé.
    inputFormatters: [
      LengthLimitingTextInputFormatter(CvCustomSection.maxNameLength),
    ],
    decoration: InputDecoration(
      labelText: 'Nom de la section',
      hintText: 'Publications, Bénévolat, Distinctions…',
      floatingLabelBehavior: FloatingLabelBehavior.always,
      fillColor: AppColors.surfaceContainerLow,
      errorText: error,
    ),
  );
}

/// Une carte radio du type de contenu.
class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final CvCustomSectionType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.disabledBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.onSecondaryContainer : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.explanation,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(type.icon, size: 22, color: AppColors.outline),
          ],
        ),
      ),
    ),
  );
}
