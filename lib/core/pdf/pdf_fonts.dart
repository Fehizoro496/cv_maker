import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Polices embarquées dans l'application pour générer le PDF hors ligne.
class PdfFonts {
  const PdfFonts({
    required this.regular,
    required this.bold,
    required this.italic,
  });

  static const regularAsset = 'assets/fonts/NotoSans-Regular.ttf';
  static const boldAsset = 'assets/fonts/NotoSans-Bold.ttf';
  static const italicAsset = 'assets/fonts/NotoSans-Italic.ttf';

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;

  /// Les polices du bundle de l'application, chargées une seule fois.
  ///
  /// Les trois fichiers pèsent près de deux mégaoctets et leur analyse n'est
  /// pas gratuite : le catalogue génère huit PDF d'affilée, et les relire à
  /// chaque fois dominait le temps d'affichage des vignettes.
  static Future<PdfFonts>? _bundled;

  static Future<PdfFonts> load([AssetBundle? bundle]) {
    // Un bundle explicite vient d'un test : il ne partage pas le cache.
    if (bundle != null) return _read(bundle);
    return _bundled ??= _read(rootBundle);
  }

  static Future<PdfFonts> _read(AssetBundle assets) async => PdfFonts(
    regular: pw.Font.ttf(await assets.load(regularAsset)),
    bold: pw.Font.ttf(await assets.load(boldAsset)),
    italic: pw.Font.ttf(await assets.load(italicAsset)),
  );

  pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: regular, bold: bold, italic: italic);
}
