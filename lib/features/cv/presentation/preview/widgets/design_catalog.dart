import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/app_theme.dart';
import '../../../../../shared/widgets/color_picker_dialog.dart';
import '../../../domain/design/cv_design.dart';
import '../../../domain/design/cv_design_spec.dart';
import '../../../domain/design/cv_template.dart';
import '../catalog_preview_provider.dart';
import '../template_catalog_provider.dart';

/// Catalogue des modèles intégrés, avec ses deux réglages.
///
/// Reprend la maquette « Choisir un modèle » du dossier de design : grille de
/// vignettes à gauche, aperçu et réglages à droite, pied rappelant la
/// compatibilité ATS.
///
/// Le dialogue ne modifie rien de lui-même : il retourne le choix retenu, que
/// l'appelant applique. « Annuler » et la croix retournent `null`, ce qui
/// laisse le CV intact.
///
/// Les vignettes montrent un CV d'exemple, identique d'une ouverture à l'autre :
/// elles ne dépendent donc que du modèle et restent en cache pour la session.
/// Le grand aperçu, lui, rend le CV réel de l'utilisateur.
class DesignCatalog extends ConsumerStatefulWidget {
  const DesignCatalog({
    super.key,
    required this.selected,
    required this.accentArgb,
    required this.showPhoto,
    this.hasPhoto = false,
  });

  /// Le modèle, la couleur et l'affichage de la photo enregistrés dans le CV.
  final CvDesign selected;
  final int accentArgb;
  final bool showPhoto;

  /// Sans photo dans la session, le réglage correspondant reste indisponible.
  final bool hasPhoto;

  static const maxWidth = 1160.0;
  static const maxHeight = 760.0;
  static const settingsWidth = 420.0;
  static const radius = 28.0;

  /// Nombre de colonnes de la grille de vignettes.
  static const columns = 4;

  /// Au-delà, la grille et le panneau tiennent côte à côte.
  static const wideBreakpoint = 900.0;

  @override
  ConsumerState<DesignCatalog> createState() => _DesignCatalogState();
}

class _DesignCatalogState extends ConsumerState<DesignCatalog> {
  late CvDesign _design = widget.selected;
  late int _accentArgb = widget.accentArgb;
  late bool _showPhoto = widget.showPhoto;

  /// Le choix en cours de composition, prévisualisé en grand.
  CatalogChoice get _choice =>
      (design: _design, accentArgb: _accentArgb, showPhoto: _showPhoto);

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(24),
    clipBehavior: Clip.antiAlias,
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
          const _Header(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // En fenêtre étroite, le dialogue défile d'un seul bloc : la
                // grille s'y insère alors sans défilement propre.
                final narrow =
                    constraints.maxWidth < DesignCatalog.wideBreakpoint;
                final grid = _TemplateGrid(
                  selected: _design,
                  insideScrollView: narrow,
                  onSelected: (design) => setState(() => _design = design),
                );
                final settings = _SettingsPanel(
                  choice: _choice,
                  hasPhoto: widget.hasPhoto,
                  onAccent: (argb) => setState(() => _accentArgb = argb),
                  onShowPhoto: (value) => setState(() => _showPhoto = value),
                );
                // En fenêtre étroite, le panneau passe sous la grille.
                if (narrow) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        grid,
                        SizedBox(height: 420, child: settings),
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

class _Header extends StatelessWidget {
  const _Header();

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
              const Text(
                'Choisir un modèle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                '${CvDesign.values.length} modèles, tous lisibles par les '
                'logiciels de tri des candidatures. Vos informations sont '
                'conservées quand vous changez de modèle.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Fermer le catalogue',
          iconSize: 20,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(36),
            foregroundColor: AppColors.onSurfaceVariant,
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}

class _TemplateGrid extends ConsumerWidget {
  const _TemplateGrid({
    required this.selected,
    required this.onSelected,
    this.insideScrollView = false,
  });

  final CvDesign selected;

  final ValueChanged<CvDesign> onSelected;

  /// Vrai lorsque la grille est posée dans un parent qui défile déjà.
  final bool insideScrollView;

  /// Hauteur réservée au nom et à la description, sous la vignette.
  static const captionHeight = 52.0;

  /// Espace entre la vignette et son nom.
  static const captionGap = 7.0;

  static const horizontalPadding = 20.0;
  static const columnGap = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(
    builder: (context, constraints) {
      final templates = ref.watch(templateCatalogProvider);
      // La vignette garde le rapport A4 exact : la hauteur d'une carte se
      // déduit de la largeur de colonne plutôt que d'un ratio approché.
      final available =
          constraints.maxWidth -
          horizontalPadding * 2 -
          columnGap * (DesignCatalog.columns - 1);
      final columnWidth = available / DesignCatalog.columns;
      // Le cadre ajoute 5 px de marge intérieure et jusqu'à 2 px de bordure.
      final thumbnailHeight = (columnWidth - 14) * 297 / 210;
      return GridView.builder(
        shrinkWrap: insideScrollView,
        physics: insideScrollView ? const NeverScrollableScrollPhysics() : null,
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: DesignCatalog.columns,
          crossAxisSpacing: columnGap,
          mainAxisSpacing: 14,
          mainAxisExtent: thumbnailHeight + 14 + captionGap + captionHeight,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return _TemplateCard(
            template: template,
            isSelected: template.id == selected.id,
            onSelected: () => onSelected(CvDesign.fromId(template.id)),
          );
        },
      );
    },
  );
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onSelected,
  });

  final CvTemplate template;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    button: true,
    label: template.label,
    child: InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Le cadre n'entoure que la vignette : le nom et la description
          // restent en dehors, comme dans la maquette.
          Expanded(
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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 210 / 297,
                    child: _Thumbnail(templateId: template.id),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: -8,
                    top: -8,
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
                        size: 16,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: _TemplateGrid.captionGap),
          SizedBox(
            height: _TemplateGrid.captionHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    template.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// La vignette d'un modèle : le CV d'exemple, indépendant de la session.
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _PageImage(page: ref.watch(templateThumbnailProvider(templateId)));
}

/// Le grand aperçu : le CV réel, rendu avec le choix en cours de composition.
class _PagePreview extends ConsumerWidget {
  const _PagePreview({required this.choice});

  final CatalogChoice choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _PageImage(
    page: ref.watch(catalogPreviewProvider(choice)),
    elevated: true,
  );
}

/// La page rendue, ou l'attente et l'échec qui la précèdent.
class _PageImage extends StatelessWidget {
  const _PageImage({required this.page, this.elevated = false});

  final AsyncValue<Uint8List> page;

  /// Le grand aperçu porte une ombre plus marquée que les vignettes.
  final bool elevated;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      boxShadow: [
        BoxShadow(
          color: elevated ? AppColors.pageShadow : AppColors.softShadow,
          blurRadius: elevated ? 14 : 4,
          offset: Offset(0, elevated ? 3 : 1),
        ),
      ],
    ),
    child: ClipRect(
      child: switch (page) {
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.choice,
    required this.hasPhoto,
    required this.onAccent,
    required this.onShowPhoto,
  });

  final CatalogChoice choice;
  final bool hasPhoto;
  final ValueChanged<int> onAccent;
  final ValueChanged<bool> onShowPhoto;

  @override
  Widget build(BuildContext context) {
    final ignoresAccent = choice.design.spec.tokens.ignoresAccent;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(left: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COULEUR D’ACCENT',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: .66,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _AccentField(
                  argb: choice.accentArgb,
                  // Un modèle sans couleur ignore ce réglage.
                  onChanged: ignoresAccent ? null : onAccent,
                ),
                if (ignoresAccent) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Ce modèle n’utilise aucune couleur.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
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
                          const SizedBox(height: 1),
                          Text(
                            hasPhoto
                                ? 'Ce modèle propose aussi une version sans '
                                      'photo.'
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
                    const SizedBox(width: 10),
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

/// La couleur d'accent courante et son accès au sélecteur de couleur.
class _AccentField extends StatelessWidget {
  const _AccentField({required this.argb, required this.onChanged});

  final int argb;

  /// `null` lorsque le modèle choisi n'utilise aucune couleur.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Color(argb);
    final enabled = onChanged != null;
    return Row(
      children: [
        Container(
          key: const Key('accent-swatch'),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? color : color.withValues(alpha: .35),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ColorPickerDialog.hexOf(color),
            style: TextStyle(
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: enabled
              ? () async {
                  final chosen = await showColorPicker(
                    context,
                    initial: color,
                    suggestions: [
                      for (final accent in CvAccent.palette) Color(accent),
                    ],
                  );
                  if (chosen != null) onChanged!(chosen.toARGB32());
                }
              : null,
          icon: const Icon(Icons.palette_outlined, size: 16),
          label: const Text('Choisir'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.outlineVariant)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.outline),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Compatible avec les logiciels de tri des candidatures',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onApply,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Appliquer le modèle'),
        ),
      ],
    ),
  );
}
