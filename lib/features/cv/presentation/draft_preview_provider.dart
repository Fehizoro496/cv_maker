import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../domain/cv_design_spec.dart';
import 'preview_input_provider.dart';
import 'widgets/cv_pdf.dart';

final pdfRasterizerProvider = Provider<Stream<Uint8List> Function(Uint8List)>(
  (ref) => (bytes) async* {
    await for (final page in Printing.raster(bytes, dpi: 110)) {
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
    session.document.design.spec,
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
