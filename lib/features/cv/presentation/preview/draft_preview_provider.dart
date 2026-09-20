import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'preview_input_provider.dart';
import 'widgets/cv_pdf.dart';

/// Rend chaque page d'un PDF en PNG, à la résolution demandée.
typedef PdfRasterizer =
    Stream<Uint8List> Function(Uint8List bytes, {double dpi});

/// Résolution des aperçus pleine page : celui de l'éditeur et celui que le
/// catalogue affiche à droite.
const previewDpi = 110.0;

/// Résolution des vignettes du catalogue.
///
/// Une vignette fait moins de deux cents pixels de large : la rendre à
/// [previewDpi] produisait sept fois trop de pixels par page, tous encodés en
/// PNG avant d'être réduits à l'affichage.
const thumbnailDpi = 40.0;

final pdfRasterizerProvider = Provider<PdfRasterizer>(
  (ref) => (bytes, {dpi = previewDpi}) async* {
    await for (final page in Printing.raster(bytes, dpi: dpi)) {
      yield await page.toPng();
    }
  },
);

class DraftPreview {
  const DraftPreview(this.bytes, this.pages);
  final Uint8List bytes;
  final List<Uint8List> pages;
}

final draftPreviewProvider = FutureProvider<DraftPreview>((ref) async {
  final session = ref.watch(previewInputProvider);
  final rasterize = ref.watch(pdfRasterizerProvider);
  final bytes = await buildCvPdf(
    session.document,
    session.document.designSpec,
    photo: session.photo,
  );
  if (!ref.mounted) throw StateError('Generation superseded');
  final pages = <Uint8List>[];
  await for (final page in rasterize(bytes)) {
    if (!ref.mounted) throw StateError('Generation superseded');
    pages.add(page);
  }
  return DraftPreview(bytes, pages);
});
