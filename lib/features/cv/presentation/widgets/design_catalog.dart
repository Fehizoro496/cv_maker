import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/cv_design.dart';

/// Offline gallery with thumbnails rendered from the actual PDF templates.
class DesignCatalog extends StatelessWidget {
  const DesignCatalog({super.key, required this.selected});

  final CvDesign selected;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 940, maxHeight: 720),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Choisir un design',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer le catalogue',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Un nouveau style, le même contenu. Choisissez le modèle qui vous ressemble.',
            ),
            const SizedBox(height: 6),
            Text(
              'Aperçus sur un CV d’exemple · 3 modèles disponibles hors ligne',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 780
                      ? 3
                      : constraints.maxWidth >= 500
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final design in CvDesign.values)
                          SizedBox(
                            width: width,
                            child: _DesignCard(
                              design: design,
                              selected: design == selected,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({required this.design, required this.selected});
  final CvDesign design;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final description = switch (design) {
      CvDesign.professional =>
        'Une présentation classique, structurée et un accent bleu discret.',
      CvDesign.modern =>
        'Un en-tête vert affirmé et des titres de section mis en valeur.',
      CvDesign.minimal =>
        'Un en-tête centré et une mise en page épurée en noir et blanc.',
    };
    return Container(
      key: ValueKey('design-card-${design.name}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryTint : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: 280,
              child: Image.asset(
                'assets/designs/${design.name}.png',
                fit: BoxFit.contain,
                semanticLabel: 'Aperçu du modèle ${design.label}',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  design.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton(
            key: ValueKey('choose-design-${design.name}'),
            onPressed: selected ? null : () => Navigator.pop(context, design),
            child: Text(selected ? 'Modèle actuel' : 'Choisir ${design.label}'),
          ),
        ],
      ),
    );
  }
}
