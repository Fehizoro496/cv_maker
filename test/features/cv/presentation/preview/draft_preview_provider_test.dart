import 'dart:typed_data';
import 'package:cv_maker/features/cv/presentation/preview/draft_preview_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('preview rasterizes the same PDF bytes that will be exported', () async {
    Uint8List? rasterized;
    final image = Uint8List.fromList([1, 2, 3]);
    final container = ProviderContainer(
      overrides: [
        pdfRasterizerProvider.overrideWithValue((
          bytes, {
          dpi = previewDpi,
        }) async* {
          rasterized = bytes;
          yield image;
        }),
      ],
    );
    addTearDown(container.dispose);
    final preview = await container.read(draftPreviewProvider.future);
    expect(preview.bytes, same(rasterized));
    expect(preview.pages.single, same(image));
  });
  testWidgets('disposing the preview cancels its pending debounce', (
    tester,
  ) async {
    final container = ProviderContainer();
    container.read(draftPreviewProvider);
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
