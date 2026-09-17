import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../domain/cv_design.dart';
import '../../domain/cv_design_spec.dart';
import '../catalog_preview_provider.dart';

/// Catalogue des modèles intégrés, avec ses deux réglages.
///
/// Le dialogue ne modifie rien de lui-même : il retourne le choix retenu, que
/// l'appelant applique. « Annuler » retourne `null`, ce qui laisse le CV
/// intact.
///
/// Les vignettes sont rendues à partir du PDF réel du CV en cours, hors ligne.
class DesignCatalog extends ConsumerStatefulWidget {
  const DesignCatalog({
    super.key,
    required this.selected,
    required this.accent,
    required this.showPhoto,
    this.hasPhoto = false,
  });

  /// Le modèle, la couleur et l'affichage de la photo enregistrés dans le CV.
  final CvDesign selected;
  final CvAccent accent;
  final bool showPhoto;

  /// Sans photo dans la session, le réglage correspondant reste indisponible.
  final bool hasPhoto;

  static const maxWidth = 1160.0;
  static const maxHeight = 760.0;
  static const settingsWidth = 420.0;
  static const radius = 28.0;

  /// Au-delà, la grille et le panneau tiennent côte à côte.
  static const wideBreakpoint = 900.0;

  @override
  ConsumerState<DesignCatalog> createState() => _DesignCatalogState();
}

class _DesignCatalogState extends ConsumerState<DesignCatalog> {
  late CvDesign _design = widget.selected;
  late CvAccent _accent = widget.accent;
  late bool _showPhoto = widget.showPhoto;

  CatalogChoice get _choice =>
      (design: _design, accent: _accent, showPhoto: _showPhoto);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignCatalog.radius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DesignCatalog.maxWidth,
          maxHeight: DesignCatalog.maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(textTheme: textTheme),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final grid = _TemplateGrid(
                    selected: _design,
                    accent: _accent,
                    showPhoto: _showPhoto,
                    onSelected: (design) => setState(() => _design = design),
                  );
                  final settings = _SettingsPanel(
                    choice: _choice,
                    hasPhoto: widget.hasPhoto,
                    onAccent: (accent) => setState(() => _accent = accent),
                    onShowPhoto: (value) => setState(() => _showPhoto = value),
                  );
                  // En fenêtre étroite, le panneau passe sous la grille.
                  if (constraints.maxWidth < DesignCatalog.wideBreakpoint) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          grid,
                          SizedBox(height: 360, child: settings),
                        ],
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: grid),
                      SizedBox(
                        width: DesignCatalog.settingsWidth,
                        child: settings,
                      ),
                    ],
                  );
                },
              ),
            ),
            _Footer(onApply: () => Navigator.pop(context, _choice)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 22, 16, 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisir un modèle', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${CvDesign.values.length} modèles, tous lisibles par les '
                'logiciels de tri des candidatures. Vos informations sont '
                'conservées quand vous changez de modèle.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Fermer le catalogue',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({
    required this.selected,
    required this.accent,
    required this.showPhoto,
    required this.onSelected,
  });

  final CvDesign selected;
  final CvAccent accent;
  final bool showPhoto;
  final ValueChanged<CvDesign> onSelected;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    shrinkWrap: true,
    physics: const ClampingScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 14,
      mainAxisSpacing: 16,
      // Une miniature A4 surmontée de son nom et de sa description.
      childAspectRatio: .56,
    ),
    itemCount: CvDesign.values.length,
    itemBuilder: (context, index) {
      final design = CvDesign.values[index];
      return _TemplateCard(
        design: design,
        isSelected: design == selected,
        choice: (design: design, accent: accent, showPhoto: showPhoto),
        onSelected: () => onSelected(design),
      );
    },
  );
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.design,
    required this.isSelected,
    required this.choice,
    required this.onSelected,
  });

  final CvDesign design;
  final bool isSelected;
  final CatalogChoice choice;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    button: true,
    label: design.label,
    child: InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryTint
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 210 / 297,
                  child: _PagePreview(choice: choice),
                ),
                const SizedBox(height: 6),
                Text(
                  design.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    design.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pageShadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// La première page du CV, rendue avec le choix demandé.
class _PagePreview extends ConsumerWidget {
  const _PagePreview({required this.choice});

  final CatalogChoice choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(catalogPreviewProvider(choice));
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRect(
        child: switch (preview) {
          AsyncData(:final value) => Image.memory(
            value,
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            semanticLabel: 'Aperçu du modèle',
            gaplessPlayback: true,
          ),
          AsyncError() => const Center(
            child: Icon(Icons.error_outline, color: AppColors.outline),
          ),
          _ => const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        },
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.choice,
    required this.hasPhoto,
    required this.onAccent,
    required this.onShowPhoto,
  });

  final CatalogChoice choice;
  final bool hasPhoto;
  final ValueChanged<CvAccent> onAccent;
  final ValueChanged<bool> onShowPhoto;

  @override
  Widget build(BuildContext context) {
    final ignoresAccent = choice.design.spec.tokens.ignoresAccent;
    return ColoredBox(
      color: AppColors.canvas,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 210 / 297,
                  child: _PagePreview(choice: choice),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Couleur d’accent',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final accent in CvAccent.values) ...[
                      if (accent != CvAccent.values.first)
                        const SizedBox(width: 10),
                      _AccentDot(
                        accent: accent,
                        isSelected: accent == choice.accent,
                        // Un modèle sans couleur ignore ce réglage.
                        onSelected: ignoresAccent
                            ? null
                            : () => onAccent(accent),
                      ),
                    ],
                  ],
                ),
                if (ignoresAccent) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ce modèle n’utilise aucune couleur.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Afficher la photo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPhoto
                                ? 'Ce modèle propose aussi une version sans photo.'
                                : 'Ajoutez une photo dans « Informations '
                                      'personnelles » pour activer ce réglage.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: choice.showPhoto,
                      onChanged: hasPhoto ? onShowPhoto : null,
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

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.isSelected,
    required this.onSelected,
  });

  final CvAccent accent;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Color(accent.color);
    return Tooltip(
      message: accent.label,
      child: Semantics(
        selected: isSelected,
        button: true,
        label: accent.label,
        child: InkWell(
          onTap: onSelected,
          customBorder: const CircleBorder(),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: onSelected == null ? color.withValues(alpha: .35) : color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.surface, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color, spreadRadius: 2)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.outlineVariant)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle,
          size: 16,
          color: AppColors.onSuccessContainer,
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Compatible avec les logiciels de tri des candidatures',
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onApply,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Appliquer le modèle'),
        ),
      ],
    ),
  );
}
