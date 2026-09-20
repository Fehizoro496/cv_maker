import 'package:flutter/material.dart';

import '../../../../../app/app_theme.dart';

/// Le dialogue de renommage d'un CV ; renvoie le nouveau nom, ou `null`.
class RenameCvDialog extends StatefulWidget {
  const RenameCvDialog({super.key, required this.name});

  final String name;

  @override
  State<RenameCvDialog> createState() => _RenameCvDialogState();
}

class _RenameCvDialogState extends State<RenameCvDialog> {
  late final _name = TextEditingController(
    text: widget.name,
  )..selection = TextSelection(baseOffset: 0, extentOffset: widget.name.length);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _isValid => _name.text.trim().isNotEmpty;

  void _submit() {
    if (_isValid) Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Renommer le CV'),
    content: SizedBox(
      width: 352,
      child: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 80,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'Nom du CV',
          counterText: '',
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: _isValid ? _submit : null,
        child: const Text('Renommer'),
      ),
    ],
  );
}

/// La confirmation de suppression d'un CV ; renvoie `true` pour supprimer.
class DeleteCvDialog extends StatelessWidget {
  const DeleteCvDialog({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.delete_outline, color: AppColors.error),
    title: const Text('Supprimer ce CV ?'),
    content: SizedBox(
      width: 352,
      child: Text(
        '« $name » sera supprimé définitivement de cet ordinateur. '
        'Cette action est irréversible.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        style: FilledButton.styleFrom(backgroundColor: AppColors.error),
        child: const Text('Supprimer'),
      ),
    ],
  );
}
