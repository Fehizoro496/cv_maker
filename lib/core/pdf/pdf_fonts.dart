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

  static Future<PdfFonts> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    return PdfFonts(
      regular: pw.Font.ttf(await assets.load(regularAsset)),
      bold: pw.Font.ttf(await assets.load(boldAsset)),
      italic: pw.Font.ttf(await assets.load(italicAsset)),
    );
  }

  pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: regular, bold: bold, italic: italic);
}
