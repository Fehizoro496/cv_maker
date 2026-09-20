import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cv_maker/shared/images/photo_bytes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un PNG uni de [width] × [height], peint plutôt qu'écrit à la main.
  Future<Uint8List> png(int width, int height) async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFF3366AA),
    );
    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  /// Les dimensions d'une image encodée.
  Future<(int, int)> sizeOf(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final image = (await codec.getNextFrame()).image;
    final size = (image.width, image.height);
    image.dispose();
    codec.dispose();
    return size;
  }

  test('une image assez petite est renvoyée telle quelle', () async {
    final bytes = await png(300, 400);

    expect(await normalizePhoto(bytes), same(bytes));
  });

  test('une image pile à la borne n’est pas retouchée', () async {
    final bytes = await png(photoMaxSide, 200);

    expect(await normalizePhoto(bytes), same(bytes));
  });

  test(
    'une image trop large est ramenée à la borne, proportions gardées',
    () async {
      final bytes = await png(1800, 900);

      expect(await sizeOf(await normalizePhoto(bytes)), (photoMaxSide, 300));
    },
  );

  test('une image trop haute est ramenée par sa hauteur', () async {
    final bytes = await png(600, 2400);

    expect(await sizeOf(await normalizePhoto(bytes)), (150, photoMaxSide));
  });

  test('une grande image devient nettement plus légère', () async {
    final bytes = await png(2400, 2400);

    expect(
      (await normalizePhoto(bytes)).length,
      lessThan(bytes.length),
      reason: 'c’est tout l’intérêt de la borne',
    );
  });

  test('des octets qui ne sont pas une image sont refusés', () {
    expect(
      normalizePhoto(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(isA<Exception>()),
    );
  });
}
