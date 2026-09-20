import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Côté maximal, en pixels, d'une photo enregistrée avec un CV.
///
/// Le PDF imprime la photo dans un cercle d'environ 35 mm, soit 410 pixels à
/// 300 points par pouce : 600 laisse de la marge à un modèle plus généreux
/// sans garder les millions de pixels d'un appareil photo, qui entreraient
/// dans la base et dans chaque PDF exporté.
const photoMaxSide = 600;

/// Vérifie que [bytes] est une image lisible et la ramène à [photoMaxSide].
///
/// Une image déjà assez petite est renvoyée telle quelle : c'est ce qui
/// préserve la compacité d'un JPEG, que le ré-encodage transformerait en PNG
/// plus lourd. Lève si les octets ne sont pas une image.
Future<Uint8List> normalizePhoto(Uint8List bytes) async {
  final decoded = await _decode(bytes);
  final longest = math.max(decoded.width, decoded.height);
  final portrait = decoded.height > decoded.width;
  decoded.dispose();
  if (longest <= photoMaxSide) return bytes;

  // Un seul côté est imposé : le codec déduit l'autre et garde les
  // proportions.
  final scaled = await _decode(
    bytes,
    targetWidth: portrait ? null : photoMaxSide,
    targetHeight: portrait ? photoMaxSide : null,
  );
  try {
    final png = await scaled.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) {
      throw const FormatException('Image impossible à ré-encoder.');
    }
    return png.buffer.asUint8List();
  } finally {
    scaled.dispose();
  }
}

Future<ui.Image> _decode(
  Uint8List bytes, {
  int? targetWidth,
  int? targetHeight,
}) async {
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: targetWidth,
    targetHeight: targetHeight,
  );
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}
