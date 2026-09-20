import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import 'app_toast.dart';

/// Superpose les notifications au-dessus de toute l'application.
///
/// La couche est posée au-dessus du `Navigator`, et non dans un écran : une
/// notification reste donc visible après un changement d'onglet et par-dessus
/// un dialogue. Les notifications ne passent pas par `ScaffoldMessenger`, dont
/// la barre du bas masquerait l'aperçu.
class ToastLayer extends StatelessWidget {
  const ToastLayer({super.key, required this.child});

  final Widget child;

  /// Largeur d'une notification, réduite en fenêtre étroite.
  static const wideWidth = 400.0;
  static const narrowWidth = 300.0;
  static const narrowBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned(
        right: 16,
        bottom: 16,
        // Posée hors du Navigator, la pile n'a pas d'Overlay au-dessus d'elle ;
        // sans celui-ci, un tooltip ou un menu échouerait à s'afficher.
        child: Overlay.wrap(
          child: _ToastStack(
            width: MediaQuery.sizeOf(context).width < narrowBreakpoint
                ? narrowWidth
                : wideWidth,
          ),
        ),
      ),
    ],
  );
}

class _ToastStack extends ConsumerWidget {
  const _ToastStack({required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(appToastsProvider);
    if (toasts.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // La plus récente en bas, comme le prévoit le design.
        for (final toast in toasts)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _ToastCard(
              key: ValueKey(toast.id),
              toast: toast,
              width: width,
            ),
          ),
      ],
    );
  }
}

class _ToastCard extends ConsumerStatefulWidget {
  const _ToastCard({super.key, required this.toast, required this.width});

  final AppToast toast;
  final double width;

  @override
  ConsumerState<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends ConsumerState<_ToastCard> {
  var _shown = false;

  @override
  void initState() {
    super.initState();
    // Le glissement et le fondu partent au premier rendu suivant.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  ({Color color, IconData icon, Color border}) get _style =>
      switch (widget.toast.kind) {
        AppToastKind.progress => (
          color: AppColors.primary,
          icon: Icons.autorenew,
          border: AppColors.outlineVariant,
        ),
        AppToastKind.info => (
          color: AppColors.primary,
          icon: Icons.style,
          border: AppColors.outlineVariant,
        ),
        AppToastKind.success => (
          color: AppColors.onSuccessContainer,
          icon: Icons.check_circle,
          border: AppColors.outlineVariant,
        ),
        AppToastKind.error => (
          color: AppColors.error,
          icon: Icons.error,
          border: AppColors.errorBorder,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final toast = widget.toast;
    final style = _style;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      offset: _shown ? Offset.zero : const Offset(0, .3),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _shown ? 1 : 0,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: style.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.pageShadow,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            // Le contenu est découpé par le cadre de la carte, rayon de la
            // bordure déduit. C'est ce qui donne au filet ses angles : un
            // rayon de carte sur un ruban de 4 px de large produirait une
            // forme en goutte, et un ruban sans rayon dépasserait des coins.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card - 1),
              child: Stack(
                children: [
                  // Le filet de couleur porte la nature de la notification.
                  // Il est posé plutôt que placé dans la rangée : une hauteur
                  // fixe s'arrêterait au milieu d'une carte à deux lignes de
                  // texte ou à bouton d'action.
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: ColoredBox(color: style.color),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Icon(style.icon, size: 20, color: style.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                toast.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (toast.message != null) ...[
                                const SizedBox(height: 2),
                                // Deux lignes au plus, pour que la pile reste
                                // lisible. Le texte entier est au survol : un
                                // chemin d'export un peu long perd sinon sa fin,
                                // c'est-à-dire le nom du fichier.
                                Tooltip(
                                  message: toast.message!,
                                  waitDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                  child: Text(
                                    toast.message!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                              if (toast.hasAction) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(appToastsProvider.notifier)
                                          .dismiss(toast.id);
                                      toast.onAction!();
                                    },
                                    icon: Icon(
                                      toast.actionIcon ?? Icons.refresh,
                                      size: 15,
                                    ),
                                    label: Text(toast.actionLabel!),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      shape: const StadiumBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fermer',
                        iconSize: 18,
                        style: IconButton.styleFrom(
                          fixedSize: const Size.square(36),
                          foregroundColor: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () => ref
                            .read(appToastsProvider.notifier)
                            .dismiss(toast.id),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
