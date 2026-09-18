import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/formatting/modified_label.dart';
import '../../../../shared/notifications/app_toast.dart';
import '../../domain/cv_summary.dart';
import '../cv_library_provider.dart';
import '../cv_session_provider.dart';
import '../cv_workspace.dart';

/// Ouvre le dialogue « Mes CV ».
Future<void> showCvLibraryDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const CvLibraryDialog());

/// La liste des CV enregistrés : ouvrir, créer, renommer, dupliquer,
/// supprimer.
class CvLibraryDialog extends ConsumerWidget {
  const CvLibraryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(cvLibraryProvider);
    final openId = ref.watch(
      cvSessionProvider.select((session) => session.document.id),
    );
    final now = ref.read(clockProvider)();
    final textTheme = Theme.of(context).textTheme;
    final count = library.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes CV',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          count <= 1
                              ? '$count CV enregistré sur cet ordinateur'
                              : '$count CV enregistrés sur cet ordinateur',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: FilledButton.icon(
                      onPressed: () => _run(context, ref, () async {
                        await ref.read(cvWorkspaceProvider).create();
                        if (context.mounted) Navigator.pop(context);
                      }),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Créer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: library.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final summary = library[index];
                    return _CvRow(
                      key: ValueKey(summary.id),
                      summary: summary,
                      isOpen: summary.id == openId,
                      meta: modifiedLabel(summary.updatedAt, now: now),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Au démarrage, le dernier CV modifié est rouvert.',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
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

/// Exécute [operation] et signale son échec par une notification.
///
/// Les notifications sont lues avant l'opération : la rangée qui l'a lancée
/// peut disparaître entre-temps, et son `ref` avec elle.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() operation,
) async {
  final toasts = ref.read(appToastsProvider.notifier);
  try {
    await operation();
  } catch (_) {
    toasts.show(
      kind: AppToastKind.error,
      title: 'Opération impossible',
      message:
          'Les CV enregistrés sur cet ordinateur n’ont pas pu être '
          'modifiés. Réessayez dans un instant.',
    );
  }
}

class _CvRow extends ConsumerWidget {
  const _CvRow({
    super.key,
    required this.summary,
    required this.isOpen,
    required this.meta,
  });

  final CvSummary summary;
  final bool isOpen;
  final String meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.read(cvWorkspaceProvider);
    return Material(
      color: isOpen ? AppColors.primaryTint : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOpen ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _run(context, ref, () async {
          final opened = await workspace.open(summary.id);
          if (!opened) throw StateError('CV introuvable');
          if (context.mounted) Navigator.pop(context);
        }),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 22,
                color: isOpen ? AppColors.primary : AppColors.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name.isEmpty ? 'Sans titre' : summary.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOpen ? '$meta · Ouvert' : meta,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Renommer',
                iconSize: 18,
                onPressed: () async {
                  final name = await showDialog<String>(
                    context: context,
                    builder: (_) => RenameCvDialog(name: summary.name),
                  );
                  if (name == null || !context.mounted) return;
                  await _run(
                    context,
                    ref,
                    () => workspace.rename(summary.id, name),
                  );
                },
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
              IconButton(
                tooltip: 'Dupliquer',
                iconSize: 18,
                onPressed: () =>
                    _run(context, ref, () => workspace.duplicate(summary.id)),
                icon: const Icon(Icons.content_copy),
              ),
              IconButton(
                tooltip: 'Supprimer',
                iconSize: 18,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => DeleteCvDialog(name: summary.name),
                  );
                  if (confirmed != true || !context.mounted) return;
                  // La rangée disparaît avec le CV : le dialogue est retenu
                  // avant, pour être refermé s'il ne reste aucun CV.
                  final navigator = Navigator.of(context);
                  await _run(context, ref, () async {
                    final remaining = await workspace.delete(summary.id);
                    // Sans CV restant, l'écran d'accueil prend le relais.
                    if (!remaining) navigator.pop();
                  });
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
