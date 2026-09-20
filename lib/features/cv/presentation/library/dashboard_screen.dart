import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/formatting/modified_label.dart';
import '../../../../shared/notifications/app_toast.dart';
import '../../../../shared/widgets/dashed_border.dart';
import '../../domain/document/cv_summary.dart';
import 'cv_library_provider.dart';
import 'cv_thumbnail_provider.dart';
import 'cv_workspace.dart';
import '../editor/editor_screen.dart';
import 'widgets/cv_dialogs.dart';

/// L'ordre d'affichage des CV du tableau de bord.
enum CvDashboardSort {
  recent('Récents'),
  name('Nom');

  const CvDashboardSort(this.label);
  final String label;
}

/// L'écran d'ouverture : les CV enregistrés, leur recherche, et la création
/// d'un nouveau CV.
///
/// Ouvrir un CV pousse l'éditeur par-dessus ; le quitter ramène ici.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  var _sort = CvDashboardSort.recent;

  /// Vrai pendant l'ouverture ou la création d'un CV : un double clic
  /// n'ouvre pas deux éditeurs.
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  CvWorkspace get _workspace => ref.read(cvWorkspaceProvider);

  void _showError(String title, String message, {VoidCallback? retry}) => ref
      .read(appToastsProvider.notifier)
      .show(
        kind: AppToastKind.error,
        title: title,
        message: message,
        actionLabel: retry == null ? null : 'Réessayer',
        actionIcon: retry == null ? null : Icons.refresh,
        onAction: retry,
      );

  /// Exécute [operation] puis ouvre l'éditeur, sauf si elle a échoué.
  Future<void> _thenEdit(
    Future<bool> Function() operation, {
    required String errorTitle,
    required String errorMessage,
    VoidCallback? retry,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    var opened = false;
    try {
      opened = await operation();
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (!opened) {
      _showError(errorTitle, errorMessage, retry: retry);
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const EditorScreen()));
  }

  Future<void> _create() => _thenEdit(
    () async {
      await _workspace.create();
      return true;
    },
    errorTitle: 'Création impossible',
    errorMessage: 'Le CV n’a pas pu être enregistré sur cet ordinateur.',
    retry: _create,
  );

  Future<void> _open(CvSummary summary) => _thenEdit(
    () => _workspace.open(summary.id),
    errorTitle: 'Ouverture impossible',
    errorMessage: '« ${summary.name} » n’a pas pu être lu sur cet ordinateur.',
  );

  /// Exécute une opération de gestion et signale son échec.
  Future<void> _manage(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      _showError(
        'Opération impossible',
        'Les CV enregistrés sur cet ordinateur n’ont pas pu être modifiés. '
            'Réessayez dans un instant.',
      );
    }
  }

  Future<void> _rename(CvSummary summary) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => RenameCvDialog(name: summary.name),
    );
    if (name == null || !mounted) return;
    await _manage(() => _workspace.rename(summary.id, name));
  }

  Future<void> _delete(CvSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteCvDialog(name: summary.name),
    );
    if (confirmed != true || !mounted) return;
    await _manage(() => _workspace.delete(summary.id));
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(cvLibraryProvider);
    final sorted = switch (_sort) {
      CvDashboardSort.recent => library,
      CvDashboardSort.name => library.sortedByName(),
    };
    final query = _search.text.trim();
    final visible = sorted.matching(query);
    final now = ref.read(clockProvider)();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _create,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _searchFocus.requestFocus,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  count: library.length,
                  onCreate: _busy ? null : _create,
                  // L'accueil a déjà son propre bouton de création.
                  showCreate: library.isNotEmpty,
                ),
                if (library.isEmpty)
                  Expanded(child: _EmptyState(onCreate: _busy ? null : _create))
                else ...[
                  _Toolbar(
                    controller: _search,
                    focusNode: _searchFocus,
                    sort: _sort,
                    onQueryChanged: (_) => setState(() {}),
                    onClear: _clearSearch,
                    onSortChanged: (sort) => setState(() => _sort = sort),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? _NoResults(query: query, onClear: _clearSearch)
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 240,
                                  mainAxisExtent: 216,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            // La tuile de création précède les CV, sauf
                            // pendant une recherche.
                            itemCount: visible.length + (query.isEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (query.isEmpty && index == 0) {
                                return _NewCvTile(
                                  onTap: _busy ? null : _create,
                                );
                              }
                              final summary =
                                  visible[index - (query.isEmpty ? 1 : 0)];
                              return _CvCard(
                                key: ValueKey(summary.id),
                                summary: summary,
                                meta: modifiedLabel(
                                  summary.updatedAt,
                                  now: now,
                                ),
                                onOpen: () => _open(summary),
                                onRename: () => _rename(summary),
                                onDuplicate: () => _manage(
                                  () => _workspace.duplicate(summary.id),
                                ),
                                onDelete: () => _delete(summary),
                              );
                            },
                          ),
                  ),
                ],
                const _OfflineFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.onCreate,
    required this.showCreate,
  });

  final int count;
  final VoidCallback? onCreate;
  final bool showCreate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes CV',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(switch (count) {
                  0 => 'Aucun CV enregistré sur cet ordinateur',
                  1 => '1 CV enregistré sur cet ordinateur',
                  _ => '$count CV enregistrés sur cet ordinateur',
                }, style: textTheme.bodySmall),
              ],
            ),
          ),
          if (showCreate)
            Tooltip(
              message: 'Nouveau CV (Ctrl+N)',
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onCreate,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouveau CV'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.focusNode,
    required this.sort,
    required this.onQueryChanged,
    required this.onClear,
    required this.onSortChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final CvDashboardSort sort;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<CvDashboardSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un CV (Ctrl+F)',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer la recherche',
                        onPressed: onClear,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                fillColor: AppColors.surface,
              ),
            ),
          ),
          SegmentedButton<CvDashboardSort>(
            showSelectedIcon: false,
            segments: [
              for (final value in CvDashboardSort.values)
                ButtonSegment(
                  value: value,
                  label: Text(value.label),
                  icon: Icon(switch (value) {
                    CvDashboardSort.recent => Icons.schedule,
                    CvDashboardSort.name => Icons.sort_by_alpha,
                  }, size: 18),
                ),
            ],
            selected: {sort},
            onSelectionChanged: (selection) => onSortChanged(selection.single),
          ),
        ],
      ),
    );
  }
}

/// La tuile « Nouveau CV », en tête de la grille.
class _NewCvTile extends StatelessWidget {
  const _NewCvTile({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: const DashedBorderPainter(
      color: AppColors.disabledBorder,
      radius: AppRadii.card,
    ),
    child: Material(
      color: AppColors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.add, color: AppColors.primary),
            ),
            SizedBox(height: 12),
            Text(
              'Nouveau CV',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Partir d’un CV vide',
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ),
  );
}

enum _CvAction { open, rename, duplicate, delete }

class _CvCard extends StatelessWidget {
  const _CvCard({
    super.key,
    required this.summary,
    required this.meta,
    required this.onOpen,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final CvSummary summary;
  final String meta;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _PagePreview(summary: summary)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.name.isEmpty ? 'Sans titre' : summary.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_CvAction>(
                    tooltip: 'Actions',
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (action) => switch (action) {
                      _CvAction.open => onOpen(),
                      _CvAction.rename => onRename(),
                      _CvAction.duplicate => onDuplicate(),
                      _CvAction.delete => onDelete(),
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _CvAction.open,
                        child: _MenuLabel(Icons.edit_outlined, 'Ouvrir'),
                      ),
                      PopupMenuItem(
                        value: _CvAction.rename,
                        child: _MenuLabel(
                          Icons.drive_file_rename_outline,
                          'Renommer',
                        ),
                      ),
                      PopupMenuItem(
                        value: _CvAction.duplicate,
                        child: _MenuLabel(Icons.content_copy, 'Dupliquer'),
                      ),
                      PopupMenuItem(
                        value: _CvAction.delete,
                        child: _MenuLabel(
                          Icons.delete_outline,
                          'Supprimer',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel(this.icon, this.label, {this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: color ?? AppColors.onSurfaceVariant),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(color: color)),
    ],
  );
}

/// Une page stylisée : le contenu réel n'est lu qu'à l'ouverture du CV.
/// L'aperçu de la première page du CV, sur le fond de la carte.
///
/// Tant qu'aucun rendu n'est disponible, la maquette de lignes tient la place :
/// elle a la forme d'une page et n'attire pas l'œil, là où un indicateur de
/// chargement par carte ferait clignoter toute la grille.
class _PagePreview extends ConsumerWidget {
  const _PagePreview({required this.summary});

  final CvSummary summary;

  /// Proportions de la vignette, celles d'une page A4.
  static const width = 84.0;
  static const height = 112.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final png = ref.watch(cvThumbnailProvider(summary)).value;
    return ColoredBox(
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.pageShadow,
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          child: png == null
              ? const _PageSkeleton()
              : Image.memory(
                  png,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  semanticLabel: 'Aperçu du CV',
                  gaplessPlayback: true,
                ),
        ),
      ),
    );
  }
}

/// La forme d'une page, en attendant son rendu.
class _PageSkeleton extends StatelessWidget {
  const _PageSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget line(double width, {double height = 4, Color? color}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: color ?? AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(40, height: 6, color: AppColors.primary),
          line(28),
          const SizedBox(height: 4),
          line(64),
          line(56),
          line(60),
          const SizedBox(height: 4),
          line(64),
          line(48),
        ],
      ),
    );
  }
}

/// Aucun CV enregistré : l'accueil du premier lancement.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_add_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenue dans CV Maker',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Text(
                'Remplissez vos informations section par section : le CV en '
                'PDF se met à jour à côté de vous. Tout reste sur votre '
                'ordinateur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onCreate,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Créer mon CV'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off, size: 36, color: AppColors.disabled),
        const SizedBox(height: 12),
        Text(
          'Aucun CV ne correspond à « $query »',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onClear,
          child: const Text('Effacer la recherche'),
        ),
      ],
    ),
  );
}

class _OfflineFooter extends StatelessWidget {
  const _OfflineFooter();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(32, 8, 32, 16),
    child: Row(
      children: [
        Icon(Icons.cloud_off_outlined, size: 16, color: AppColors.outline),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            'Fonctionne hors ligne, sans compte — données sur cet ordinateur',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.outline),
          ),
        ),
      ],
    ),
  );
}
