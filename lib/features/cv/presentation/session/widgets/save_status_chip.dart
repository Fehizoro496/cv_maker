import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/app_theme.dart';
import '../cv_autosave.dart';

/// La puce « Enregistré », « Enregistrement… » ou « Erreur d'enregistrement »
/// de l'en-tête du formulaire.
///
/// L'icône d'attente ne tourne pas : une animation infinie empêcherait les
/// tests d'attendre la fin des animations.
class SaveStatusChip extends ConsumerWidget {
  const SaveStatusChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(cvSaveStatusProvider);
    final (icon, label, background, foreground, tooltip) = switch (status) {
      CvSaveStatus.saved => (
        Icons.check_circle_outline,
        'Enregistré',
        AppColors.successContainer,
        AppColors.onSuccessContainer,
        'Vos modifications sont enregistrées sur cet ordinateur.',
      ),
      CvSaveStatus.saving => (
        Icons.sync,
        'Enregistrement…',
        AppColors.surfaceContainer,
        AppColors.onSurfaceVariant,
        'Enregistrement des dernières modifications.',
      ),
      CvSaveStatus.error => (
        Icons.error_outline,
        'Erreur d’enregistrement',
        AppColors.errorContainer,
        AppColors.error,
        'Vos modifications sont conservées en mémoire mais n’ont pas pu '
            'être enregistrées.',
      ),
    };
    final fontSize = compact ? 11.0 : 12.0;
    return Tooltip(
      message: tooltip,
      child: Container(
        height: compact ? 26 : 28,
        padding: EdgeInsets.only(
          left: 10,
          right: status == CvSaveStatus.error ? 2 : 10,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            // Dans un en-tête étroit, le libellé cède la place au bouton.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
            if (status == CvSaveStatus.error) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 22,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => ref.read(cvAutosaveProvider).flush(),
                  child: const Text('Réessayer'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
