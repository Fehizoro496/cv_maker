import 'package:cv_maker/core/pdf/pdf_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('les polices sont livrées dans les assets de l\'application', () async {
    for (final asset in [
      PdfFonts.regularAsset,
      PdfFonts.boldAsset,
      PdfFonts.italicAsset,
    ]) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  test('génère un PDF A4 avec des caractères accentués', () async {
    final fonts = await PdfFonts.load();
    final document = pw.Document(theme: fonts.theme);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          children: [
            pw.Text('Éléonore Lefèvre — Chargée de développement'),
            pw.Text(
              'Compétences : ça, œuvre, naïve',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Références',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      ),
    );

    final bytes = await document.save();

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(fonts.theme.defaultTextStyle.font, same(fonts.regular));
  });
}
