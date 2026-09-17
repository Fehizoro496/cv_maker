import 'dart:math' as math;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/notifications/app_toast.dart';
import '../../../../shared/widgets/soft_panel.dart';
import '../draft_preview_provider.dart';
import '../preview_input_provider.dart';

class PdfPreviewPanel extends ConsumerStatefulWidget {
  const PdfPreviewPanel({super.key, this.initialZoom = 100});
  final int initialZoom;
  static const a4AspectRatio = 210 / 297;
  static const minZoom = 50;
  static const maxZoom = 200;
  static const zoomStep = 25;
  // The HTML reference uses a 372 px content box plus 56 px padding.
  static const referencePageWidth = 428.0;
  @override
  ConsumerState<PdfPreviewPanel> createState() => _PdfPreviewPanelState();
}

class _PdfPreviewPanelState extends ConsumerState<PdfPreviewPanel> {
  late int _zoom = widget.initialZoom;
  DraftPreview? _lastPreview;
  bool _exporting = false;

  void _refresh() {
    ref.read(previewInputProvider.notifier).flush();
    ref.invalidate(draftPreviewProvider);
  }

  void _changeZoom(int delta) => setState(
    () => _zoom = (_zoom + delta).clamp(
      PdfPreviewPanel.minZoom,
      PdfPreviewPanel.maxZoom,
    ),
  );

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent &&
        HardwareKeyboard.instance.isControlPressed) {
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (_) => _changeZoom(
          event.scrollDelta.dy < 0
              ? PdfPreviewPanel.zoomStep
              : -PdfPreviewPanel.zoomStep,
        ),
      );
    }
  }

  /// Attend la génération correspondant aux dernières modifications.
  ///
  /// Une saisie pendant l'attente invalide la génération en cours : la boucle
  /// recommence jusqu'à ce que l'aperçu et la session soient d'accord.
  Future<DraftPreview?> _upToDatePreview() async {
    Future<DraftPreview> pending;
    DraftPreview preview;
    do {
      ref.read(previewInputProvider.notifier).flush();
      pending = ref.read(draftPreviewProvider.future);
      preview = await pending;
      if (!mounted) return null;
      ref.read(previewInputProvider.notifier).flush();
    } while (!identical(pending, ref.read(draftPreviewProvider.future)));
    return preview;
  }

  Future<void> _export() async {
    final toasts = ref.read(appToastsProvider.notifier);
    setState(() => _exporting = true);
    // Prévenir seulement si l'attente est réelle : sinon la notification
    // apparaîtrait et disparaîtrait sans que personne ne la lise.
    final waiting = ref.read(previewDirtyProvider)
        ? toasts.show(
            kind: AppToastKind.progress,
            title: 'Mise à jour du PDF…',
            message: "L’export démarrera dès que l’aperçu sera à jour.",
          )
        : null;
    try {
      var preview = await _upToDatePreview();
      if (preview == null) return;
      if (waiting != null) toasts.dismiss(waiting);
      final location = await getSaveLocation(
        suggestedName: 'CV.pdf',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (location == null || !mounted) return;
      preview = await _upToDatePreview();
      if (preview == null) return;
      await XFile.fromData(
        preview.bytes,
        mimeType: 'application/pdf',
      ).saveTo(location.path);
      if (!mounted) return;
      toasts.show(
        kind: AppToastKind.success,
        title: 'PDF exporté',
        message: location.path,
      );
    } catch (_) {
      if (!mounted) return;
      toasts.show(
        kind: AppToastKind.error,
        title: "L’export a échoué",
        message:
            'Le fichier est peut-être ouvert dans une autre application. '
            'Fermez-le puis réessayez.',
        actionLabel: 'Réessayer',
        actionIcon: Icons.refresh,
        onAction: _export,
      );
    } finally {
      if (waiting != null) toasts.dismiss(waiting);
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(draftPreviewProvider);
    final dirty = ref.watch(previewDirtyProvider);
    if (preview.asData != null) _lastPreview = preview.asData!.value;
    final pages = _lastPreview?.pages ?? [];
    return SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(
            dirty: dirty,
            zoom: _zoom,
            onZoomChanged: _changeZoom,
            loading: preview.isLoading,
            error: preview.hasError,
            exporting: _exporting,
            onRefresh: _refresh,
            onExport: _export,
          ),
          SizedBox(
            height: 3,
            child: preview.isLoading
                ? const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppColors.secondaryContainer,
                  )
                : const ColoredBox(color: AppColors.divider),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.surfaceContainer,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Listener(
                      onPointerSignal: _onPointerSignal,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final pageWidth =
                              math.min(
                                PdfPreviewPanel.referencePageWidth,
                                constraints.maxWidth - 32,
                              ) *
                              _zoom /
                              100;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < math.max(1, pages.length);
                                        i++
                                      ) ...[
                                        Opacity(
                                          opacity:
                                              preview.isLoading &&
                                                  pages.isNotEmpty
                                              ? .55
                                              : 1,
                                          child: Container(
                                            key: ValueKey(
                                              i == 0
                                                  ? 'a4-page-placeholder'
                                                  : 'a4-page-$i',
                                            ),
                                            width: pageWidth,
                                            height:
                                                pageWidth /
                                                PdfPreviewPanel.a4AspectRatio,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: const [
                                                BoxShadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 3,
                                                  color: AppColors.softShadow,
                                                ),
                                                BoxShadow(
                                                  offset: Offset(0, 10),
                                                  blurRadius: 28,
                                                  color: AppColors.pageShadow,
                                                ),
                                              ],
                                            ),
                                            child: pages.isEmpty
                                                ? null
                                                : Image.memory(
                                                    pages[i],
                                                    fit: BoxFit.fill,
                                                    gaplessPlayback: true,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Page ${i + 1} sur ${math.max(1, pages.length)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (preview.isLoading || preview.hasError)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          boxShadow: appSoftShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (preview.isLoading) ...[
                              const SizedBox(
                                width: 34,
                                height: 34,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Mise à jour de l’aperçu…',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Le PDF n'a pas pu être généré.",
                                style: TextStyle(fontSize: 12),
                              ),
                              OutlinedButton.icon(
                                onPressed: _refresh,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Réessayer'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
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
    required this.dirty,
    required this.zoom,
    required this.onZoomChanged,
    required this.loading,
    required this.error,
    required this.exporting,
    required this.onRefresh,
    required this.onExport,
  });
  final int zoom;
  final ValueChanged<int> onZoomChanged;
  final bool loading, error, exporting;
  final bool dirty;
  final VoidCallback onRefresh, onExport;
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Text(
              'Aperçu PDF',
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: loading
                ? 'Génération en cours…'
                : error
                ? 'Erreur de génération'
                : dirty
                ? 'À actualiser'
                : 'À jour',
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: error
                    ? AppColors.errorContainer
                    : loading || dirty
                    ? AppColors.primaryTint
                    : AppColors.successContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    error
                        ? Icons.error_outline
                        : loading || dirty
                        ? Icons.hourglass_top
                        : Icons.check_circle_outline,
                    size: 14,
                    color: error
                        ? AppColors.error
                        : loading || dirty
                        ? AppColors.primary
                        : AppColors.onSuccessContainer,
                  ),
                  if (constraints.maxWidth >= 480) const SizedBox(width: 5),
                  if (constraints.maxWidth >= 480)
                    Text(
                      loading
                          ? 'En cours…'
                          : error
                          ? 'Erreur'
                          : dirty
                          ? 'À actualiser'
                          : 'À jour',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: error
                            ? AppColors.error
                            : loading || dirty
                            ? AppColors.onSecondaryContainer
                            : AppColors.onSuccessContainer,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ZoomControl(zoom: zoom, onZoomChanged: onZoomChanged),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Rafraîchir',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
          if (constraints.maxWidth < 400)
            Tooltip(
              message: exporting ? 'Patientez…' : 'Exporter',
              child: FilledButton(
                onPressed: exporting ? null : onExport,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.square(32),
                  fixedSize: const Size.square(32),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.download, size: 16),
              ),
            )
          else
            FilledButton.icon(
              onPressed: exporting ? null : onExport,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.download, size: 16),
              label: Text(exporting ? 'Patientez…' : 'Exporter'),
            ),
        ],
      ),
    ),
  );
}

class _ZoomControl extends StatelessWidget {
  const _ZoomControl({required this.zoom, required this.onZoomChanged});
  final int zoom;
  final ValueChanged<int> onZoomChanged;
  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      foregroundColor: AppColors.onSurfaceVariant,
      minimumSize: const Size.square(24),
      fixedSize: const Size.square(24),
    );
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom arrière',
            style: style,
            iconSize: 16,
            onPressed: zoom > PdfPreviewPanel.minZoom
                ? () => onZoomChanged(-PdfPreviewPanel.zoomStep)
                : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$zoom %',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            tooltip: 'Zoom avant',
            style: style,
            iconSize: 16,
            onPressed: zoom < PdfPreviewPanel.maxZoom
                ? () => onZoomChanged(PdfPreviewPanel.zoomStep)
                : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
