import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'preview_input_provider.dart';
import 'widgets/draft_pdf.dart';

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
  final input = ref.watch(previewInputProvider);
  final rasterize = ref.watch(pdfRasterizerProvider);
  final bytes = await buildDraftPdf(input.draft, input.visibility);
  if (!ref.mounted) throw StateError('Generation superseded');
  final pages = <Uint8List>[];
  await for (final page in rasterize(bytes)) {
    if (!ref.mounted) throw StateError('Generation superseded');
    pages.add(page);
  }
  return DraftPreview(bytes, pages);
});
