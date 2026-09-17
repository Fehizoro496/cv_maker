import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_fonts.dart';
import '../../domain/cv_section.dart';
import '../../domain/cv_design.dart';
import '../cv_section_presentation.dart';
import '../editor_draft_provider.dart';

/// The preview and export share these exact bytes, with bundled offline fonts.
Future<Uint8List> buildDraftPdf(
  EditorDraft draft,
  Map<CvSection, bool> visibility,
) async {
  final fonts = await PdfFonts.load();
  final document = pw.Document(theme: fonts.theme);
  final modern = draft.design == CvDesign.modern;
  final minimal = draft.design == CvDesign.minimal;
  final accent = PdfColor.fromInt(
    modern
        ? 0xFF176B61
        : minimal
        ? 0xFF343A40
        : 0xFF2F5D8C,
  );
  const grey = PdfColor.fromInt(0xFF3A3F45);
  pw.Widget heading(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 7),
    child: pw.Container(
      padding: modern
          ? const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5)
          : pw.EdgeInsets.zero,
      decoration: modern
          ? pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFEBF4F2),
              border: pw.Border(left: pw.BorderSide(color: accent, width: 3)),
            )
          : null,
      child: pw.Text(
        minimal ? title : title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: minimal ? 10 : 8,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: minimal ? 0 : 1.12,
          color: accent,
        ),
      ),
    ),
  );
  final sections = <pw.Widget>[];
  final profile = draft.fields['Profil professionnel'] ?? '';
  if (profile.isNotEmpty) {
    final lines = profile.split('\n');
    sections.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [heading('Profil professionnel'), pw.Text(lines.first)],
      ),
    );
    for (final line in lines.skip(1)) {
      sections.add(pw.Text(line));
    }
  }
  for (final section in CvSection.values.skip(2)) {
    final entries = draft.entries[section] ?? [];
    if (visibility[section] == false || entries.isEmpty) continue;
    if (section == CvSection.skills || section == CvSection.languages) {
      final text = entries
          .map(
            (entry) => section == CvSection.skills
                ? entry['Nom'] ?? ''
                : '${entry['Langue'] ?? ''}${(entry['Niveau'] ?? '').isEmpty ? '' : ' (${entry['Niveau']})'}',
          )
          .where((v) => v.isNotEmpty)
          .join(' · ');
      sections.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [heading(section.label), pw.Text(text)],
        ),
      );
      continue;
    }
    var first = true;
    for (final entry in entries) {
      final values = entry.entries
          .where(
            (e) =>
                !['id', 'En cours', 'Début', 'Fin', 'Lieu'].contains(e.key) &&
                e.value.isNotEmpty,
          )
          .toList();
      if (values.isEmpty) continue;
      final titleValues = values
          .where((e) => !e.key.startsWith('Description'))
          .map((e) => e.value)
          .toList();
      final description = values
          .where((e) => e.key.startsWith('Description'))
          .map((e) => e.value)
          .join('\n');
      final dates = [
        entry['Début'] ?? '',
        entry['En cours'] == 'true' ? "aujourd'hui" : entry['Fin'] ?? '',
      ].where((v) => v.isNotEmpty).join(' – ');
      sections.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (first) heading(section.label) else pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    titleValues.join(' · '),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  pw.SizedBox(width: 8),
                  pw.Text(
                    dates,
                    style: const pw.TextStyle(fontSize: 8.5, color: grey),
                  ),
                ],
              ],
            ),
            if ((entry['Lieu'] ?? '').isNotEmpty)
              pw.Text(
                entry['Lieu']!,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontStyle: pw.FontStyle.italic,
                  color: grey,
                ),
              ),
          ],
        ),
      );
      if (description.isNotEmpty) {
        for (final line in description.split('\n')) {
          sections.add(pw.Text(line));
        }
      }
      first = false;
    }
  }
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(18 * PdfPageFormat.mm),
      theme: fonts.theme.copyWith(
        defaultTextStyle: const pw.TextStyle(fontSize: 9.5, lineSpacing: 3),
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 9.5,
            color: PdfColor.fromInt(0xFF9AA0A6),
          ),
        ),
      ),
      build: (context) => [
        pw.Container(
          padding: modern ? const pw.EdgeInsets.all(16) : pw.EdgeInsets.zero,
          color: modern ? accent : null,
          child: pw.Row(
            children: [
              if (draft.photo != null) ...[
                pw.ClipOval(
                  child: pw.Image(
                    pw.MemoryImage(draft.photo!),
                    width: 25 * PdfPageFormat.mm,
                    height: 25 * PdfPageFormat.mm,
                    fit: pw.BoxFit.cover,
                  ),
                ),
                pw.SizedBox(width: 18),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: minimal
                      ? pw.CrossAxisAlignment.center
                      : pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      draft.name.isEmpty ? 'Votre nom' : draft.name,
                      style: pw.TextStyle(
                        fontSize: minimal ? 26 : 23,
                        color: modern ? PdfColors.white : PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      draft.fields['Titre professionnel'] ?? '',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: modern ? PdfColors.white : accent,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      [
                            'Localisation',
                            'Téléphone',
                            'E-mail',
                            'Site / portfolio',
                          ]
                          .map((key) => draft.fields[key] ?? '')
                          .where((v) => v.isNotEmpty)
                          .join(' · '),
                      textAlign: minimal
                          ? pw.TextAlign.center
                          : pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: modern ? PdfColors.white : grey,
                      ),
                    ),
                    for (final link
                        in draft.entries[CvSection.personalInfo] ??
                            <Map<String, String>>[])
                      pw.Text(
                        link['URL'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: modern ? PdfColors.white : grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (!modern) pw.Divider(color: accent, thickness: minimal ? .4 : 1),
        ...sections,
      ],
    ),
  );
  return document.save();
}
